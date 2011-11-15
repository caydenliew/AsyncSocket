//
//  AppDelegate.m
//  SocketClient
//
//  Created by Cayden Liew on 11/15/11.
//  Copyright (c) 2011 Cayden Liew. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "ViewController.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface AppDelegate (Private)
- (void)connectToNextAddress;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize asyncSocket;


- (void)dealloc
{
    [_window release];
    [_viewController release];
    [asyncSocket release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
	[DDLog addLogger:[DDASLLogger sharedInstance]];
	
	// Start browsing for bonjour services
	
	netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	
	[netServiceBrowser setDelegate:self];
	[netServiceBrowser searchForServicesOfType:@"_YourServiceName._tcp." inDomain:@"local."];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
{
	DDLogError(@"DidNotSearch: %@", errorInfo);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	DDLogVerbose(@"DidFindService: %@", [netService name]);
	
	// Connect to the first service we find
	
	if (serverService == nil)
	{
		DDLogVerbose(@"Resolving...");
		
		serverService = [netService retain];
		
		[serverService setDelegate:self];
		[serverService resolveWithTimeout:5.0];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	DDLogVerbose(@"DidRemoveService: %@", [netService name]);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
{
	DDLogInfo(@"DidStopSearch");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	DDLogError(@"DidNotResolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	DDLogInfo(@"DidResolve: %@", [sender addresses]);
	
	if (serverAddresses == nil)
	{
		serverAddresses = [[sender addresses] mutableCopy];
	}
	
	if (asyncSocket == nil)
	{
		asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		
		[self connectToNextAddress];
	}
}

- (void)connectToNextAddress
{
	BOOL done = NO;
	
	while (!done && ([serverAddresses count] > 0))
	{
		NSData *addr;
		
		// Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
		// 
		// If your server is also using GCDAsyncSocket then you don't have to worry about it,
		// as the socket automatically handles both protocols for you transparently.
		
		if (YES) // Iterate forwards
		{
			addr = [[serverAddresses objectAtIndex:0] retain];
			[serverAddresses removeObjectAtIndex:0];
		}
		else // Iterate backwards
		{
			addr = [[serverAddresses lastObject] retain];
			[serverAddresses removeLastObject];
		}
		
		DDLogVerbose(@"Attempting connection to %@", addr);
		
		NSError *err = nil;
		if ([asyncSocket connectToAddress:addr error:&err])
		{
			done = YES;
		}
		else
		{
			DDLogWarn(@"Unable to connect: %@", err);
		}
		
		[addr release];
	}
	
	if (!done)
	{
		DDLogWarn(@"Unable to connect to any resolved address");
	}
}

-(void)onSocket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"socket:%p didWriteDataWithTag:%@", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	DDLogInfo(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	DDLogWarn(@"SocketDidDisconnect:WithError: %@", err);
	
	if (!connected)
	{
		[self connectToNextAddress];
	}
}

@end
