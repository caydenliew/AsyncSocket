//
//  AppDelegate.h
//  SocketClient
//
//  Created by Cayden Liew on 11/15/11.
//  Copyright (c) 2011 Cayden Liew. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GCDAsyncSocket;
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
    NSNetServiceBrowser *netServiceBrowser;
	NSNetService *serverService;
	NSMutableArray *serverAddresses;
	GCDAsyncSocket *asyncSocket;
	BOOL connected;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) ViewController *viewController;

@end
