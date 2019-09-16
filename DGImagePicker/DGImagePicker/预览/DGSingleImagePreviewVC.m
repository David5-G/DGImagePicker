//
//  DGSingleImagePreviewVC.m

//
//  Created by david on 16/7/21.
//  Copyright © 2016年 david. All rights reserved.
//

#import "DGSingleImagePreviewVC.h"
#import "DGIP_Header.h"
#import "DGToast.h"

static const float maxZoom = 3.0;
static const float minZoom = 0.5;

@interface DGSingleImagePreviewVC ()<UIScrollViewDelegate>

@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic, strong) NSMutableDictionary *mutableDic;
@property (nonatomic, strong) UIImageView *imageView;
//判断是否是url
@property (nonatomic,assign,getter=isLoadImageUrl) BOOL loadImageUrl;
//当前的缩放比
@property (nonatomic,assign) CGFloat currentScale;
//判断当前点击是否是doubleTap
@property (nonatomic,assign,getter=isDoubleTaping) BOOL doubleTaping;
@end

@implementation DGSingleImagePreviewVC

#pragma mark - 懒加载
-(NSMutableDictionary *)mutableDic{
    if (!_mutableDic) {
        _mutableDic = [NSMutableDictionary dictionary];
    }
    return _mutableDic;
}
#pragma mark - 生命周期
- (id)initWithImageURL:(NSURL *)imageUrl {
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //赋值
        _imageUrl = imageUrl;
        _loadImageUrl = YES;
    }
    return self;
}

-(id)initWithImage:(UIImage *)image{
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _image = image;
        _loadImageUrl = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    //1.配置scrollView
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DGIP_SCREEN_W, DGIP_SCREEN_H)];
    self.scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.maximumZoomScale = maxZoom;
    scrollView.minimumZoomScale = minZoom;
    scrollView.bouncesZoom = YES;
    scrollView.contentSize =CGSizeMake(DGIP_SCREEN_W, DGIP_SCREEN_H);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    //2.配置indicatorView
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]init];
    self.indicatorView = indicatorView;
    indicatorView.center = self.view.center;
    [self.view addSubview:indicatorView];
    
    //3.如果是Url加载图片
    if(self.isLoadImageUrl){
        [self configWithUrl];
    }else{
        [self configWithImage];
    }
    
}

#pragma mark - statuBar
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - 配置
/** 用url配置imageView*/
-(void)configWithUrl{
    //动画开始
    [self.indicatorView startAnimating];
    UIImage *image = self.mutableDic[self.imageUrl.absoluteString];
    if (image) {
        //字典中有数据,直接显示
        [self updateImageView:image];
    } else {
        //字典中没有数据；从沙盒指定的文件中读取
        NSString *imagePath = [self getImagePathFromSandbox:self.imageUrl];
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        if (data) {
            //沙盒中有
            [self updateImageView:[UIImage imageWithData:data]];
        } else {
            //字典中没有；并且沙盒也没有
            //下载逻辑
            [self startDownloadAndStore];
        }
    }
}
/** 用image配置imageView*/
-(void)configWithImage{
    [self updateImageView:self.image];
}

#pragma mark - 图片
- (NSString *)getImagePathFromSandbox:(NSURL *)imageUrl {
    //需求：xxx/Library/Caches/photo_%d.jpg
    //http://images.apple.com/v/iphone-5s/gallery/a/images/download/photo_6.jpg
    //cachesPath: xxx/Library/Caches
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    //NSURL取最后一个组件component
    //xxx/Library/Caches/photo_%d.jpg
    return [cachesPath stringByAppendingPathComponent:[imageUrl lastPathComponent]];
}

- (void)startDownloadAndStore {
    //使用GCD来下载图片
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:self.imageUrl];
        //检查url是否可用决定后续操作
        if(!imageData.length){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        UIImage *image = [UIImage imageWithData:imageData];
        //存到字典中
        self.mutableDic[self.imageUrl.absoluteString] = image;
        //存到沙盒中
        NSString *imagePath = [self getImagePathFromSandbox:self.imageUrl];
        [imageData writeToFile:imagePath atomically:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新UI
            [self updateImageView:image];
        });
    });
}

//更新图片 加载上去
- (void)updateImageView:(UIImage *)image {

    //1.创建imageView；添加到scrollView
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.bounds = CGRectMake(0, 0, DGIP_SCREEN_W, DGIP_SCREEN_W/image.size.width*image.size.height);
    self.imageView.center = self.scrollView.center;
    [self.scrollView addSubview:self.imageView];
//    self.scrollView.contentSize = self.imageView.size;
    CGSize size = self.scrollView.contentSize;
//    NSLog(@"w = %f, h = %f", size.width, size.height);

    //2.添加手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapImageView:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapImageView:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:doubleTap];
    //3.添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 1.0;
    [self.imageView addGestureRecognizer:longPress];
    
    self.imageView.userInteractionEnabled = YES;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    //4.停止动画
    if(self.isLoadImageUrl){
         [self.indicatorView stopAnimating];
    }
}

#pragma mark - Gesture手势操作
/** singleTap退出ImageViewController */
-(void)singleTapImageView:(UITapGestureRecognizer *)gr{
    if (self.isDoubleTaping) {
        return;
    }
      //左侧推出
//    CATransition * animation = [CATransition animation];
//    animation.duration = 0.4;
//    animation.type = kCATransitionPush;
//    animation.subtype = kCATransitionFromLeft;
//    [self.view.window.layer addAnimation:animation forKey:nil];
//    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)doubleTapImageView:(UITapGestureRecognizer *)gr{
    if (self.isDoubleTaping) {
        return;
    }
    self.doubleTaping = YES;
    if (self.currentScale == 1.0) {
        self.currentScale = maxZoom;
        [self.scrollView setZoomScale:maxZoom animated:YES];
    }else{
        self.currentScale = 1.0;
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
    //延时做标记判断，使用户点击3次时的单击效果不生效。
    [self performSelector:@selector(doubleTaping) withObject:nil afterDelay:0.65];
}

-(void)doubleTaping{
    self.doubleTaping = NO;
}


-(void)longPress:(UILongPressGestureRecognizer *)gr{
        //1.创建AlertController
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message: @"保存图片到本地相册" preferredStyle:UIAlertControllerStyleAlert];
        //2.创建界面上的按钮
        UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [actionCancel setValue:[UIColor darkGrayColor] forKey:@"titleTextColor"];
        
        [alert addAction:actionCancel];
        [alert addAction:actionYes];
        
        //3.设置message字体样式
        NSMutableAttributedString *alertTitleStr = [[NSMutableAttributedString alloc] initWithString:alert.message];
        [alertTitleStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, alert.message.length)];
        [alert setValue:alertTitleStr forKey:@"attributedMessage"];
        
        //3.显示AlertController
        [self presentViewController:alert animated:YES completion:nil];
   
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [DGToast showMsg:@"保存成功" duration:2.0];
    }else{
        [DGToast showMsg:@"保存失败" duration:2.0];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    //    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    //     ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    //    self.imageView.center = CGPointMake(xcenter, ycenter);
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                        scrollView.contentSize.height * 0.5 + offsetY);
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    self.currentScale = scale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


@end
