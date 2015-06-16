#import "KWMessageSpying.h"

@interface KWCaptureSpy : NSObject<KWMessageSpying>

@property (nonatomic, strong, readonly) id argument;

- (id)initWithArgumentIndex:(NSUInteger)index;

@end
