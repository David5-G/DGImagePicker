//
//  ViewController.m
//  DGImagePicker
//
//  Created by david on 2018/12/11.
//  Copyright © 2018 david. All rights reserved.
//

#import "ViewController.h"
#import "DGImagePickerManager.h"
#import "DGImagePreviewVC.h"
#import "DGToast.h"

@interface ViewController ()<DGImagePickerManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *clipRectImageView;

@property (weak, nonatomic) IBOutlet UIImageView *clipCircleImageView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@property (nonatomic,strong) DGImagePickerManager *imagePickerMgr;

/** 1:裁剪矩形, 2:裁剪圆形, 3:选择图片(多选,2张) */
@property (nonatomic,assign) NSInteger clickBtnIndex;
@end

@implementation ViewController

-(DGImagePickerManager *)imagePickerMgr {
    if (!_imagePickerMgr) {
        _imagePickerMgr = [[DGImagePickerManager alloc]initWithMaxImageCount:5];
        _imagePickerMgr.delegate = self;
    }
    return _imagePickerMgr;
}

- (IBAction)clickClipRectSelecteImageBtn:(UIButton *)sender {
    self.clickBtnIndex = 1;
    self.imagePickerMgr.needRectangle = YES;
    self.imagePickerMgr.rectangleSize = CGSizeMake(120, 60);
    self.imagePickerMgr.needCircle = NO;
    [self.imagePickerMgr presentImagePickerByVC:self];
}


- (IBAction)clickClipCircleSelectImageBtn:(UIButton *)sender {
    self.clickBtnIndex = 2;
    self.imagePickerMgr.needRectangle = NO;
    self.imagePickerMgr.needCircle = YES;
    [self.imagePickerMgr presentImagePickerByVC:self];
}


- (IBAction)clickSelecteImageBtn:(UIButton *)sender {
    self.clickBtnIndex= 3;
    self.imagePickerMgr.needRectangle = NO;
    self.imagePickerMgr.needCircle = NO;
    self.imagePickerMgr.maxImageCount = 2;
    [self.imagePickerMgr presentImagePickerByVC:self];
}


- (IBAction)clickPreviewSelectedImagsBtn:(UIButton *)sender {
    
    //1.整理要预览的imageArr
    NSMutableArray *imageArr = [NSMutableArray array];
    if (self.clipRectImageView.image) {
        [imageArr addObject:self.clipRectImageView.image];
    }
    
    if (self.clipCircleImageView.image) {
        [imageArr addObject:self.clipCircleImageView.image];
    }
    
    if (self.imageView1.image) {
        [imageArr addObject:self.imageView1.image];
    }
    
    if (self.imageView2.image) {
        [imageArr addObject:self.imageView2.image];
    }
    
    //没图,不能看
    if (imageArr.count < 1) {
        [DGToast showMsg:@"不选图片怎么预览?" duration:2.0];
        return ;
    }
    //2.跳转
    DGImagePreviewVC *previewVC = [[DGImagePreviewVC alloc]init];
    previewVC.isAssetPreview = NO;
    [previewVC setPreviewImages:imageArr defaultIndex:1];
    [self presentViewController:previewVC animated:YES completion:nil];
}



#pragma mark DGImagePickerManagerDelegate
-(void)manager:(DGImagePickerManager *)mgr didSlectedImages:(NSArray<UIImage *> *)seletedImages {
    
    if (self.clickBtnIndex == 1) {
        self.clipRectImageView.image = seletedImages.firstObject;
    }else if(self.clickBtnIndex == 2){
        self.clipCircleImageView.image = seletedImages.firstObject;
    }else if (self.clickBtnIndex == 3){
        self.imageView1.image = seletedImages.firstObject;
        self.imageView2.image = seletedImages.lastObject;//selectedImages[1]写法不妥,因为是最多选2张,不一定选2张
    }

}


@end
