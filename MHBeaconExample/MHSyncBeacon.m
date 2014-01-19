//
//  MHSyncBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHSyncBeacon.h"
#import "MHSendBeacon.h"
#import "MHReceiveBeacon.h"

@interface MHSyncBeacon ()

@property (nonatomic) MHSendBeacon *sendBeacon;
@property (nonatomic) MHReceiveBeacon *receiveBeacon;

@end

@implementation MHSyncBeacon

-(void)sendData:(NSData*)data{
    [self.sendBeacon sendData:data];
}

-(void)setDataReceived:(void (^)(NSData *))dataReceived{
    self.receiveBeacon.dataReceived = dataReceived;
}

-(id)init{
    if (self = [super init]) {
        _sendBeacon = [[MHSendBeacon alloc]init];
        _receiveBeacon = [[MHReceiveBeacon alloc]init];
    }
    return self;
}

+(MHSyncBeacon*)beacon{
    return [[MHSyncBeacon alloc]init];
}

@end
