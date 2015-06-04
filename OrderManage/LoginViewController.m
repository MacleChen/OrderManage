//
//  LoginViewController.m
//  OrderManage
//
//  Created by mac on 15/5/29.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "LoginViewController.h"

#define loginSecUrl @"emp!login.action?"//emp.empname=gzcy&emp.emppwd=123456"

// 登陆成功后获取会员详细信息
NSDictionary *dictLogin = nil;

@interface LoginViewController () <UITextFieldDelegate> {
    float _viewLoginInitY;
}

@end

@implementation LoginViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _viewLoginInitY = self.viewLogin.frame.origin.y;
    self.lbInfo.text = @"";
    
    // 设置view的手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleBackgroundTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    /* 设置一些属性信息  */
    // 设置一次性清除x按钮
    self.edtName.clearButtonMode = UITextFieldViewModeAlways;
    self.edtPwd.clearButtonMode = UITextFieldViewModeAlways;
    
    // 设置键盘类型
    self.edtName.keyboardType = UIKeyboardTypeNamePhonePad;
    self.edtPwd.keyboardType = UIKeyboardTypeNumberPad;
    self.edtPwd.secureTextEntry = YES;   // 设置为安全输入
    
    // 限制输入textfield的字符串的长度

    // 设置第一响应者
    [self.edtName becomeFirstResponder];
    
    // 设置代理
    self.edtName.delegate = self;
    self.edtPwd.delegate = self;
    
    // 检测键盘的出现与隐藏
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
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
//emp!login.action?emp.empname=gzcy&emp.emppwd=123456


// 测试按钮响应方法
- (IBAction)btnTest:(UIButton *)sender {
    // 跳转到主页面
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];  // 根据storyboardID获取视图
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];   // 立即效果
    
    [self presentViewController: viewController animated:YES completion:nil];

}

- (IBAction)btnClick:(UIButton *)sender {
    
    // 网络数据请求 --- 登录数据包
    NSString *strUrl = [[NSString alloc] initWithFormat:@"%@emp!login.action?emp.empname=%@&emp.emppwd=%@", WEBBASEURL, self.edtName.text, self.edtPwd.text];
    
    //[HttpRequest HttpAFNetworkingRequestWithURL:strUrl];
    
    
    NSURL *url = [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    从URL获取json数据
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *oper = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [oper setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *html = operation.responseString;
        NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
        id dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
        NSLog(@"aaaa%@", [NSThread currentThread]);
        NSLog(@"获取到的数据为：%@",dict);
        NSString *statCode = [dict objectForKey:statusCdoe];
        if ([statCode intValue] == 200) {
            self.lbInfo.text = loginSuccess;
            
            // 获取登录数据
            dictLogin = [dict objectForKey:message];
            
            // 跳转到主页面
            //    [self performSegueWithIdentifier:@"Main" sender:nil];
            UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];  // 根据storyboardID获取视图
            //[viewController setModalTransitionStyle:UIModalTransitionStylePartialCurl];  // 翻书页的效果
            //[viewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal]; // 左右翻滚页
            [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];   // 立即效果
            //[viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];    // 由下向上
            
            [self presentViewController: viewController animated:YES completion:^{
                self.lbInfo.text = @"";
                // 辞退上一个界面
                
            }];

        } else {
            self.lbInfo.text = loginInfoErr;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"bbbb%@", [NSThread currentThread]);
        NSLog(@"发生错误！%@",error);
        self.lbInfo.text = ConnectException;
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:oper];
}

#pragma mark - textfield 的代理方法的实现
#pragma mark  当输入框开始编辑时调用方法
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.btnLogin.enabled = NO;
    self.lbInfo.text = @"";
    
    return YES;
}

#pragma mark 编辑时，实时调用的方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (([string isEqual:@""] && textField.text.length <= 1) || [self.edtName.text isEqual:@""] || [self.edtPwd.text isEqual:@""]) {
        self.btnLogin.enabled = NO;
    } else {
        self.btnLogin.enabled = YES;
    }
    
    return YES;
}


#pragma mark 清除 textField时，设置登录按钮为 false
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.btnLogin.enabled = NO;
    
    return YES;
}

#pragma mark - 检测键盘的调出，退出
#pragma mark 检测键盘的调出
- (void)keyboardDidShow:(NSNotification *)aNotfication {
   
    // 获取键盘的高度
    NSDictionary *userInfo = [aNotfication userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSLog(@"%f, %f, %f, %f", keyboardRect.origin.x, keyboardRect.origin.y, keyboardRect.size.width, keyboardRect.size.height);
}

#pragma mark 检测键盘的退出
- (void)keyboardDidHide:(NSNotification *)aNotfication {
    NSLog(@"exit键盘--- %f", self.viewLogin.frame.origin.y);
//    CGRect viewFrame = self.viewLogin.frame;
//    viewFrame.origin.y = _viewLoginInitY;
//    [self setAnimatForViewFordur:0.3 position:viewFrame];
    
}

#pragma mark 点击背景时，退出键盘
-(void)HandleBackgroundTap:(UITapGestureRecognizer *)sender {
    //[self keyboardDidHide];
    [self.view endEditing:YES];
}

- (void)setAnimatForViewFordur:(float)DurTime position:(CGRect)viewFrame {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:DurTime];
    
    self.viewLogin.frame = viewFrame;
    
    [UIView commitAnimations];
}

@end
