//
//  WRDNSProviderGoogle.m
//  WRHttpDNSDemo
//
//  Created by hypo on 2017/3/21.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import "WRDNSProviderGoogle.h"

const static NSString *kHTTPDNS_GOOGLE_SERVER_ADDRESS = @"dns.google.com";

@implementation WRDNSProviderGoogle
-(NSString *)getRequestString:(NSString *)domain isHttps:(BOOL)isHttps{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/resolve?type=1&name=%@",(isHttps?@"https":@"http"), kHTTPDNS_GOOGLE_SERVER_ADDRESS, domain];
    return urlString;
}

-(WRDNSRecord *)parseResult:(NSData *)data domain:(NSString *)domain{
    if (!data) {
        return nil;
    }
    NSError *jsonError;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError) {
        return nil;
    }
    NSArray *answerArray = [jsonDic objectForKey:@"Answer"];
    NSMutableArray *ips = [[NSMutableArray alloc] init];
    int ttl = 0;
    for (NSDictionary *answer in answerArray) {
        if([[answer objectForKey:@"type"] isEqual: @1]) {
            ttl = [[answer objectForKey:@"TTL"] intValue];
            [ips addObject:[answer objectForKey:@"data"]];
        }
    }

    int value = (arc4random() % ips.count);
    NSString *ip = (NSString *)ips[value];
    WRDNSRecord *info = [[WRDNSRecord alloc] init];
    info.domain = domain;
    info.ip = ip;
    info.TTL = ttl;
    info.requestTime = [[NSDate date] timeIntervalSinceNow];
    return info;
}
@end
