//
//  WRHttpDNSManager.h
//  WRHttpDNS
//
//  Created by hypo on 2017/3/14.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WRHttpDNSManager : NSObject
+ (instancetype)shareInstance;

- (BOOL)useHttpDNSWithRequest:(NSMutableURLRequest *)request;

- (NSString *)getIPWithDomain:(NSString *)domain;
- (void)markDNSCacheAbandonedWithDomain:(NSString *)domain;
- (BOOL)isHostUnreachableWithError:(NSError *)error;
@end
