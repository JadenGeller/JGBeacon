//
//  JGReceiveBeacon.h
//  JGBeaconExample
//
//  Created by Jaden Geller on 1/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JGReceiveBeacon : NSObject

@property (nonatomic, copy) void (^dataReceived)(NSData *data);

@property (nonatomic) BOOL scanning;

+(JGReceiveBeacon*)beacon;

@end
