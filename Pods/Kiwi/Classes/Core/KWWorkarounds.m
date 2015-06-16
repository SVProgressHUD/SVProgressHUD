//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWWorkarounds.h"

#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG

static NSException *KWExceptionAcrossInvokeBoundary = nil;

void KWSetExceptionFromAcrossInvocationBoundary(NSException *anException) {
    if (KWExceptionAcrossInvokeBoundary != nil)
        return;

    KWExceptionAcrossInvokeBoundary = anException;
}

NSException *KWGetAndClearExceptionFromAcrossInvocationBoundary(void) {
    NSException *exception = KWExceptionAcrossInvokeBoundary;
    KWExceptionAcrossInvokeBoundary = nil;
    return exception;
}

#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
