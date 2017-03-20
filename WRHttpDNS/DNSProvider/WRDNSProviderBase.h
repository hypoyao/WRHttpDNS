//
//  WRDNSProviderBase.h
//  WRHttpDNS
//
//  Created by hypo on 2017/3/15.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRDNSRecord.h"
@protocol HTTPDNSBaseProtocol

@required
-(WRDNSRecord *)parseResult:(NSData *)data domain:(NSString *)domain;
- (NSString *)getRequestString:(NSString *)domain;

@end

@interface WRDNSProviderBase : NSObject  <HTTPDNSBaseProtocol>

- (NSString *)getRequestString:(NSString *)domain isHttps:(BOOL)isHttps;
- (void)requsetRecord:(NSString *)domain isHttps:(BOOL)isHttps callback:(HTTPDNSCallback)callback;
@end
