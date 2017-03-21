//
//  WRHttpDNSManager.m
//  WRHttpDNS
//
//  Created by hypo on 2017/3/14.
//  Copyright © 2017年 hypo. All rights reserved.
//

#import "WRHttpDNSManager.h"
#import "WRDNSRecord.h"
#import "WRDNSProviderQcloud.h"
#import "AFNetworkReachabilityManager.h"
#import "WRDNSProviderGoogle.h"

static dispatch_queue_t requestIPQueue() {
    static dispatch_queue_t httpDNS_requestIP_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpDNS_requestIP_queue = dispatch_queue_create("httpDNS.queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return httpDNS_requestIP_queue;
}


@implementation WRHttpDNSManager {
    NSMutableDictionary *_DNSCache;
    WRDNSProviderBase *_dnsProvider;
}

+ (instancetype)shareInstance
{
    static WRHttpDNSManager *httpDNSManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpDNSManager = [[WRHttpDNSManager alloc] init];
    });
    return httpDNSManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _DNSCache = [[NSMutableDictionary alloc] init];
        [self userGoogleDNSProvider];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChanged) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

- (void)userQcloudDNSProvider {
    _dnsProvider = [[WRDNSProviderQcloud alloc] init];
}

- (void)userGoogleDNSProvider {
    _dnsProvider = [[WRDNSProviderGoogle alloc] init];
}

- (BOOL)shouldUseHttpDNSWithDomain:(NSString *)domain {
    return YES;
}

- (BOOL)useHttpDNSWithRequest:(NSMutableURLRequest *)request {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:request.URL resolvingAgainstBaseURL:YES];
    if (!urlComponents) {
        return NO;
    }
    BOOL isHttps = [[request.URL absoluteString] hasPrefix:@"https"];
    NSString *originalDomain = urlComponents.host;
    NSString* ip = [[WRHttpDNSManager shareInstance] getIPWithDomain:originalDomain];
    if (ip.length) {
        urlComponents.host = ip;
        request.URL = urlComponents.URL;
        if (isHttps) {
            [request setValue:originalDomain forHTTPHeaderField:@"Host"];
        }
        NSLog(@"replace success domain:%@ to host:%@",originalDomain,ip);
        return YES;
    }
    return NO;
}

- (NSString *)getIPWithDomain:(NSString *)domain {
    if (![self shouldUseHttpDNSWithDomain:domain]) {
        return nil;
    }
    NSAssert(domain.length,@"domain is nil");
    @synchronized (_DNSCache) {
        WRDNSRecord *info = _DNSCache[domain];
        
        if (info.isAbandoned) {
            return nil;
        }
        
        if ([info isAlmostOverDue]) {
            dispatch_async(requestIPQueue(), ^{
                NSLog(@"dns info overdue");
                [self requestIPWithDomain:domain];
            });
            NSLog(@"dns info success");
            return info.ip;
        }
        
        if (info) {
            NSLog(@"dns info success");
            return info.ip;
        }
    }
    
    dispatch_async(requestIPQueue(), ^{
        [self requestIPWithDomain:domain];
    });
    
    return nil;
}

- (void)requestIPWithDomain:(NSString *)domain {
    WRDNSRecord *info = [self readDNSInfoFromCacheWithDomain:domain];
    if (info) {
        return;
    }

    [_dnsProvider requsetRecord:domain isHttps:YES callback:^(WRDNSRecord *record) {
        [self setDNSCacheWithIP:record domain:domain];
    }];
}

- (void)setDNSCacheWithIP:(WRDNSRecord *)info domain:(NSString *)domain {
    @synchronized (_DNSCache) {
        if ([info isValid] && domain.length) {
            [_DNSCache setObject:info forKey:domain];
        }
    }
}

- (void)markDNSCacheAbandonedWithDomain:(NSString *)domain {
    WRDNSRecord *dnsInfo = nil;
    @synchronized (_DNSCache) {
        dnsInfo = _DNSCache[domain];
        if (dnsInfo) {
            dnsInfo.isAbandoned = YES;
        }
    }
    if (dnsInfo) {
        NSLog(@"httpDns connect failed");
    }
}

- (void)checkHttpDNSError:(NSError *)error domain:(NSString *)domain {
    if ([[WRHttpDNSManager shareInstance] isHostUnreachableWithError:error]) {
        [[WRHttpDNSManager shareInstance] markDNSCacheAbandonedWithDomain:domain];
    }
}

- (WRDNSRecord *)readDNSInfoFromCacheWithDomain:(NSString *)domain {
    @synchronized (_DNSCache) {
        WRDNSRecord *dnsInfo = _DNSCache[domain];
        if ([dnsInfo isValid]) {
            return dnsInfo;
        }
    }
    return nil;
}

- (void)handleNetworkChanged {
    @synchronized (_DNSCache) {
        [_DNSCache removeAllObjects];
    }
}

- (BOOL)isHostUnreachableWithError:(NSError *)error {
    return error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorCannotFindHost || error.code == kCFURLErrorCannotConnectToHost;
}
@end
