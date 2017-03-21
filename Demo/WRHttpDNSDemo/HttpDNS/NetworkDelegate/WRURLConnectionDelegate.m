//
//  WRURLConnectionDelegate.m
//  WRHttpDNS
//
//  Created by hypo on 2017/3/20.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import "WRURLConnectionDelegate.h"
#import "WRevaluateServerTrust.h"
#import "WRHttpDNSManager.h"

@implementation WRURLConnectionDelegate

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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //mark HttpDNS cache Abandoned
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:connection.originalRequest.URL resolvingAgainstBaseURL:YES];
    NSString *domain = urlComponents.host;
    [[WRHttpDNSManager shareInstance] checkHttpDNSError:error domain:domain];
}

@end
