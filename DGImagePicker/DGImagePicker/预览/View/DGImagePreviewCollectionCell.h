//
//  DGImagePreviewCollectionCell.h
//  kk_buluo
//
//  Created by david on 2019/9/24.
//  Copyright © 2019 yaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGZoomScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DGImagePreviewCollectionCell : UICollectionViewCell

@property (nonatomic,weak)DGZoomScrollView *imageScrollView;
@property (nonatomic,strong) UIImage *img;

@end

NS_ASSUME_NONNULL_END
