//
//  DGImagePickerManager.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DGImagePickerManager;

@protocol DGImagePickerManagerDelegate <NSObject>
-(void)manager:(DGImagePickerManager *)mgr didSlectedImages:(NSArray<UIImage *> *)seletedImages;
@end


@interface DGImagePickerManager : NSObject

-(instancetype)initWithMaxImageCount:(NSInteger)maxImageCount;

/** 最大图片数 */
@property (nonatomic,assign) NSInteger maxImageCount;

/** 代理 */
@property(nonatomic,weak) id<DGImagePickerManagerDelegate> delegate;

/** 跳转显示 ImagePicker */
- (void)presentImagePickerByVC:(UIViewController *)presentVC;


#pragma mark - 裁剪

/** 需要 切成圆形图 */
@property (nonatomic,assign) BOOL needCircle;

/** 需要 切成矩形图 */
@property (nonatomic,assign) BOOL needRectangle;

/** 矩形的size */
@property (nonatomic,assign) CGSize rectangleSize;



#pragma mark - block
@property (nonatomic, copy) void(^finishBlock)(NSArray<UIImage *> *seletedImages);

@end
