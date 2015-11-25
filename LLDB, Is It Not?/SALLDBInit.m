#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (DBGLLDBSession)
- (void)executeDebuggerCommand:(id)arg1 threadID:(unsigned long long)arg2 stackFrameID:(unsigned long long)arg3;
- (void)_setSessionThreadIdentifier:(void *)arg;
- (BOOL)currentThreadIsSessionThread;
@end

@interface NSObject (SALLDBInit)
@end

@implementation NSObject (SALLDBInit)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSLog(@"DID LOAD! %@", plugin);

    Class klass = NSClassFromString(@"DBGLLDBSession");
    NSParameterAssert(klass); // todo just do nothing

    Method originalMethod = class_getInstanceMethod(klass, @selector(_setSessionThreadIdentifier:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(SALLDBInit_setSessionThreadIdentifier:));

    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)SALLDBInit_setSessionThreadIdentifier:(void *)arg;
{
    // First call original implementation
    [self SALLDBInit_setSessionThreadIdentifier:arg];

    NSLog(@"SWIZZLED INVOCATION: %@", self);

    // Ensure we’re in the debugger thread, as expected.
    if (!self.currentThreadIsSessionThread) {
        NSLog(@"[SALLDBInit] Ignoring unexpected call to -[DBGLLDBSession _setSessionThreadIdentifier:]");
        return;
    }

    [self executeDebuggerCommand:@"command script import /Users/eloy/Code/CocoaPods/CocoaPods-app/app/lldb_ruby.py" threadID:1 stackFrameID:0];
}

@end
