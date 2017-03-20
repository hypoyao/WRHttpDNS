//
//  WRDNSRecord.m
//  WRHttpDNS
//
//  Created by hypo on 2017/3/15.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import "WRDNSRecord.h"

@implementation WRDNSRecord

- (BOOL)isValid {
    if (self.ip.length <= 1) {
        return NO;
    }
    
    if (self.isAbandoned) {
        return NO;
    }
    
    NSTimeInterval durationTime = [[NSDate date] timeIntervalSinceNow] - self.requestTime;
    if (durationTime > self.TTL ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isAlmostOverDue {
    if ([self isValid]) {
        return  [[NSDate date] timeIntervalSinceNow] - self.requestTime > self.TTL * 0.75;
    }
    return NO;
}
@end
