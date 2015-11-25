#import <Foundation/Foundation.h>

@class SALLDBInit;

static SALLDBInit *sharedPlugin;

@interface SALLDBInit : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle *bundle;
@end