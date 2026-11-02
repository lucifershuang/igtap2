#import <Foundation/Foundation.h>

#define COOKIE_FILE @"/var/mobile/Media/ig/app_cookie.txt"
#define LOG_FILE    @"/var/mobile/Media/ig/igtap.log"

static void ig_log(NSString *s) {
    NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [NSDate date], s];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:LOG_FILE];
    if (!fh) {
        [line writeToFile:LOG_FILE atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return;
    }
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    } @finally {
        [fh closeFile];
    }
}

static void ig_grab(NSURLRequest *req) {
    static BOOL done = NO;
    if (done || !req) return;
    @try {
        NSString *ck = [req valueForHTTPHeaderField:@"Cookie"];
        if (ck.length < 20) return;
        if ([ck rangeOfString:@"sessionid="].location == NSNotFound) return;
        if ([ck rangeOfString:@"ds_user_id="].location == NSNotFound) return;

        done = YES;
        [ck writeToFile:COOKIE_FILE atomically:YES
               encoding:NSUTF8StringEncoding error:nil];
        ig_log([NSString stringWithFormat:@"OK captured len=%lu", (unsigned long)ck.length]);
    } @catch (NSException *e) {
        ig_log([NSString stringWithFormat:@"grab err: %@", e]);
    }
}

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    ig_grab(request);
    return %orig;
}

%end

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request {
    ig_grab(request);
    return %orig;
}

%end

%ctor {
    ig_log(@"igtap2 loaded");
}
