//
//  ALAsset+DGSelectImage.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@interface ALAsset (DGSelectImage)

@property (nonatomic, assign) BOOL isSelected;

+ (void)getorignalImage:(ALAsset *)assert completion:(void (^)(UIImage *))returnImage;

@end
