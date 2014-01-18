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

@property (nonatomic) MHSendBeacon *sharedSendBeacon;
@property (nonatomic) MHReceiveBeacon *sharedReceiveBeacon;

@end

@implementation MHSyncBeacon

-(void)sendData:(NSData*)data{
    [self.sharedSendBeacon sendData:data];
}

-(void)setDataReceived:(void (^)(NSData *))dataReceived{
    self.sharedReceiveBeacon.dataReceived = dataReceived;
}

-(id)init{
    if (self = [super init]) {
        _sharedSendBeacon = [[MHSendBeacon alloc]init];
        _sharedReceiveBeacon = [[MHReceiveBeacon alloc]init];
    }
    return self;
}

+(MHSyncBeacon*)beacon{
    return [[MHSyncBeacon alloc]init];
}

@end
