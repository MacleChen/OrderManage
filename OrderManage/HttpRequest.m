//
//  HttpRequest.m
//  OrderManage
//
//  Created by mac on 15/5/29.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "HttpRequest.h"

@implementation HttpRequest {

}


+ (NSData *)HttpsyncRequestPostWithURL:(NSString *)stURL {
    //@"http://180.97.81.151/cshop/emp!login.action?emp.empname=gzcy&emp.emppwd=123456"
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:stURL];
    
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str = @"type=focus-c";//设置参数
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    return received;
}

+ (NSData *)HttpAFNetworkingRequestWithURL:(NSString *)stURL {
    NSURL *url = [NSURL URLWithString:[stURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [[NSData alloc] init];
    //    从URL获取json数据
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *oper = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [oper setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *html = operation.responseString;
        NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
        id dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
        NSLog(@"aaaa%@", [NSThread currentThread]);
        NSLog(@"获取到的数据为：%@",dict);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:oper];
    
     return nil;
}



@end
