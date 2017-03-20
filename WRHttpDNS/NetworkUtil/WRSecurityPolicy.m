//
//  WRSecurityPolicy.m
//  WRHttpDNS
//
//  Created by hypo on 2017/3/20.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import "WRSecurityPolicy.h"
#import "WRHttpDNSManager.h"

@implementation WRSecurityPolicy

+ (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain {
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    NSLog(@"evaluateServerTrust domain:%@, restult:%@",domain,@(result));
    BOOL isSuccess = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    //证书校验不通过，可能是因为客户端没有支持SNI，IP访问导致拿到的证书不对
    if (!isSuccess) {
        NSLog(@"evaluateServerTrust cer failed");
        [[WRHttpDNSManager shareInstance] markDNSCacheAbandonedWithDomain:domain];
    }
    
    NSAssert(isSuccess, @"wr_evaluateServerTrust failed");
    return isSuccess;
}
@end
