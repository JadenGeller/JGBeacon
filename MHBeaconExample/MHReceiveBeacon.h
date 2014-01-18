//
//  MHReceiveBeacon.h
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import <Foundation/Foundation.h>

@interface MHReceiveBeacon : NSObject

@property (nonatomic, copy) void (^dataReceived)(NSData *data);

@end
