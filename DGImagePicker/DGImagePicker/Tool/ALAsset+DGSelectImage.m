//
//  ALAsset+DGSelectImage.m
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//
#import <objc/runtime.h>
#import "ALAsset+DGSelectImage.h"
static const char *select_key = "select_key";

@implementation ALAsset (DGSelectImage)

- (BOOL)isSelected {
    return [objc_getAssociatedObject(self, select_key) boolValue];
}

- (void)setIsSelected:(BOOL)isSelected {
    objc_setAssociatedObject(self, select_key, [NSNumber numberWithBool:isSelected], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)getorignalImage:(ALAsset *)assert completion:(void (^)(UIImage *))returnImage {
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib assetForURL:assert.defaultRepresentation.url resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = asset.defaultRepresentation;
        //CGImageRef imageRef = rep.fullResolutionImage;
        CGImageRef imageRef = rep.fullScreenImage;
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:rep.scale orientation:UIImageOrientationUp];
        
        if (image) {
            returnImage(image);
        }
        
    }failureBlock:^(NSError *error){
        
    }];
}
@end
