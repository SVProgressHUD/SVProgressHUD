#import "KWCaptureSpy.h"

#import "KWObjCUtilities.h"
#import "KWNull.h"
#import "KWValue.h"
#import "NSInvocation+KiwiAdditions.h"
#import "NSMethodSignature+KiwiAdditions.h"

@interface KWCaptureSpy()

@property (nonatomic, strong) id argument;

@end

@implementation KWCaptureSpy {
	NSUInteger _argumentIndex;
}

- (id)initWithArgumentIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        _argumentIndex = index;
    }
    return self;
}

- (id)argument {
    if (!_argument) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Argument requested has yet to be captured." userInfo:nil];
    }

	if(_argument == [KWNull null]) {
		return nil;
	}
	else {
		return _argument;
	}
}

- (void)object:(id)anObject didReceiveInvocation:(NSInvocation *)anInvocation {
    if (!_argument) {
        NSMethodSignature *signature = [anInvocation methodSignature];
        const char *objCType = [signature messageArgumentTypeAtIndex:_argumentIndex];
        if (KWObjCTypeIsObject(objCType) || KWObjCTypeIsClass(objCType)) {
			void* argumentBuffer = NULL;
            [anInvocation getMessageArgument:&argumentBuffer atIndex:_argumentIndex];
			id argument = (__bridge id)argumentBuffer;
            if (KWObjCTypeIsBlock(objCType)) {
                _argument = [argument copy];
            } else {
				if(argument == nil) {
					_argument = [KWNull null];
				} else {
					_argument = argument;
				}
            }
        } else {
            NSData *data = [anInvocation messageArgumentDataAtIndex:_argumentIndex];
            _argument = [KWValue valueWithBytes:[data bytes] objCType:objCType];
        }
    }
}

@end
