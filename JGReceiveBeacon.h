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
@property (nonatomic, copy) BOOL (^shouldConnectToBeacon)(NSUUID *identifier, NSNumber *strength);

@property (nonatomic) BOOL scanning;

+(JGReceiveBeacon*)beacon;
-(void)disconnectBeacon:(NSUUID*)identifier;
-(void)disconnectAll;

@end
