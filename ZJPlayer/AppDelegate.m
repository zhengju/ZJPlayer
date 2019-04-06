//
//  AppDelegate.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/6.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "AppDelegate.h"
#import "MyTabBarController.h"

#import "ZJPlayerSDK.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#define webPath [[NSBundle mainBundle] pathForResource:@"Web" ofType:nil]

@interface AppDelegate ()
{
    HTTPServer *httpServer;
}
@end

@implementation AppDelegate

- (void)startServer
{
    // Start the server (and check for problems)
    
    NSError *error;
    if([httpServer start:&error])
    {
  NSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
    }
    else
    {
//        DDLogError(@"Error starting HTTP Server: %@", error);
    }
}

#define ZJCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache"]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    MyTabBarController * tab = [[MyTabBarController alloc]init];
    
    self.window.rootViewController = tab;
    [self.window makeKeyAndVisible];

    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Create server using our custom MyHTTPServer class
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:12345];
    
    // Serve files from our embedded Web folder
    NSString *webPath2 = ZJCachesDirectory;
    //[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
//    ;
    

    NSLog(@"Setting document root: %@", webPath2);
    
    [httpServer setDocumentRoot:webPath2];
    

            [self startServer];


    return YES;
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return  UIInterfaceOrientationMaskAll;
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//}

//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self startServer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // There is no public(allowed in AppStore) method for iOS to run continiously in the background for our purposes (serving HTTP).
    // So, we stop the server when the app is paused (if a users exits from the app or locks a device) and
    // restart the server when the app is resumed (based on this document: http://developer.apple.com/library/ios/#technotes/tn2277/_index.html )
    
    [httpServer stop];
}
@end
