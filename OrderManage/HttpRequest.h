//
//  HttpRequest.h
//  OrderManage
//
//  Created by mac on 15/5/29.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"

#define WEBBASEURL @"http://180.97.81.151/cshop/"
#define WEBBASEURLTest @"http://180.97.69.100/cshop_jspay/"

#define WEBLoginAction @"emp!login.action?"
#define WEBFindCardAction @"newcard!findcard.action?"
#define WEBNewCardNumAction @"newcard!cardnum.action?"
#define WEBCustomerAddAction @"customer!add.action?"


#define statusCdoe @"statusCode"
#define message    @"message"
#define ConnectException @"网络繁忙，请稍后重试！"

@interface HttpRequest : NSObject

+ (NSData *)HttpsyncRequestPostWithURL:(NSString *)stURL;
+ (NSData *)HttpAFNetworkingRequestWithURL:(NSString *)stURL;
+ (id)HttpAFNetworkingRequestWithURL_Two:(NSString *)strURL parameters:(id)param;

@end
