#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface DVTFilePath : NSObject
- (NSURL *)fileURL;
@end

@interface IDEWorkspace : NSObject
- (DVTFilePath *)representingFilePath;
@end

@interface IDEExecutionEnvironment : NSObject
- (IDEWorkspace *)workspace;
@end

@interface IDELaunchSession : NSObject
- (IDEExecutionEnvironment *)executionEnvironment;
@end

@interface NSObject (DBGLLDBSession)
- (void)_refreshThreadListAndUpdateCurrentThread:(int)arg1;
- (BOOL)currentThreadIsSessionThread;
- (void)executeDebuggerCommand:(id)arg1 threadID:(unsigned long long)arg2 stackFrameID:(unsigned long long)arg3;
- (IDELaunchSession *)launchSession;
@end

@interface NSObject (SALLDBInit)
@end

@implementation NSObject (SALLDBInit)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    Class klass = NSClassFromString(@"DBGLLDBSession");
    if (klass == nil) {
        NSLog(@"[SALLDBInit] Disabled due to being unable to load DBGLLDBSession class.");
        return;
    }
    Method originalMethod = class_getInstanceMethod(klass, @selector(_refreshThreadListAndUpdateCurrentThread:));
    Method swizzledMethod = class_getInstanceMethod(klass, @selector(SALLDBInit_refreshThreadListAndUpdateCurrentThread:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

// The -[DBGLLDBSession _refreshThreadListAndUpdateCurrentThread:] method is called when a debugger event occurs, such
// as when the process is interrupted. The reason for hijacking this method is two-fold:
//
// 1. It means we don’t always perform this work and load the scripts when the user doesn’t end-up using the debugger.
// 2. It is called from the debugger session thread (from inside the `DBGLLDBSessionThread` function), which is the
//    only thread from where commands can be executed.
//
- (void)SALLDBInit_refreshThreadListAndUpdateCurrentThread:(int)arg1;
{
    // First call the original implementation.
    [self SALLDBInit_refreshThreadListAndUpdateCurrentThread:arg1];

    static char didLoadInitFileKey;
    NSNumber *didLoadInitFile = objc_getAssociatedObject(self, &didLoadInitFileKey);
    if (didLoadInitFile.boolValue) {
        return;
    }

    // Ensure we’re in the debugger thread.
    if (!self.currentThreadIsSessionThread) {
        NSLog(@"[SALLDBInit] Ignoring unexpected call to -[DBGLLDBSession _refreshThreadListAndUpdateCurrentThread:]");
        return;
    }

    objc_setAssociatedObject(self, &didLoadInitFileKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // Even though it’s called ‘workspace’, this refers to the xcodeproj when the user isn’t using a workspace.
    NSURL *workspaceURL = self.launchSession.executionEnvironment.workspace.representingFilePath.fileURL;
    NSURL *sourceRootURL = [workspaceURL URLByDeletingLastPathComponent];
    NSURL *lldbinitURL = [sourceRootURL URLByAppendingPathComponent:@".lldbinit"];

    if (![lldbinitURL checkResourceIsReachableAndReturnError:nil]) {
        NSLog(@"[SALLDBInit] No LLDB init file at: %@", lldbinitURL.path);
        return;
    }

    NSLog(@"[SALLDBInit] Loading LLDB init file at: %@", lldbinitURL.path);
    NSString *cwd = [NSString stringWithFormat:@"script import os; os.chdir('%@');", sourceRootURL.path];
    [self executeDebuggerCommand:cwd threadID:1 stackFrameID:0];
    [self executeDebuggerCommand:@"command source .lldbinit" threadID:1 stackFrameID:0];
}

@end
