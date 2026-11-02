#import <Foundation/Foundation.h>

// TrollFools 注入版：写 App 沙盒内的 tmp 目录
static NSString *igtap_file(NSString *name) {
    NSString *dir = NSTemporaryDirectory();
    if (!dir || dir.length == 0) dir = @"/tmp";
    return [dir stringByAppendingPathComponent:name];
}

static void igtap_log(NSString *s) {
    NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [NSDate date], s];
    NSString *p = igtap_file(@"igtap2.log");
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:p];
    if (!fh) {
        [line writeToFile:p atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return;
    }
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    } @finally {
        [fh closeFile];
    }
}

static void igtap_grab(NSURLRequest *req) {
    static BOOL done = NO;
    if (done || !req) return;
    @try {
        NSString *ck = [req valueForHTTPHeaderField:@"Cookie"];
        if (ck.length < 20) return;
        if ([ck rangeOfString:@"sessionid="].location == NSNotFound) return;
        if ([ck rangeOfString:@"ds_user_id="].location == NSNotFound) return;

        done = YES;
        NSString *p = igtap_file(@"igtap2_cookie.txt");
        [ck writeToFile:p atomically:YES encoding:NSUTF8StringEncoding error:nil];
        igtap_log([NSString stringWithFormat:@"OK captured len=%lu -> %@",
                   (unsigned long)ck.length, p]);
    } @catch (NSException *e) {
        igtap_log([NSString stringWithFormat:@"grab err: %@", e]);
    }
}

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    igtap_grab(request);
    return %orig;
}

%end

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request {
    igtap_grab(request);
    return %orig;
}

%end

%ctor {
    igtap_log([NSString stringWithFormat:@"igtap2 loaded (sandbox), tmp=%@",
               NSTemporaryDirectory()]);
}
