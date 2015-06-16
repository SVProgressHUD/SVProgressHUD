//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWMessagePattern.h"
#import "KWFormatter.h"
#import "KWNull.h"
#import "KWObjCUtilities.h"
#import "KWValue.h"
#import "NSInvocation+KiwiAdditions.h"
#import "NSMethodSignature+KiwiAdditions.h"
#import "KWGenericMatchEvaluator.h"
#import "Kiwi.h"

@implementation KWMessagePattern

#pragma mark - Initializing

- (id)initWithSelector:(SEL)aSelector {
    return [self initWithSelector:aSelector argumentFilters:nil];
}

- (id)initWithSelector:(SEL)aSelector argumentFilters:(NSArray *)anArray {
    self = [super init];
    if (self) {
        selector = aSelector;

        if ([anArray count] > 0)
            argumentFilters = [anArray copy];
    }

    return self;
}

- (id)initWithSelector:(SEL)aSelector firstArgumentFilter:(id)firstArgumentFilter argumentList:(va_list)argumentList {
    NSUInteger count = KWSelectorParameterCount(aSelector);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    [array addObject:(firstArgumentFilter != nil) ? firstArgumentFilter : [KWNull null]];

    for (NSUInteger i = 1; i < count; ++i)
    {
        id object = va_arg(argumentList, id);
        [array addObject:(object != nil) ? object : [KWNull null]];
    }

    va_end(argumentList);
    return [self initWithSelector:aSelector argumentFilters:array];
}

+ (id)messagePatternWithSelector:(SEL)aSelector {
    return [self messagePatternWithSelector:aSelector argumentFilters:nil];
}

+ (id)messagePatternWithSelector:(SEL)aSelector argumentFilters:(NSArray *)anArray {
    return [[self alloc] initWithSelector:aSelector argumentFilters:anArray];
}

+ (id)messagePatternWithSelector:(SEL)aSelector firstArgumentFilter:(id)firstArgumentFilter argumentList:(va_list)argumentList {
    return [[self alloc] initWithSelector:aSelector firstArgumentFilter:firstArgumentFilter argumentList:argumentList];
}

+ (id)messagePatternFromInvocation:(NSInvocation *)anInvocation {
    NSMethodSignature *signature = [anInvocation methodSignature];
    NSUInteger numberOfMessageArguments = [signature numberOfMessageArguments];
    NSMutableArray *argumentFilters = nil;

    if (numberOfMessageArguments > 0) {
        argumentFilters = [[NSMutableArray alloc] initWithCapacity:numberOfMessageArguments];

        for (NSUInteger i = 0; i < numberOfMessageArguments; ++i) {
			const char *type = [signature messageArgumentTypeAtIndex:i];
			void* argumentDataBuffer = malloc(KWObjCTypeLength(type));
			[anInvocation getMessageArgument:argumentDataBuffer atIndex:i];
			id object = nil;
			if(*(__unsafe_unretained id*)argumentDataBuffer != [KWAny any] && !KWObjCTypeIsObject(type)) {
                NSData *data = [anInvocation messageArgumentDataAtIndex:i];
                object = [KWValue valueWithBytes:[data bytes] objCType:type];
            } else {
				object = *(__unsafe_unretained id*)argumentDataBuffer;

				if (object != [KWAny any] && KWObjCTypeIsBlock(type)) {
					object = [object copy]; // Converting NSStackBlock to NSMallocBlock
				}
			}
			
            [argumentFilters addObject:(object != nil) ? object : [KWNull null]];

			free(argumentDataBuffer);
        }
    }

    return [self messagePatternWithSelector:[anInvocation selector] argumentFilters:argumentFilters];
}

#pragma mark - Properties

@synthesize selector;
@synthesize argumentFilters;

#pragma mark - Matching Invocations

- (BOOL)argumentFiltersMatchInvocationArguments:(NSInvocation *)anInvocation {
    if (self.argumentFilters == nil)
        return YES;

    NSMethodSignature *signature = [anInvocation methodSignature];
    NSUInteger numberOfArgumentFilters = [self.argumentFilters count];
    NSUInteger numberOfMessageArguments = [signature numberOfMessageArguments];

    for (NSUInteger i = 0; i < numberOfMessageArguments && i < numberOfArgumentFilters; ++i) {
        const char *objCType = [signature messageArgumentTypeAtIndex:i];
        id __autoreleasing object = nil;

        // Extract message argument into object (wrapping values if neccesary)
        if (KWObjCTypeIsObject(objCType) || KWObjCTypeIsClass(objCType)) {
            [anInvocation getMessageArgument:&object atIndex:i];
        } else {
            NSData *data = [anInvocation messageArgumentDataAtIndex:i];
            object = [KWValue valueWithBytes:[data bytes] objCType:objCType];
        }

        // Match argument filter to object
        id argumentFilter = (self.argumentFilters)[i];

        if ([argumentFilter isEqual:[KWAny any]]) {
            continue;
        }

        if ([KWGenericMatchEvaluator isGenericMatcher:argumentFilter]) {
            id matcher = argumentFilter;
            if ([object isKindOfClass:[KWValue class]] && [object isNumeric]) {
                NSNumber *number = [object numberValue];
                if (![KWGenericMatchEvaluator genericMatcher:matcher matches:number]) {
                    return NO;
                }
            } else if (![KWGenericMatchEvaluator genericMatcher:matcher matches:object]) {
                return NO;
            }
        } else if ([argumentFilter isEqual:[KWNull null]]) {
            if (!KWObjCTypeIsPointerLike(objCType)) {
                [NSException raise:@"KWMessagePatternException" format:@"nil was specified as an argument filter, but argument(%d) is not a pointer for @selector(%@)", (int)(i + 1), NSStringFromSelector([anInvocation selector])];
            }
            void *p = nil;
            [anInvocation getMessageArgument:&p atIndex:i];
            if (p != nil)
                return NO;
        } else if (![argumentFilter isEqual:object]) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)matchesInvocation:(NSInvocation *)anInvocation {
    return self.selector == [anInvocation selector] && [self argumentFiltersMatchInvocationArguments:anInvocation];
}

#pragma mark - Comparing Message Patterns

- (NSUInteger)hash {
    return [NSStringFromSelector(self.selector) hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[KWMessagePattern class]])
        return NO;

    return [self isEqualToMessagePattern:object];
}

- (BOOL)isEqualToMessagePattern:(KWMessagePattern *)aMessagePattern {
    if (self.selector != aMessagePattern.selector)
        return NO;

    if (self.argumentFilters == nil && aMessagePattern.argumentFilters == nil)
        return YES;

    return [self.argumentFilters isEqualToArray:aMessagePattern.argumentFilters];
}

#pragma mark - Retrieving String Representations

- (NSString *)selectorString {
    return NSStringFromSelector(self.selector);
}

- (NSString *)selectorAndArgumentFiltersString {
    NSMutableString *description = [[NSMutableString alloc] init];
    NSArray *components = [NSStringFromSelector(self.selector) componentsSeparatedByString:@":"];
    NSUInteger count = [components count] - 1;

    for (NSUInteger i = 0; i < count; ++i) {
        NSString *selectorComponent = components[i];
        NSString *argumentFilterString = [KWFormatter formatObject:(self.argumentFilters)[i]];
        [description appendFormat:@"%@:%@ ", selectorComponent, argumentFilterString];
    }

    return description;
}

- (NSString *)stringValue {
    if (self.argumentFilters == nil)
        return [self selectorString];
    else
        return [self selectorAndArgumentFiltersString];
}

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"selector: %@\nargumentFilters: %@",
                                      NSStringFromSelector(self.selector),
                                      self.argumentFilters];
}

@end
