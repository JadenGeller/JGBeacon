//
//  Window.h
//  JGBeaconExample
//
//  Created by Jaden Geller on 2/15/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JGBeacon.h"

@interface Window : NSWindow <JGBeaconDelegate>

@property (weak) IBOutlet NSTextField *sendText;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

-(void)setup;

@end
