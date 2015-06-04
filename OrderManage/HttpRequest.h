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
#define WEBLoginAction @"emp!login.action?"
#define WEBFindCardAction @"newcard!findcard.action?"
#define WEBNewCardNumAction @"newcard!cardnum.action?"


#define statusCdoe @"statusCode"
#define message    @"message"
#define ConnectException @"网络异常"

@interface HttpRequest : NSObject

+ (NSData *)HttpsyncRequestPostWithURL:(NSString *)stURL;
+ (NSData *)HttpAFNetworkingRequestWithURL:(NSString *)stURL;
+ (id)HttpAFNetworkingRequestWithURL_Two:(NSString *)strURL;

@end
