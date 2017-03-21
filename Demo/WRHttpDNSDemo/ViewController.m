//
//  ViewController.m
//  WRHttpDNS
//
//  Created by hypo on 2017/3/14.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import "ViewController.h"
#import "WRHttpDNSManager.h"
#import "WRevaluateServerTrust.h"

#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
#define SCREEN_WIDTH (IOS_VERSION >= 8.0 ? [[UIScreen mainScreen] bounds].size.width : (IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width))

@interface ViewController ()
@property (nonatomic, strong) UITextView *requestUrlView;
@property (nonatomic, strong) UITextView *responseView;
@property (nonatomic,strong) UIButton *sendRequestButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)initSubViews {
    _requestUrlView = [[UITextView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, 20, 300,50)];
    _requestUrlView.text = @"http://i.weread.qq.com/book/info?bookId=100014";
    [_requestUrlView setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
    [_requestUrlView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:_requestUrlView];
    
    _responseView = [[UITextView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, 100, 300, 300)];
    [_responseView setBackgroundColor:[UIColor grayColor]];
    [_requestUrlView setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
    [self.view addSubview:_responseView];
    
    _sendRequestButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, 420, 300, 30)];
    [_sendRequestButton setTitle:@"send request" forState:UIControlStateNormal];
    [_sendRequestButton setBackgroundColor:[UIColor greenColor]];
    [_sendRequestButton addTarget:self action:@selector(handleRequestButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sendRequestButton];
}

- (void)handleRequestButtonClick:(id)button {
    NSURL *url = [NSURL URLWithString:_requestUrlView.text];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[WRHttpDNSManager shareInstance] useHttpDNSWithRequest:request];
    
    [self requestWithURLSessionRequest:request];
    [self requestWithURLConnectionRequest:request];
}

- (void)requestWithURLSessionRequest:(NSMutableURLRequest *)request {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:nil];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self checkHttpDNSError:error request:request];
        }
        [self updateResponseViewWithData:data];
    }] resume];
    
}

- (void)requestWithURLConnectionRequest:(NSMutableURLRequest *)request {
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}


- (void)updateResponseViewWithData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
        _responseView.text = [NSString stringWithFormat:@"response content:%@",responseString];
    });
    NSLog(@"responseString:%@",responseString);
}

- (void)checkHttpDNSError:(NSError *)error request:(NSURLRequest *)request{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:request.URL resolvingAgainstBaseURL:YES];
    NSString *domain = urlComponents.host;
    [[WRHttpDNSManager shareInstance] checkHttpDNSError:error domain:domain];
}


#pragma mark - URLSession delegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSString* host = [[task.originalRequest allHTTPHeaderFields] objectForKey:@"Host"];
    if (!host) {
        host = task.originalRequest.URL.host;
    }
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([WRevaluateServerTrust evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - connection delegate

- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    NSString* host = [[connection.originalRequest allHTTPHeaderFields] objectForKey:@"Host"];
    if (!host) {
        host = connection.currentRequest.URL.host;
    }
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([WRevaluateServerTrust evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        } else {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    } else {
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
     [self updateResponseViewWithData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self checkHttpDNSError:error request:connection.originalRequest];
}

@end
