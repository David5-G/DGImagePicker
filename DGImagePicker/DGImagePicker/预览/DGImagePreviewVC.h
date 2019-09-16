//
//  DGImagePreviewVC.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAsset+DGSelectImage.h"

@interface DGImagePreviewVC : UIViewController

/** 是否是 相册asset预览 */
@property (nonatomic,assign) BOOL isAssetPreview;

#pragma mark - 相册选图的预览
/** asset数组 */
@property (nonatomic,strong) NSArray *assetArray;

/** 选中/取消选中 block */
@property (nonatomic,copy) void(^selectBlock)(ALAsset *curModel, BOOL isSelect);

/** 完成block */
@property (nonatomic,copy) void(^finishBlock)(void);


#pragma mark - 仅预览图片
-(void)setPreviewImages:(NSArray <UIImage *>*)imageArr defaultIndex:(NSUInteger)defaultIndex;

@end






