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
- (void)markDNSCacheAbandonedWithDomain:(NSString *)domain;
- (void)checkHttpDNSError:(NSError *)error domain:(NSString *)domain;
@end
