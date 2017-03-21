# WRHttpDNS
- A simple httpDNS framework, support http and https, but not SNI currently. 
- High availability, request DNS info asynchronously, abandon overdue or unusable DNS Cache automatically, change DNS cache as network changed.
- Provide GoogleDNS service default, you can add other custom DNS service easily.

## Installation
### As a [CocoaPod](http://cocoapods.org/)
Just add this to your Podfile
```bash
pod 'MLeaksFinder'
```
 ### Other approaches
 Download all files under WRHttpDNS directory.
 
 ## Usage
 Support NSURLSession and NSURLConnection，call the method before a real request.
 ```objc
[[WRHttpDNSManager shareInstance] useHttpDNSWithRequest:request];
```
If network responsed an error, you should check the error.
```objc
[[WRHttpDNSManager shareInstance] checkHttpDNSError:error domain:domain]
```
 if the request is https, NSURLSession and NSURLConnection should implement the specified delegate method
 ### NSURLSession
```objc
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSString* host = [[task.originalRequest allHTTPHeaderFields] objectForKey:@"Host"];
    if (!host) {
        host = task.originalRequest.URL.host;
    }
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([WRevaluateServerTrust evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}
```
 ### NSURLConneciton
 ```objc
 - (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    NSString* host = [[connection.originalRequest allHTTPHeaderFields] objectForKey:@"Host"];
    if (!host) {
        host = connection.currentRequest.URL.host;
    }
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([WRevaluateServerTrust evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        } else {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    } else {
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

 ```
## License
WRHttpDNS is released under the MIT license. See LICENSE for details.
