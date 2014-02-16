//
//  JGBeacon.h
//  JGBeaconExample
//
//  Created by Jaden Geller on 1/20/14.
//
//

#import <Foundation/Foundation.h>

@protocol JGBeaconDelegate <NSObject>

-(void)receivedData:(NSData*)data;
-(void)connectedToBeacon:(NSUUID*)identifier;
-(void)disconnectedFromBeacon:(NSUUID*)identifier;

@end

@interface JGBeacon : NSObject

enum {
    JGBeaconSendingOnly = (1 << 0),
    JGBeaconReceivingOnly = (1 << 1),
    JGBeaconNotRunning = 0,
    JGBeaconSendingAndReceiving = JGBeaconSendingOnly | JGBeaconReceivingOnly
} typedef JGBeaconState;

@property (nonatomic, weak) id<JGBeaconDelegate> delegate;

+(JGBeacon*)beacon;

-(void)queueDataToSend:(NSData*)data;

@property (nonatomic, readonly) NSMutableArray *dataQueue;

@property (nonatomic) NSUUID *connectedBeacon;

@property (nonatomic) BOOL scanning;
@property (nonatomic) BOOL advertising;
@property (nonatomic) JGBeaconState running;

@end
