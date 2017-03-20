//
//  WRDNSProviderBase.m
//  WRHttpDNS
//
//  Created by hypo on 2017/3/15.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import "WRDNSProviderBase.h"



@implementation WRDNSProviderBase

-(NSString *) getRequestString:(NSString *)domain {
    return @"";
}

-(WRDNSRecord *)parseResult:(NSData *)data domain:(NSString *)domain {
    return nil;
}

- (void)requsetRecord:(NSString *)domain isHttps:(BOOL)isHttps callback:(HTTPDNSCallback)callback {
    NSString *urlString = [self getRequestString:domain isHttps:isHttps];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        WRDNSRecord *res = [self parseResult:data domain:domain];
        callback(res);
    }] resume];
}

@end
