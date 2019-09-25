//
//  DGIPConfig.m
//  DGImagePicker
//
//  Created by david on 2019/9/17.
//  Copyright © 2019 david. All rights reserved.
//

#import "DGIPConfig.h"

@implementation DGIPConfig


+(UIImage *)dgipBundleImage:(NSString *)name {
    //    NSString *imgName = [NSString stringWithFormat:@"xxx.bundle/images/%@",name];
    //    return [UIImage imageNamed:imgName];
    
    //1.bundlePath
    NSBundle *lkBundle = [DGIPConfig getDgipBundle];
    
    //2.imagePath
    NSString *imgName = name;
    if ([UIScreen mainScreen].scale == 3.0) {
        imgName = [name stringByAppendingString:@"@3x"];
    }else {
        imgName = [name stringByAppendingString:@"@2x"];
    }
    NSString *imgPath = [lkBundle pathForResource:imgName ofType:@"png" inDirectory:@"images"];
    
    //3.return
    return [UIImage imageWithContentsOfFile:imgPath];
}


+(NSBundle *)getDgipBundle {
    NSString *nameStr = @"DGIP";
    
    //1.mainPath
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    //NSString * mainBundle = [NSBundle mainBundle];
    
    //2.如果是在项目里
    NSString *bPath = [mainBundle pathForResource:nameStr ofType:@"bundle"];
    
    //3.如果是用pod导入
    if (!bPath) {
        NSString *sdkPath = [mainBundle pathForResource:@"DGImagePicker" ofType:@"bundle"];
        NSBundle* sdkBundle = [NSBundle bundleWithPath:sdkPath];
        bPath = [sdkBundle pathForResource:nameStr ofType:@"bundle"];
    }
    
    //4.return
    return [NSBundle bundleWithPath:bPath];
}
@end
