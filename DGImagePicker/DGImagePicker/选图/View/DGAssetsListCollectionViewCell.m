//
//  DGAssetsListCollectionViewCell.m
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import "DGAssetsListCollectionViewCell.h"
#import "DGCheckmarkView.h"

@interface DGAssetsListCollectionViewCell ()
/** imgView */
@property (nonatomic, weak) UIImageView *imgView;

@property (nonatomic, weak) DGCheckmarkView *checkmarkView;

@end


@implementation DGAssetsListCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

#pragma mark - UI
-(void)setupSubViews {
    //1.imageView
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imgView = imgV;
    imgV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:imgV];
    
    //2.checkMarkView
    DGCheckmarkView *checkmarkV = [[DGCheckmarkView alloc] initWithFrame:CGRectMake(self.bounds.size.width - (4.0 + 24.0),  4.0 , 24.0, 24.0)];
    self.checkmarkView = checkmarkV;
    [self.contentView addSubview:checkmarkV];
    
    checkmarkV.autoresizingMask = UIViewAutoresizingNone;
    checkmarkV.layer.shadowColor = [[UIColor grayColor] CGColor];
    checkmarkV.layer.shadowOffset = CGSizeMake(0, 0);
    checkmarkV.layer.shadowOpacity = 0.6;
    checkmarkV.layer.shadowRadius = 2.0;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.imgView.frame = self.bounds;
    self.checkmarkView.frame = CGRectMake(self.bounds.size.width-24-4, 4, 24, 24);
}

#pragma mark setter
-(void)setAsset:(ALAsset *)asset {
    _asset = asset;
    
    CGImageRef thumbnailImageRef = [asset thumbnail];
    
    if (thumbnailImageRef) {
        self.imgView.image = [UIImage imageWithCGImage:thumbnailImageRef];
    } else {
        self.imgView.image = [self getBlankImage];
    }
}
-(void)setHasBeenSelected:(BOOL)hasBeenSelected {
    _hasBeenSelected = hasBeenSelected;
    
    if (!self.checkmarkHidden) {
        self.checkmarkView.isSelected = hasBeenSelected;
        [self.checkmarkView setNeedsDisplay];
    }
}

-(void)setCheckmarkHidden:(BOOL)checkmarkHidden {
    _checkmarkHidden = checkmarkHidden;
    self.checkmarkView.hidden = checkmarkHidden;
}

#pragma mark - 
- (UIImage *)getBlankImage {
    
    CGSize size = CGSizeMake(100.0, 100.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [[UIColor colorWithWhite:(240.0 / 255.0) alpha:1.0] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *blankImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return blankImg;
}

@end
