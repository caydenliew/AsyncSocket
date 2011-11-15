//
//  AppDelegate.h
//  SocketServer
//
//  Created by Cayden Liew on 11/15/11.
//  Copyright (c) 2011 Cayden Liew. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GCDAsyncSocket;
@interface AppDelegate : NSObject <NSApplicationDelegate, NSNetServiceDelegate> {
    NSNetService *netService;
	GCDAsyncSocket *asyncSocket;
	NSMutableArray *connectedSockets;
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
