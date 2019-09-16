//
//  DGSelectImgView.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import "DGCheckmarkView.h"
#import "DGIP_Header.h"

@implementation DGCheckmarkView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.isSelected = NO ;
    }
    return self;
}

//- (CGSize)sizeThatFits:(CGSize)size {
//    return CGSizeMake(24.0, 24.0);
//}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(self.isSelected){
        
        //1.填充背景
        const CGFloat *components = CGColorGetComponents(DGIP_COLOR_NAVI.CGColor);
        const CGFloat a = CGColorGetAlpha(DGIP_COLOR_NAVI.CGColor);
        
        CGContextSetRGBFillColor(context, components[0], components[1], components[2], a);
        CGContextFillEllipseInRect(context, self.bounds);
        
        //2.中间对号
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetLineWidth(context, 1.5);
        CGContextMoveToPoint(context, 6.0, 12.0);
        CGContextAddLineToPoint(context, 10.0, 16.0);
        CGContextAddLineToPoint(context, 18.0, 8.0);
        CGContextStrokePath(context);
    }
    
    //3.外围圆圈
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, 1.0, 1.0));
}


#pragma mark - checkmarkImage
/** 未选中状态,对应的image */
+(UIImage *)imageForDefault {
    
    return [DGCheckmarkView checkmarkImageWithColor:nil bgColor:nil hasCircle:YES];
}

/** 选中状态,对应的image */
+(UIImage *)imageForSelected:(UIColor *)bgColor {
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    return [DGCheckmarkView checkmarkImageWithColor:color bgColor:bgColor hasCircle:YES];
}

/** 对勾image (没圈,透明底,color对勾)*/
+(UIImage *)checkmarkImage:(UIColor *)color{
    return [DGCheckmarkView checkmarkImageWithColor:color bgColor:nil hasCircle:NO];
}

/** 对勾checkmarkImage
  @param color 对勾颜色
  @param bgColor 对勾颜色
  @param hasCircle 是否有圆圈(白色)
 
  @return checkmarkImage
 */
+(UIImage *)checkmarkImageWithColor:(UIColor *)color bgColor:(UIColor *)bgColor hasCircle:(BOOL)hasCircle {
    
    CGRect frame = CGRectMake(0, 0, 96, 96);
    //1.创建临时画布
    UIGraphicsBeginImageContext(frame.size);
    
    //2.获取context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //3.填充背景
    if (bgColor) {
        const CGFloat *components = CGColorGetComponents(bgColor.CGColor);
        const CGFloat a = CGColorGetAlpha(bgColor.CGColor);
        CGContextSetRGBFillColor(context, components[0], components[1], components[2], a);
        CGContextFillEllipseInRect(context, frame);
    }
    
    //3.中间对号
    if (color) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        const CGFloat a = CGColorGetAlpha(color.CGColor);
        CGContextSetRGBStrokeColor(context, components[0], components[1], components[2], a);
        CGContextSetLineWidth(context, 6);
        CGContextMoveToPoint(context, 24.0, 48.0);
        CGContextAddLineToPoint(context, 40.0, 64.0);
        CGContextAddLineToPoint(context, 72.0, 32.0);
        CGContextStrokePath(context);
    }
    
    //3.画圆圈
    if (hasCircle) {
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetLineWidth(context, 5);
        CGContextStrokeEllipseInRect(context, CGRectInset(frame, 3, 3));
    }
    
    //4.获取图片
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    
    //5.结束
    UIGraphicsEndImageContext();
    
    //6.return
    return newImg;
}

@end
