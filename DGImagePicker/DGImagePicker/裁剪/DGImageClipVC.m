//
//  DGImageClipVC.m
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import "DGImageClipVC.h"
#import "DGIP_Header.h"

#define kScaleFrameY    100.0f
#define kShowImgViewOriginX    5.0f
#define kBounceDuration 0.3f

@interface DGImageClipVC ()<UIGestureRecognizerDelegate>
/** 最大缩放比例(放大) */
@property (nonatomic, assign) CGFloat maxScale;
/** 是否 是圆形 */
@property (nonatomic,assign) BOOL needCircle;
/** 裁剪尺寸 */
@property (nonatomic,assign) CGSize rectangleSize;

/** 原始图 */
@property (nonatomic, retain) UIImage *originalImage;
/** 裁剪后的图片 */
@property (nonatomic, retain) UIImage *clipedImage;

@property (nonatomic, retain) UIImageView *showImgView;
@property (nonatomic, retain) UIView *maskView;
@property (nonatomic, retain) UIView *clipLineView;

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic,assign) CGRect clipFrame;

@end

@implementation DGImageClipVC

#pragma mark - init
- (id)initWithImage:(UIImage *)image maxScale:(CGFloat)maxScale rectangleSize:(CGSize)rectangleSize needCircle:(BOOL)needCircle{
    
    self = [super init];
    if (self) {
        self.maxScale = maxScale;
        self.originalImage = image;
        self.needCircle = needCircle;
        
        CGFloat w = DGIP_SCREEN_W - 2*kShowImgViewOriginX;
        if (needCircle) {
            self.rectangleSize = CGSizeMake(w, w);
        }else{
            if(rectangleSize.height <=0 || rectangleSize.width <= 0){
                self.rectangleSize = CGSizeMake(w, w);
            }else{
                CGFloat h = (rectangleSize.height*w)/rectangleSize.width;
                self.rectangleSize = CGSizeMake(w, h);
            }
        }
    }
    return self;
}

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupUI];
}

#pragma mark - statusBar
- (BOOL)shouldAutorotate {
    return NO;
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - UI
/** 设置UI */
- (void)setupUI {
    [self setupNavi];
    
    [self setupShowImgView];
    [self setupMaskView];
    [self setupClipLineView];
    //根据clipFrame添加蒙层,所以在setupClipLineView方法调用后
    [self maskViewSetMask];
    [self addGestureRecognizers];
}


#pragma mark navi
-(void)setupNavi {
    
    self.navigationController.navigationBarHidden = NO;
    
    //1.title
    self.navigationItem.title = @"裁切";
    
    //2.left
    UIImage *leftImg = [UIImage imageNamed:@"dgip_navi_back"];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:leftImg style:UIBarButtonItemStylePlain target:self action:@selector(clickNaviBackItem:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    //3.right
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确认 " style:UIBarButtonItemStylePlain target:self action:@selector(clickNaviConfirmItem:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)clickNaviBackItem:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickNaviConfirmItem:(id)sender{
    
    if (self.finishhandle) {
        UIImage *image = self.needCircle ? [self getCircleImage] : [self getRectImage];
        self.finishhandle(self,image);
    }
}

#pragma mark subviews
-(void)setupShowImgView {
    //1.创建
    self.showImgView = [[UIImageView alloc] init];
    self.showImgView.image = self.originalImage;
    self.showImgView.userInteractionEnabled = YES;
    self.showImgView.multipleTouchEnabled = YES;
    
    //2.计算尺寸 设置frame
    CGFloat imgW = self.originalImage.size.width;
    CGFloat imgH = self.originalImage.size.height;
    CGFloat w = self.rectangleSize.width;
    CGFloat h = w * (imgH/imgW);
    //如果宽高比 > rectangleSize的宽高比
    if (imgW/imgH > self.rectangleSize.width/self.rectangleSize.height) {
        h = self.rectangleSize.height;
        w =  h * (imgW/imgH);
    }
    CGPoint center = self.view.center;
    center.y -= DGIP_STATUS_AND_NAVI_BAR_HEIGHT/2.0;//DGImagePickerManager中添加naviC.navigationBar.translucent = NO;后做的适配
    self.showImgView.center = center;
    self.showImgView.bounds = CGRectMake(0, 0, w, h);
    
    //3.add
    [self.view addSubview:self.showImgView];
    
    //4.记录frame
    self.originalFrame = self.showImgView.frame;
}

/** 设置MaskView */
-(void)setupMaskView {
    //1.创建
    self.maskView = [[UIView alloc] initWithFrame:self.view.frame];
    self.maskView.alpha = 0.5f;
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.userInteractionEnabled = NO;
    self.maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //2.add
    [self.view addSubview:self.maskView];
}


/** 设置maskView的蒙层 */
- (void)maskViewSetMask {
    
    //1.path
    CGFloat radius = self.needCircle ? self.clipFrame.size.width/2.0 : 0;
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:self.clipFrame cornerRadius:radius];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.maskView.frame];
    //bezierPathByReversingPath方法 获得与原path相同形状,但不同方向的新path对象
    [path appendPath: [roundedRectPath bezierPathByReversingPath]];
    
    //2.layer 
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.maskView.frame;
    maskLayer.path = path.CGPath;
    
    //3.mask
    self.maskView.layer.mask = maskLayer;
}

/** 设置ClipLineView */
-(void)setupClipLineView {
    //1.创建
    self.clipLineView = [[UIView alloc]init];
    
    //2.设置frame
    self.clipLineView.center = self.showImgView.center;
    self.clipLineView.bounds = CGRectMake(0, 0, self.rectangleSize.width, self.rectangleSize.height);
    self.clipLineView.autoresizingMask = UIViewAutoresizingNone;
    
    self.clipLineView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.clipLineView.layer.borderWidth = 1.0f;
    if (self.needCircle) {//需要切圆形
        self.clipLineView.layer.cornerRadius = self.rectangleSize.width/2.0 ;
    }
    
    //3.add
    [self.view addSubview:self.clipLineView];
    
    //4.记录frame
    self.clipFrame = self.clipLineView.frame;
}

#pragma mark - 手势
- (void) addGestureRecognizers {
    
    //1.给clipLineView加手势
//    UIPanGestureRecognizer *clipLineViewPanGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panClipLineView:)];
//    [self.clipLineView addGestureRecognizer:clipLineViewPanGr];
    
    //2.给self.view加手势
    //1.1 pinch
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    //2.2 pan
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

/** ClipLineView的pan手势 */
-(void)panClipLineView:(UIPanGestureRecognizer *)gr {
    if (gr.view == self.clipLineView) {
        if (gr.state == UIGestureRecognizerStateBegan) {
            CGPoint p = [gr locationInView:gr.view];
        }
    }
}

/** self.view的pinch */
- (void) pinchView:(UIPinchGestureRecognizer *)gr{
    
    UIView *view = self.showImgView;
    if (gr.state == UIGestureRecognizerStateBegan
        || gr.state == UIGestureRecognizerStateChanged) {
        
        view.transform = CGAffineTransformScale(view.transform, gr.scale, gr.scale);
        //去掉本次比率，归1
        gr.scale = 1;
    
    }else if (gr.state == UIGestureRecognizerStateEnded) {
        
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self checkScaleOverflow:newFrame];
        [UIView animateWithDuration:kBounceDuration animations:^{
            self.showImgView.frame = newFrame;
        }];
    }
}

/** self.view的pan */
- (void) panView:(UIPanGestureRecognizer *)gr {
    
    if (gr.state == UIGestureRecognizerStateBegan
        || gr.state == UIGestureRecognizerStateChanged) {
        
        CGFloat scaleRatio = 1;//移动比例
        CGPoint translation = [gr translationInView:self.view];
        CGPoint center = self.showImgView.center;
        center.x += translation.x * scaleRatio;
        center.y += translation.y * scaleRatio;
        self.showImgView.center = center;
        
        //将本次走了的距离归0
        [gr setTranslation:CGPointZero inView:self.view];
   
    }else if (gr.state == UIGestureRecognizerStateEnded) {
    
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self checkBorderOverflow:newFrame];
        
        [UIView animateWithDuration:kBounceDuration animations:^{
            self.showImgView.frame = newFrame;
        }];
    }
}

/** 检查scale溢出 */
- (CGRect)checkScaleOverflow:(CGRect)newFrame {
    
    CGFloat newW = newFrame.size.width;
    CGFloat newH = newFrame.size.height;
    CGFloat originalW = self.originalFrame.size.width;
    CGFloat originalH = self.originalFrame.size.height;
    CGFloat maxW = self.maxScale * originalW;
    CGFloat maxH = self.maxScale * originalH;
    
    //1.缩小
    if (newW < originalW || newH < originalH) {
        newFrame = self.originalFrame;
    }
    
    //2.放大
    if (newW > maxW || newH > maxH) {
        //center保持不变
        CGFloat w = maxW;
        CGFloat h = maxH;
        CGFloat x = newFrame.origin.x + (newW - w)/2;
        CGFloat y = newFrame.origin.y + (newH - h)/2;
        newFrame = CGRectMake(x, y, w, h);
    }
    
    //3.return
    return newFrame;
}

/** 检查border溢出 */
- (CGRect)checkBorderOverflow:(CGRect)newFrame {
    
    //相对于裁剪框
    CGRect clipFrame = self.clipFrame;
    
    //0.如果left和right同时留白, 或者top和bottom同时留白 ==> 返回的frame和originalFrame的center相同
    if ((newFrame.origin.x > clipFrame.origin.x
        && CGRectGetMaxX(newFrame) < CGRectGetMaxX(clipFrame))
        || (newFrame.origin.y > clipFrame.origin.y && CGRectGetMaxY(newFrame) < CGRectGetMaxY(clipFrame))){
        CGRect originalFrame = self.originalFrame;
        newFrame.origin.x = originalFrame.origin.x + (originalFrame.size.width-newFrame.size.width)/2.0;
        newFrame.origin.y = originalFrame.origin.y + (originalFrame.size.height-newFrame.size.height)/2.0;
        return newFrame;
    }
    
    //1.left不能留白
    if (newFrame.origin.x > clipFrame.origin.x){
        newFrame.origin.x = clipFrame.origin.x;
    
    //2.right不能留白
    }else if (CGRectGetMaxX(newFrame) < CGRectGetMaxX(clipFrame)){
        newFrame.origin.x = CGRectGetMaxX(clipFrame) - newFrame.size.width;
    }
    
    //3.top不能留白
    if (newFrame.origin.y > clipFrame.origin.y){
        newFrame.origin.y = clipFrame.origin.y;
    
    //4.bottom不能留白
    }else if (CGRectGetMaxY(newFrame) < CGRectGetMaxY(clipFrame)) {
        newFrame.origin.y = CGRectGetMaxY(clipFrame) - newFrame.size.height;
    }

    //5.return
    return newFrame;
}

#pragma mark - gestureRecognizer delegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gr {
    if (gr.view == self.clipLineView) {
        CGPoint p = [gr locationInView:gr.view];
        CGRect rect = CGRectInset(self.clipLineView.frame, 5, 5);
        if (CGRectContainsPoint(rect, p)) {
            return  NO;
        }
        
    }
    return YES;
}


#pragma mark - 图片裁剪
/** 获取 矩形图片 */
-(UIImage *)getRectImage{
    
    CGRect clipFrame = self.clipFrame;
    CGRect showFrame = self.showImgView.frame;
    CGFloat scaleRatio = showFrame.size.width / self.originalImage.size.width;
    
    //1.计算要截取的范围
    CGFloat x = (clipFrame.origin.x - showFrame.origin.x) / scaleRatio;
    CGFloat y = (clipFrame.origin.y - showFrame.origin.y) / scaleRatio;
    CGFloat w = clipFrame.size.width / scaleRatio;
    CGFloat h = clipFrame.size.height / scaleRatio;
    
    //2和3不会同时符合判断,因为初始化showImageView时,originalFrame和clipFrame的宽高至少有一个是相同的
    //2.保证 水平方向 被图填充满
    if (showFrame.size.width < clipFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (clipFrame.size.height / clipFrame.size.width);
        x = 0;
        y += (h - newH) / 2;
        w = newH;
        h = newH;
    }

    //3.保证 竖直方向 被图填充满
    if (showFrame.size.height < clipFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (clipFrame.size.width / clipFrame.size.height);
        x += (w - newW) / 2;
        y = 0;
        w = newH;
        h = newH;
    }
    
    //4.裁剪
    CGImageRef imgRef = self.originalImage.CGImage;
    CGRect subImgRect = CGRectMake(x, y, w, h);
    CGImageRef subImgRef = CGImageCreateWithImageInRect(imgRef, subImgRect);
    
    UIGraphicsBeginImageContext(subImgRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImgRect, subImgRef);
    UIImage* subImage = [UIImage imageWithCGImage:subImgRef];
    CGImageRelease(subImgRef);
    UIGraphicsEndImageContext();
    
    //5.return
    return subImage;
}

/** 获取圆形图片 */
-(UIImage *)getCircleImage {
    UIImage *rectImg = [self getRectImage];
    return [self makeEllipseImage:rectImg];
}


/** 生成椭圆形图片,如果image宽高相等则为圆形 */
-(UIImage*)makeEllipseImage:(UIImage*)image {
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    //1.创建临时画布
    UIGraphicsBeginImageContext(image.size);
    
    //2.获取context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //3.设置绘图有效区
    //只有在path内部的部分才允许绘制,在该path以外的部分设置为绘图无效区，
   
    //方式1
    //UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    //[path addClip];
    
    //方式2
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    //4.绘图
    [image drawInRect:rect];
    
    //5.设置描边
//    CGContextSetLineWidth(context, 1);
//    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//    CGContextAddEllipseInRect(context, rect);
//    CGContextStrokePath(context);
    
    //6.获取图片
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    
    //7.结束
    UIGraphicsEndImageContext();
    
    //8.reutrn
    return newImg;
}


#pragma mark - 调整imageSize
/** 图片缩放到指定大小尺寸 */
- (UIImage *)resizeImg:(UIImage *)img toSize:(CGSize)size{

    UIGraphicsBeginImageContext(size);
    
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    
    //1.获取原图size
    CGImageRef imgRef = image.CGImage;
    CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    
    //2.等于目标size,直接return
    if (CGSizeEqualToSize(srcSize, size)) {
        return image;
    }
    
    //3.size处理,transform
    CGFloat scaleRatio = size.width / srcSize.width;
    UIImageOrientation orient = image.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            size = CGSizeMake(size.height, size.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            size = CGSizeMake(size.height, size.width);
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            size = CGSizeMake(size.height, size.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            size = CGSizeMake(size.height, size.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    //4.临时画布,画出来
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) { return nil; }
    
    if (orient == UIImageOrientationRight
        || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -srcSize.height, 0);
    
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -srcSize.height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //5.return
    return resizedImage;
}


@end



