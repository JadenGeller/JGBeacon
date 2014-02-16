//
//  JGAppDelegate.m
//  JGBeaconExample
//
//  Created by Jaden Geller on 2/15/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGAppDelegate.h"
#import "Window.h"

@implementation JGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [(Window*)self.window setup];
}

@end
