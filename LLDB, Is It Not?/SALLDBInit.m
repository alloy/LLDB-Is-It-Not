#import "SALLDBInit.h"

@interface SALLDBInit ()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation SALLDBInit

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
    }
    return self;
}

@end
