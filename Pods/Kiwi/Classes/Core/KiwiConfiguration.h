//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

// As of iPhone SDK 4 GM, exceptions thrown across an NSInvocation -invoke or
// forwardInvocation: boundary in the simulator will terminate the app instead
// of being caught in @catch blocks from the caller side of the -invoke. Kiwi
// tries to handle this by storing the first exception that it would have
// otherwise thrown in a nasty global that callers can look for and handle.
// (Buggy termination is less desirable than global variables).
//
// Obviously, this can only handles cases where Kiwi itself would have raised
// an exception.
#if TARGET_IPHONE_SIMULATOR
    #define KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG 1
#endif
