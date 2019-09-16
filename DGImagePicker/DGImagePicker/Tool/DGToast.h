//
//  DGToast.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGToast : UIView

@property (nonatomic, strong, readonly) UILabel *textLabel;

+ (instancetype)sharedToast;
+ (instancetype)makeText:(NSString *)text;
- (void)dismiss;
- (void)show;
- (void)showWithOffset:(CGFloat)offsetY;
- (void)showWithOffset:(CGFloat)offsetY duration:(CGFloat)duration;

#pragma mark - convenience
+ (void)showMsg:(NSString *)msg;
+ (void)showMsg:(NSString *)msg duration:(CGFloat)duration;

@end
