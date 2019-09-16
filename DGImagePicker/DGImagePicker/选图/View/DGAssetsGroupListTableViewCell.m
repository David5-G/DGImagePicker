//
//  DGAssetsGroupListTableViewCell.m
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//


#import "DGAssetsGroupListTableViewCell.h"
#import "DGIP_Header.h"
#import "DGCheckmarkView.h"

@interface DGAssetsGroupListTableViewCell()

@end


@implementation DGAssetsGroupListTableViewCell
#pragma mark - lazy load
-(UIImageView *)iconView{
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}
-(UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

-(UIButton *)selectBtn{
    if (_selectBtn == nil) {
        _selectBtn = [[UIButton alloc]init];
        _selectBtn.userInteractionEnabled = NO;
        [_selectBtn setBackgroundImage:[DGCheckmarkView checkmarkImage:DGIP_COLOR_NAVI] forState:UIControlStateNormal];
    }
    return _selectBtn;
}
-(UIView *)grayLine {
    if (_grayLine == nil) {
        _grayLine = [[UIView alloc]init];
        _grayLine.backgroundColor = DGIP_COLOR_GRAY;
    }
    return _grayLine;
}


#pragma mark - life circle
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    //1.icon
    CGFloat iconViewW = 38;
    CGFloat iconViewX = 15;
    self.iconView.frame = CGRectMake(iconViewX, (h-iconViewW)/2.0, iconViewW, iconViewW);
    
    //2.selectBtn
    CGFloat selectBtnW = 35;
    CGFloat selectBtnRightSpace = 14;
    self.selectBtn.frame = CGRectMake(w-selectBtnW-selectBtnRightSpace, (h-selectBtnW)/2.0, selectBtnW, selectBtnW);
    
    //3.titleL
    CGFloat titleLableX = CGRectGetMaxX(self.iconView.frame) + 10;
    CGFloat titleLabelW = w - titleLableX - selectBtnW - selectBtnRightSpace;
    CGFloat tittleLabelH = 20;
    self.titleLabel.frame = CGRectMake(titleLableX, (h-tittleLabelH)/2.0, titleLabelW, tittleLabelH);
    
    //4.grayLine
    self.grayLine.frame = CGRectMake(15, h-1, w-15-10, 1);
}

#pragma mark - UI
-(void)setupSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = UIColor.clearColor;
    
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.grayLine];
}

#pragma mark - setter
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
