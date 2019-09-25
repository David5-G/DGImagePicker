//
//  DGImagePreviewVC.m
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//

#import "DGImagePreviewVC.h"
//view
#import "DGToast.h"
#import "DGCheckmarkView.h"
#import "DGImagePreviewCollectionCell.h"
//tool
#import "DGIP_Header.h"


static NSString *const cellId = @"DGImagePreviewCollectionCell";

#pragma mark - DGImagePreviewVC
@interface DGImagePreviewVC () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,weak) UICollectionView *collectionView;

@property (nonatomic,copy) NSArray <UIImage *>*imageArr;

/** 选中图片的个数 */
@property (nonatomic,assign) NSInteger selectCount;

/** 当前图片的index */
@property (nonatomic,assign) NSInteger currentIndex;

/** 索引显示label */
@property (nonatomic,strong) UILabel *indexLabel;

/** 确认完成button */
@property (nonatomic,strong) UIButton *confrimButton;

/** 控制选中的button */
@property (nonatomic,strong) UIButton *selectButton;

@end


@implementation DGImagePreviewVC

#pragma mark  - getter/setter
#pragma mark  lazy load
-(UILabel *)indexLabel {
    if (_indexLabel == nil) {
        //添加index标签
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.font = [UIFont systemFontOfSize:18.0];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.userInteractionEnabled = YES;
    }
    return _indexLabel;
}

- (UIButton *)selectButton {
    if (_selectButton == nil) {
        _selectButton = [[UIButton alloc]init];
        [_selectButton setImage:[DGCheckmarkView imageForDefault] forState:(UIControlStateNormal)];
        [_selectButton setImage:[DGCheckmarkView imageForSelected:DGIP_COLOR_CHECK_MARK_BG] forState:(UIControlStateSelected)];
        [_selectButton addTarget:self action:@selector(clickSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectButton;
}

- (UIButton *)confrimButton {
    if (_confrimButton == nil) {
        _confrimButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        _confrimButton.layer.cornerRadius = 4 ;
        _confrimButton.backgroundColor = [UIColor clearColor];
        [_confrimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confrimButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_confrimButton setTitle:@"完成" forState:UIControlStateNormal];
        [_confrimButton setBackgroundImage:[DGIPConfig dgipBundleImage:@"dgip_blueBg"] forState:UIControlStateNormal];
        [_confrimButton addTarget:self action:@selector(clickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _confrimButton;
}


#pragma mark  setter
- (void)setAssetArray:(NSArray *)assetArray {
    _assetArray = [assetArray copy];
    [self.confrimButton setTitle:[NSString stringWithFormat:@"完成(%zd)", assetArray.count] forState:UIControlStateNormal];
    _selectCount = assetArray.count;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    //1.改变index
    NSInteger totalCount = self.isAssetPreview ? self.assetArray.count : self.imageArr.count;
    self.indexLabel.text = [NSString stringWithFormat:@"%zd/%zd", self.currentIndex + 1, totalCount];
    
    //2.改变选中状态
    if (self.isAssetPreview) {
        ALAsset *model = [self.assetArray objectAtIndex:currentIndex];
        self.selectButton.selected = model.isSelected;
    }
}

#pragma mark  - life circle
-(instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    //如果是查看图片,滚动currentIndex对应的cell
    if (self.imageArr.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }else{
        self.currentIndex = 0;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark  - statusBar
-(BOOL)shouldAutorotate {
    return NO;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark  - UI
-(void)setupUI {
    [self setupCollectionView];
    [self setupTopView];
    
    //有AssetPreview才有bottomV
    if(self.isAssetPreview){
        [self setupBottomView];
    }
}

/** 设置CollectionView */
-(void)setupCollectionView {
    //1.flowLayout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));

    //2.创建collectionView
    UICollectionView *collectionV = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    self.collectionView = collectionV;
    [self.view addSubview:collectionV];
    
    //2.1 设置
    collectionV.backgroundColor = UIColor.whiteColor;
    collectionV.pagingEnabled = YES;
    collectionV.showsHorizontalScrollIndicator = NO;
    collectionV.bounces = NO;
    collectionV.delegate = self;
    collectionV.dataSource = self;
    [collectionV registerClass:[DGImagePreviewCollectionCell class] forCellWithReuseIdentifier:cellId];
}

/** 设置TopView */
- (void)setupTopView {
    //1.创建topV
    UIView *topV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DGIP_SCREEN_W, DGIP_STATUS_AND_NAVI_BAR_HEIGHT)];
    topV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    topV.userInteractionEnabled = YES;
    [self.view addSubview:topV];

    //2.title
    CGFloat indexLabelW = 80;
    CGFloat indexLabelX = (DGIP_SCREEN_W - indexLabelW)/2.0;
    self.indexLabel.frame = CGRectMake(indexLabelX, DGIP_STATUS_BAR_HEIGHT, indexLabelW, DGIP_NAVI_BAR_HEIGHT);
    [topV addSubview:self.indexLabel];

    
    //3.backBtn
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, DGIP_STATUS_BAR_HEIGHT, 40, DGIP_NAVI_BAR_HEIGHT)];
    [backBtn setImage:[DGIPConfig dgipBundleImage:@"dgip_navi_back"] forState:(UIControlStateNormal)];
    [backBtn addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [topV addSubview:backBtn];

    //4.是AssetPreview才有选中按钮
    if(self.isAssetPreview){
        CGFloat rightSpace = 10;
        CGFloat selectBtnW = DGIP_NAVI_BAR_HEIGHT;
        self.selectButton.frame = CGRectMake(DGIP_SCREEN_W - selectBtnW - rightSpace, DGIP_STATUS_BAR_HEIGHT, selectBtnW, selectBtnW);
        self.selectButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [topV addSubview:self.selectButton];
    }
}

/** 设置BottomView */
- (void)setupBottomView {
    //1.创建bottomV
    CGFloat bottomViewH = DGIP_NAVI_BAR_HEIGHT + DGIP_HOME_INDICATOR_HEIGHT;
    CGFloat bottomViewY = self.view.frame.size.height - bottomViewH;
    UIView *bottomV = [[UIView alloc] initWithFrame:CGRectMake(0, bottomViewY, DGIP_SCREEN_W, bottomViewH)];
    [self.view addSubview:bottomV];
    bottomV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    bottomV.userInteractionEnabled = YES;
    
    //1.确认按钮
    CGFloat btnW = 70;
    CGFloat btnH = 30;
    CGFloat btnRightSpace = 10;
    self.confrimButton.frame = CGRectMake(DGIP_SCREEN_W - btnW -btnRightSpace,(DGIP_NAVI_BAR_HEIGHT-btnH)/2.0 , btnW, btnH);
    [bottomV addSubview:self.confrimButton];
}

#pragma mark  - interaction
/** 点击返回按钮 */
- (void)clickBackButton:(UIButton *)sender {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/** 点击选中按钮 */
- (void)clickSelectedButton:(UIButton *)sender {

    ALAsset *currentAsset = self.assetArray[self.currentIndex];
    
    //1.改变选中状态
    sender.selected = !sender.selected;
    currentAsset.isSelected = sender.isSelected;
    
    //2. 改变选中数量
    self.selectCount += sender.selected ? 1 : (-1);
    [self.confrimButton setTitle:[NSString stringWithFormat:@"完成(%zd)", self.selectCount] forState:UIControlStateNormal];
    
    //3.回传 当前图片的选中状态
    
    if (self.selectBlock) {
        self.selectBlock(currentAsset, sender.selected);
    }
    
}

/** 点击确认按钮 */
- (void)clickConfirmButton:(UIButton *)sender {
    //调block
    self.finishBlock();
}

#pragma mark  - delegate
#pragma mark  collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //1.是AssetPreview
    if (self.isAssetPreview) {
        return self.assetArray.count;
    }
    
    //2.仅预览图片
    return self.imageArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.item;
    
    //1.获取cell
    DGImagePreviewCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blackColor];
    
    //2.是AssetPreview
    if (self.isAssetPreview) {
        ALAsset *model = self.assetArray[row];
        [ALAsset getorignalImage:model completion:^(UIImage *image) {
            cell.img = image;
        }];
        return cell;
    }
    
    //3.仅预览图片
    cell.img = self.imageArr[row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DGImagePreviewCollectionCell *curCell = (DGImagePreviewCollectionCell *)cell;
    [curCell.imageScrollView setZoomScale:1.0 animated:NO];
    [curCell.imageScrollView setNeedsLayout];
    [curCell.imageScrollView layoutIfNeeded];
}



#pragma mark  scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = (scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width;
    if (index < 0) return;

    self.currentIndex = index;
}


#pragma mark - 仅预览图片
-(void)setPreviewImages:(NSArray<UIImage *> *)imageArr defaultIndex:(NSUInteger)defaultIndex{
    self.imageArr = imageArr;
    self.currentIndex = imageArr.count > defaultIndex ? defaultIndex : 0;
}

@end
