#import "NSObject_Extension.h"
#import "SALLDBInit.h"

@implementation NSObject (SALLDBInit)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[SALLDBInit alloc] initWithBundle:plugin];
        });
    }
}
@end
