//
//  DGAssetsListCollectionViewCell.h
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface DGAssetsListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic,assign) BOOL checkmarkHidden;

/** 是否被选中 */
@property (nonatomic,assign) BOOL hasBeenSelected;

@end
