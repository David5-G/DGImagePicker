//
//  DGSelectImgView.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGCheckmarkView : UIView

/** 是否被选中 */
@property (nonatomic,assign) BOOL isSelected;


#pragma mark - checkmarkImage
/** 未选中状态,对应的image (白圈,透明底)*/
+(UIImage *)imageForDefault;

/** 选中状态,对应的image (白圈,bgColor底,白对勾)*/
+(UIImage *)imageForSelected:(UIColor *)bgColor;

/** 对勾image (没圈,透明底,color对勾)*/
+(UIImage *)checkmarkImage:(UIColor *)color;


/** 对勾checkmarkImage
 @param color 对勾颜色
 @param bgColor 对勾颜色
 @param hasCircle 是否有圆圈(白色)
 
 @return checkmarkImage
 */
+(UIImage *)checkmarkImageWithColor:(UIColor *)color bgColor:(UIColor *)bgColor hasCircle:(BOOL)hasCircle;

@end
