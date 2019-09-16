//
//  DGImageClipVC.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGImageClipVC : UIViewController

/**
  @param image  要裁剪的图片
  @param maxScale 最大缩放比例(放大)
  @param rectangleSize  要裁剪的尺寸
  @param needCircle  是否是圆形(是圆形,就会忽略rectangleSize)
 */
- (id)initWithImage:(UIImage *)image maxScale:(CGFloat)maxScale rectangleSize:(CGSize)rectangleSize needCircle:(BOOL)needCircle;

@property(nonatomic ,copy) void(^finishhandle)(DGImageClipVC *controller, UIImage *image);

@end

