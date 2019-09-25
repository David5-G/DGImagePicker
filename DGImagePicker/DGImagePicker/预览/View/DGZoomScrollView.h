//
//  DGZoomScrollView.h
//  kk_buluo
//
//  Created by david on 2019/9/24.
//  Copyright © 2019 yaya. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DGZoomScrollView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic,weak) UIImageView *imageView;
@property (nonatomic,assign)CGFloat currentScale;

@end

NS_ASSUME_NONNULL_END
