//
//  DGIPConfig.h
//  DGImagePicker
//
//  Created by david on 2019/9/17.
//  Copyright © 2019 david. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DGIPConfig : NSObject

/** 获取LoginKit.bundle里的图片 */
+(UIImage *)dgipBundleImage:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
