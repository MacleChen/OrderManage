//
//  MainViewController.m
//  OrderManage
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "MainViewController.h"
#import "viewOtherDeal.h"

#define SECTION_PAGE_COUNT 1  // 页数
#define CELL_IN_SECTION_COUNT 9 // 每页显示的cell数

@interface MainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    float _mainScreenWidth;
    float _mainScreenHeight;
    
    float _collectionPageIndex;  // 页数
    float _cellGapX;  // 横向间距
    float _cellGapY;  // 竖向间距
    CGSize _cellSize; // cell的长宽
    int _RowIncellCount;  // 每一行显示的cell数量
    
    UIPageControl *_pageControl;  // // 分页条码指示控制器
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.barBtnItem = [[UIBarButtonItem alloc] init];
//    self.barBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(barBtnItemClick:)];
    
    // 获取屏幕的宽高
    _mainScreenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    _mainScreenHeight = [UIScreen mainScreen].applicationFrame.size.height + 20;
    
    // 设置cell的大小和间距
    _RowIncellCount = 3;
    _cellGapX = 10;
    _cellGapY = 15;
    _cellSize = CGSizeMake((_mainScreenWidth -(_RowIncellCount + 1) * _cellGapX) / _RowIncellCount, (_mainScreenWidth -(_RowIncellCount + 1) * _cellGapX) / _RowIncellCount);
    
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = _cellSize;
    //flowLayout.sectionInset = UIEdgeInsetsMake(20, 10, 0, 0);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.collectionview =[[UICollectionView alloc] initWithFrame:CGRectMake(0, MenuAddNotificationHeight, _mainScreenWidth, _mainScreenHeight - 108) collectionViewLayout:flowLayout];
    self.collectionview.dataSource=self;
    self.collectionview.delegate=self;
    self.collectionview.pagingEnabled = YES;
    self.collectionview.alwaysBounceHorizontal= YES;
    self.collectionview.showsHorizontalScrollIndicator = NO;
    self.collectionview.showsVerticalScrollIndicator = NO;
    [self.collectionview setBackgroundColor:[UIColor whiteColor]];
    
    //注册Cell，必须要有
    [self.collectionview registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    self.collectionview.contentSize = CGSizeMake(_mainScreenWidth * SECTION_PAGE_COUNT, _mainScreenHeight - 108);
    
    [self.view addSubview:self.collectionview];
    
    // 设置分页点
    _pageControl = [[UIPageControl alloc]init];
    // pageControl分页指示条的中心点在底部中间
    _pageControl.numberOfPages = SECTION_PAGE_COUNT; //这个最重要
    _pageControl.center = CGPointMake(_mainScreenWidth / 2, _mainScreenHeight / 6 * 5);
    _pageControl.bounds = CGRectMake(0, 0, 150, 15);
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = ColorMainSystem;
    _pageControl.enabled = NO; //取消其默认的点击行为
    [self.view addSubview:_pageControl];
    
    // 存储数据源
    self.muArrayData = [NSMutableArray array];
    for(int i = 0; i < SECTION_PAGE_COUNT; i++) {
        NSMutableArray *muarrayTemp = [NSMutableArray array];
        for(int j = 0; j < CELL_IN_SECTION_COUNT; j++) {
            UIImage *imageTemp = [UIImage imageNamed:[NSString stringWithFormat:@"mainViewCell_%d_%d.png", i, j + 1]];
            
            if(imageTemp == nil) continue;   // 为空时不保存
            [muarrayTemp addObject:imageTemp];
            //[muarrayTemp addObject:[viewOtherDeal scaleToSize:imageTemp size:CGSizeMake(90, 90)]];
        }
        [self.muArrayData addObject:muarrayTemp];
    }
}

#pragma mark -- UICollectionViewDataSource
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.muArrayData.count;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *muarrayTemp = self.muArrayData[section];
    return muarrayTemp.count;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // 设置随机色
    //cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
    cell.backgroundView = [[UIImageView alloc] initWithImage:self.muArrayData[indexPath.section][indexPath.row]];
    cell.hidden = NO;
    // 设置cell的位置和大小
    CGRect cellRect = cell.frame;
    cellRect.size = _cellSize;
    
    
    cellRect.origin.x = (indexPath.row  % _RowIncellCount) * (cellRect.size.width + _cellGapX) + _cellGapX + _mainScreenWidth * indexPath.section;
    cellRect.origin.y = (indexPath.row  / _RowIncellCount) * (cellRect.size.height + _cellGapY) + _cellGapY;
    
    cell.frame = cellRect;
    
    return cell;
}



#pragma mark --UICollectionViewDelegateFlowLayout

////定义每个Item 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(90, 90);
//}
//
////定义每个UICollectionView 的 margin
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(10, 10, 10, 10);
//}


#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取对应的cell
//    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //临时改变个颜色，看好，只是临时改变的。如果要永久改变，可以先改数据源，然后在cellForItemAtIndexPath中控制。（和UITableView差不多吧！O(∩_∩)O~）
//    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
//    imageview.backgroundColor = [UIColor lightGrayColor];
//    cell.selectedBackgroundView = imageview;
    //切换到下一个界面  --- push
    NSString *strIdentifier = [NSString stringWithFormat:@"mainViewCell_%ld_%ld", (long)indexPath.section, (long)indexPath.row + 1];
    UIViewController  *viewControl = [self.storyboard instantiateViewControllerWithIdentifier:strIdentifier];
    [self.navigationController pushViewController:viewControl animated:YES];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - scrollview 代理方法的实现
#pragma mark 当scrollview移动时，实时调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    _collectionPageIndex = self.collectionview.contentOffset.x / _mainScreenWidth;
//    NSLog(@"%.2f", self.collectionview.contentOffset.x);
//    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControl.currentPage = self.collectionview.contentOffset.x / _mainScreenWidth;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)barBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
