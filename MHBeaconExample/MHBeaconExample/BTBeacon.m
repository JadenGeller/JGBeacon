//
//  BTBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/20/14.
//
//

#import "BTBeacon.h"
#import "BTReceiveBeacon.h"
#import "BTSendBeacon.h"

@interface BTBeacon ()

@property (nonatomic) BTSendBeacon *sendBeacon;
@property (nonatomic) BTReceiveBeacon *receiveBeacon;

@end

@implementation BTBeacon

+(BTBeacon*)beacon{
    return [[BTBeacon alloc]init];
}

-(id)init{
    if (self = [super init]) {
        self.sendBeacon = [BTSendBeacon beacon];
        self.receiveBeacon = [BTReceiveBeacon beacon];
    }
    return self;
}

-(void)setDataReceived:(void (^)(NSData *))dataReceived{
    self.receiveBeacon.dataReceived = dataReceived;
}

-(void)queueDataToSend:(NSData*)data{
    [self.sendBeacon queueDataToSend:data];
}

-(BOOL)sending{
    return self.sendBeacon.sending;
}

-(void)setScanning:(BOOL)scanning{
    self.receiveBeacon.scanning = scanning;
}

-(BOOL)scanning{
    return self.receiveBeacon.scanning;
}

-(void)setAdvertising:(BOOL)advertising{
    self.sendBeacon.advertising = advertising;
}

-(BOOL)advertising{
    return self.sendBeacon.advertising;
}

-(void)setRunning:(BTBeaconState)running{
    self.sendBeacon.advertising = running & BTBeaconSendingOnly;
    self.receiveBeacon.scanning = running & BTBeaconReceivingOnly;
}

-(BTBeaconState)running{
    return (self.advertising | self.scanning);
}

@end
