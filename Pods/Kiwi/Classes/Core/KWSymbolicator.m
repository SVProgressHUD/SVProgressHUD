//
//  KWSymbolicator.m
//  Kiwi
//
//  Created by Jerry Marino on 4/28/13.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import "KWSymbolicator.h"
#import <objc/runtime.h>
#import <libunwind.h>

long kwCallerAddress (void){
#if !__arm__
	unw_cursor_t cursor; unw_context_t uc;
	unw_word_t ip;

	unw_getcontext(&uc);
	unw_init_local(&cursor, &uc);

    int pos = 2;
	while (unw_step(&cursor) && pos--){
		unw_get_reg (&cursor, UNW_REG_IP, &ip);
        if(pos == 0) return (NSUInteger)(ip - 4);
	}
#endif
    return 0;
}

// Used to suppress compiler warnings by
// casting receivers to this protocol
@protocol NSTask_KWWarningSuppressor

- (void)setLaunchPath:(NSString *)path;
- (void)setArguments:(NSArray *)arguments;
- (void)setEnvironment:(NSDictionary *)dict;
- (void)setStandardOutput:(id)output;
- (void)launch;
- (void)waitUntilExit;

@end

@implementation NSString (KWShellCommand)

+ (NSString *)stringWithShellCommand:(NSString *)command arguments:(NSArray *)arguments {
    id<NSTask_KWWarningSuppressor> task = [[NSClassFromString(@"NSTask") alloc] init];
    [task setEnvironment:[NSDictionary dictionary]];
    [task setLaunchPath:command];
    [task setArguments:arguments];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];

    [task waitUntilExit];

    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

@end
