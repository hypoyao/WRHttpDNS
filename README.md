# WRHttpDNS
- A simple httpDNS framework, support http and https, but not SNI currently. 
- High availability, request DNS info asynchronously, abandon overdue or unusable DNS Cache automatically, change DNS cache as network changed.
- Provide GoogleDNS service default, you can add other custom DNS service easily.

## Installation
### As a [CocoaPod](http://cocoapods.org/)
Just add this to your Podfile
```bash
pod 'WRHttpDNS'
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
As https connection, you should implement some delegate like `WRURLSessionDelegate` or `WRURLConnecitonDelegate`.

## License
WRHttpDNS is released under the MIT license. See LICENSE for details.
