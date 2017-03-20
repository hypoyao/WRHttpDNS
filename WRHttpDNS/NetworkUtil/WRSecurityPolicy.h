//
//  WRSecurityPolicy.h
//  WRHttpDNS
//
//  Created by hypo on 2017/3/20.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WRSecurityPolicy : NSObject
+ (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain;
@end
