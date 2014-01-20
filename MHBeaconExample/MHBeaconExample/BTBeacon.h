//
//  BTBeacon.h
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/20/14.
//
//

#import <Foundation/Foundation.h>

@interface BTBeacon : NSObject

enum {
    BTBeaconSendingOnly = (1 << 0),
    BTBeaconReceivingOnly = (1 << 1),
    BTBeaconNotRunning = 0,
    BTBeaconSendingAndReceiving = BTBeaconSendingOnly | BTBeaconReceivingOnly
} typedef BTBeaconState;

+(BTBeacon*)beacon;

@property (nonatomic, copy) void (^dataReceived)(NSData *data);
-(void)queueDataToSend:(NSData*)data;

@property (nonatomic, readonly) BOOL sending;

@property (nonatomic) BOOL scanning;
@property (nonatomic) BOOL advertising;
@property (nonatomic) BTBeaconState running;

@end
