#import <Foundation/Foundation.h>

// 极简诊断版：只写文件，不 hook 任何东西
%ctor {
    NSString *dir = NSTemporaryDirectory();
    if (!dir) dir = @"/tmp";
    NSString *p = [dir stringByAppendingPathComponent:@"igtap2_loaded.txt"];
    NSString *s = [NSString stringWithFormat:@"loaded at %@\npid=%d\ntmp=%@\n",
                   [NSDate date], getpid(), dir];
    [s writeToFile:p atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
