//
//  WRDNSRecord.h
//  WRHttpDNS
//
//  Created by hypo on 2017/3/15.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WRDNSRecord : NSObject
@property(nonatomic, strong) NSString *domain;
@property(nonatomic, strong) NSString *ip;
@property(nonatomic, assign) NSInteger TTL;
@property(nonatomic, assign) NSTimeInterval requestTime;
@property(nonatomic, assign) BOOL isAbandoned;

typedef void(^HTTPDNSCallback)(WRDNSRecord *record);

- (BOOL)isValid;
- (BOOL)isAlmostOverDue;
@end
