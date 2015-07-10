//
//  MainViewController.h
//  OrderManage
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "LoginViewController.h"

@interface MainViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *muArrayData; // 数据源

@property (strong, nonatomic) IBOutlet UIBarButtonItem *barBtnItem;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionview;



- (IBAction)barBtnClick:(id)sender;
@end
