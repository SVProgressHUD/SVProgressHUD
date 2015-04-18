//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"

#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG

#pragma mark - Invocation Exception Bug Workaround

// See KiwiConfiguration.h for notes.
void KWSetExceptionFromAcrossInvocationBoundary(NSException *anException);
NSException *KWGetAndClearExceptionFromAcrossInvocationBoundary(void);

#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
