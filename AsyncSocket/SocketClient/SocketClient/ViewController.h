//
//  ViewController.h
//  SocketClient
//
//  Created by Cayden Liew on 11/15/11.
//  Copyright (c) 2011 Cayden Liew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface ViewController : UIViewController {
    UITextField *textfield;
    GCDAsyncSocket *asyncSocket;
}

@end
