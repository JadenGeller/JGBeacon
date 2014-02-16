//
//  JGBluetooth.h
//  JGBeaconExample
//
//  Created by Jaden Geller on 2/16/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JGBluetooth : NSObject

-(void)connnect;
-(void)sendData:(NSData*)data;

@end
