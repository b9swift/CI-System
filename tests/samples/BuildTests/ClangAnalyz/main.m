//
//  main.m
//  ClangAnalyz
//
//  Copyright (c) 2024 BB9z, MIT License
//

#import <Foundation/Foundation.h>

@interface StaticAnalysis : NSObject
@property (nonnull) void (^capture)(void);
@end

@implementation StaticAnalysis

- (void)vfork {
    pid_t pid = vfork();
    assert(pid >= 0);
}

- (void)misuseKeychianAPI {
    UInt32 passwordLength;
    void *passwordData;
    OSStatus status = SecKeychainFindGenericPassword(NULL, 9, "myService", 8, "myAccount", &passwordLength, &passwordData, NULL);
    if (status == errSecSuccess) {
        // Missing SecKeychainItemFreeContent
    }
}

- (void)nilMutex {
    id obj = nil;
    @synchronized (obj) {
        NSLog(@"do someting");
    }
}

- (void)makeWarning {
    NSString *var = @"a";
    self.capture = nil;
    if (self == nil) {
        NSLog(@"never");
    }
    self.capture = ^{
        [self nilMutex];
    };
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        StaticAnalysis.new;
    }
    return 0;
}
