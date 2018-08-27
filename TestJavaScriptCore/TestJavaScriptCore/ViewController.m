//
//  ViewController.m
//  TestJavaScriptCore
//
//  Created by tantan fan on 2018/8/27.
//  Copyright © 2018年 tantan fan. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (weak, nonatomic) JSContext *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc]init];
    _webView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Test.html" ofType:nil];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
    // 创建按钮
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2, 200, 50);
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 setTitle:@"OC 调用无参 JS" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(function1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2 + 100, 200, 50);
    btn2.backgroundColor = [UIColor orangeColor];
    [btn2 setTitle:@"OC 调用 JS（传参）" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(function2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    
}

// MARK: - OC 调用 JS
- (void)function1 {
    NSLog(@"OC 调用无参 JS");
    
    [_webView stringByEvaluatingJavaScriptFromString:@"aaa()"];
}

- (void)function2 {
    NSLog(@"OC 调用 JS（传参）");
    
    NSString *name = @"I love you";
    NSInteger num = 520;
    
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"bbb('%@','%ld');", name, num]];
}

// OC中直接写JS代码
- (void)testOCUseJS {
    // 准备执行的 JS 代码
    NSString *jsAlert = @"alert('test OC Use JS')";
    
    [_context evaluateScript:jsAlert];
}

// MARK: - JS 调用 OC
- (void)method1 {
    NSLog(@"JS调用了无参数OC方法");
}

- (void)method2:(NSString *)str1 and:(NSString *)str2 {
    NSLog(@"JS调用了有参数返回给OC，参数为%@%@",str1,str2);
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"开始响应请求时触发");
    
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"开始加载网页");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"网页加载完毕");
    // 获取 JS 运行环境
    _context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // html 调用无参数 OC
    _context[@"test1"] = ^() {
        [self method1];
    };
    
    // html 调用有参数传过来 OC
    _context[@"test2"] = ^() {
      
        // 传过来的参数
        NSArray *args = [JSContext currentArguments];
        
        for (id objc in args) {
            NSLog(@"JS 传过来的参数 %@", objc);
        }
        
        NSString *name = args[0];
        NSString *str = args[1];
        
        [self method2:name and:str];
    };
    
    
    //OC调用JS方法
    [self testOCUseJS];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"网页加载出错");
}


@end
