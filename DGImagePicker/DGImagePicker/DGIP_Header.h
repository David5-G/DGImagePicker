//
//  DGIP_Header.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#ifndef DGIP_Header_h
#define DGIP_Header_h


//---------------------------------------------------
#pragma mark - color
/** rgb颜色*/
#define DGIP_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define DGIP_RGB(r,g,b)    DGIP_RGBA(r,g,b,1.0f)

#define DGIP_COLOR_NAVI     DGIP_RGBA(42, 62, 255, 1)
#define DGIP_COLOR_GRAY     DGIP_RGBA(202, 203, 204, 1)

//---------------------------------------------------
#pragma mark - 尺寸(宽高)

/** 获取屏幕 宽度、高度*/
#define DGIP_SCREEN_W       ([UIScreen mainScreen].bounds.size.width)
#define DGIP_SCREEN_H       ([UIScreen mainScreen].bounds.size.height)


#define DGIP_STATUS_BAR_HEIGHT (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))

#define DGIP_NAVI_BAR_HEIGHT             (44.f)
#define DGIP_STATUS_AND_NAVI_BAR_HEIGHT  (DGIP_STATUS_BAR_HEIGHT + DGIP_NAVI_BAR_HEIGHT)
#define DGIP_TAB_BAR_HEIGHT             (DGIP_iPhoneX ? (49.f+34.f) : 49.f)
#define DGIP_HOME_INDICATOR_HEIGHT      (DGIP_iPhoneX ? 34.f : 0.f)

//---------------------------------------------------

// 判断iPhone
#define DGIP_iPhone4  (MAX(DGIP_SCREEN_W, DGIP_SCREEN_H) == 480)
#define DGIP_iPhone5  (MAX(DGIP_SCREEN_W, DGIP_SCREEN_H) == 568)
#define DGIP_iPhone6  (MAX(DGIP_SCREEN_W, DGIP_SCREEN_H) == 667)
#define DGIP_iPhone6P (MAX(DGIP_SCREEN_W, DGIP_SCREEN_H) == 736)
#define DGIP_iPhoneX  (MAX(DGIP_SCREEN_W, DGIP_SCREEN_H) >= 812)


//---------------------------------------------------
#pragma mark - strong/weak
#define DGIP_WeakS(weakSelf)    __weak __typeof(&*self)weakSelf = self;
#define DGIP_StrongS(strongSelf)  __strong __typeof(&*weakSelf)strongSelf = weakSelf;


//---------------------------------------------------
#pragma mark - log
#ifdef DEBUG
#   define DGIP_Log(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DGIP_Log(...)
#endif

#endif /* DGIP_Header_h */
