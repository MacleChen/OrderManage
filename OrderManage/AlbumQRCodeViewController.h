//
//  AlbumQRCodeViewController.h
//  OrderManage
//
//  Created by mac on 15/7/1.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AlbumQRCodeViewController : UIViewController

@property (nonatomic,strong) UIViewController *nextVC;

@property (nonatomic,strong) NSMutableArray        *groupArrays;
@property (nonatomic,strong) UIImageView           *litimgView;



- (IBAction)barBtnCancelClick:(UIBarButtonItem *)sender;

@end
