//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#if __has_feature(objc_arc)
#   define KW_ARC_AUTORELEASE(obj) obj
#else
#   define KW_ARC_AUTORELEASE(obj) [obj autorelease]
#endif

#define KW_LET_REF(var) \
    (__autoreleasing id *) \
    ( (void *(^)(void)) KW_ARC_AUTORELEASE([^{ void *ref = &var; return ref; } copy]) )()
