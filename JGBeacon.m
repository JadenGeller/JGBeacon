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

-(id)init{
    if (self = [super init]) {
        self.sendBeacon = [JGSendBeacon beacon];
        self.receiveBeacon = [JGReceiveBeacon beacon];
        
        JGBeacon __block *blockSelf = self;
        self.receiveBeacon.dataReceived = ^void (NSData *data){
            [blockSelf.delegate receivedData:data];
        };
    }
    return self;
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
    self.sendBeacon.advertising = running & JGBeaconSendingOnly;
    self.receiveBeacon.scanning = running & JGBeaconReceivingOnly;
}

-(JGBeaconState)running{
    return (self.advertising | self.scanning);
}

@end
