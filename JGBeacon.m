//
//  JGBeacon.m
//  JGBeaconExample
//
//  Created by Jaden Geller on 1/20/14.
//
//

#import "JGBeacon.h"
#import "JGReceiveBeacon.h"
#import "JGSendBeacon.h"

@interface JGBeacon ()

@property (nonatomic) JGSendBeacon *sendBeacon;
@property (nonatomic) JGReceiveBeacon *receiveBeacon;

@end

@implementation JGBeacon

+(JGBeacon*)beacon{
    return [[JGBeacon alloc]init];
}

-(JGSendBeacon*)sendBeacon{
    if (!_sendBeacon) {
        _sendBeacon = [JGSendBeacon beacon];
    }
    return _sendBeacon;
}

-(JGReceiveBeacon*)receiveBeacon{
    if (!_receiveBeacon) {
        _receiveBeacon = [JGReceiveBeacon beacon];
        
        JGBeacon __block *blockSelf = self;
        _receiveBeacon.dataReceived = ^void (NSData *data){
            [blockSelf.delegate receivedData:data];
            
        };
        _receiveBeacon.shouldConnectToBeacon = ^BOOL (NSUUID *identifier, NSNumber *strength){
            
            return [blockSelf.delegate shouldConnectToBeacon:identifier strength:strength];
            
        };
    }
    return _receiveBeacon;
}

-(void)queueDataToSend:(NSData*)data{
    [self.sendBeacon queueDataToSend:data];
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

-(void)setRunning:(JGBeaconState)running{
    
    if (running & JGBeaconSendingOnly) {
        self.sendBeacon.advertising = YES;
    }
    else if(_sendBeacon) self.sendBeacon.advertising = NO;
    if (running & JGBeaconReceivingOnly) {
        self.receiveBeacon.scanning = YES;
    }
    else if(_receiveBeacon) self.receiveBeacon.scanning = NO;
}

-(JGBeaconState)running{
    return (self.advertising | self.scanning);
}

-(void)disconnectBeacon:(NSUUID*)identifier{
    [self.receiveBeacon disconnectBeacon:identifier];
}

-(void)disconnectAll{
    [self.receiveBeacon disconnectAll];
}

@end
