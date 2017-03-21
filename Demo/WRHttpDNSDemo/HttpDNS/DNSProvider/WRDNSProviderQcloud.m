//
//  WRDNSProvideTencentYun.m
//  WRHttpDNS
//
//  Created by hypo on 2017/3/15.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import "WRDNSProviderQcloud.h"

const static NSString *kHTTPDNS_QCLOUD_SERVER_ADDRESS = @"182.254.116.120";
const static NSString *kHTTPDNS_HTTPS_QCLOUD_SERVER_ADDRESS = @"182.254.116.117";

@implementation WRDNSProviderQcloud


-(NSString *) getRequestString:(NSString *)domain isHttps:(BOOL)isHttps{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/d?dn=%@&ttl=1",(isHttps?@"https":@"http"),(isHttps?kHTTPDNS_HTTPS_QCLOUD_SERVER_ADDRESS:kHTTPDNS_QCLOUD_SERVER_ADDRESS),domain];
    return urlString;
}

-(WRDNSRecord *)parseResult:(NSData *)data domain:(NSString *)domain{
    NSString *httpDNSValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!httpDNSValue || httpDNSValue.length == 0) {
        return nil;
    }
    
    NSArray *ipAndTTL = [httpDNSValue componentsSeparatedByString:@","];
    if (!ipAndTTL || ipAndTTL.count != 2) {
        return nil;
    }
    
    NSInteger TTL = [ipAndTTL[1] integerValue];
    NSArray *ips = [ipAndTTL[0] componentsSeparatedByString:@";"];
    if (ips.count <= 0) {
        return nil;
    }
    
    int value = (arc4random() % ips.count);
    NSString *ip = (NSString *)ips[value];
    WRDNSRecord *info = [[WRDNSRecord alloc] init];
    info.domain = domain;
    info.ip = ip;
    info.TTL = TTL;
    info.requestTime = [[NSDate date] timeIntervalSinceNow];
    return info;
}


@end
