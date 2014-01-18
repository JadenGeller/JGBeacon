//
//  MHSyncBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHSyncBeacon.h"

NSString * const MHService = @"4902FB43-3A20-4835-88FB-5C2A269579DD";

NSString * const MHUserNameKey = @"com.MH.userName";
NSString * const MHMessageKey = @"com.MH.message";

@implementation MHSyncBeacon

-(void)peripheralEnteredProximity:(CBPeripheral*)peripheral{
    
    //decide who sends first (send random number in inital greeting/discovery)
    //either send -> receive or receive -> send
    
    //RECIEVE - BOTH CASES: add if not already present
    //          IF WE ARE FIRST: if already present, mark as recieved from this person in context
    //          BOTH CASES: Send new things no already present neighbors
    
    //SEND - loop though our messsages and push them
    //       IF WE ARE SECOND: don't push those marked as already sent
}

-(NSDictionary*)dataWithMessageText:(NSString*)message{
    return @{MHUserNameKey: self.name, MHMessageKey : message};
}

-(void)sendMessage:(NSDictionary*)message toPeripheral:(CBPeripheral*)peripheral{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data toPeripheral:peripheral];
}

-(MHSyncBeacon*)syncBeacon{
    MHSyncBeacon *beacon = [[MHSyncBeacon alloc]init];
    MHBeaconData *data = [MHBeaconData beaconData];
    data.localNameKey = self.name;
    data.serviceUUIDsKey = @[MHService];
    
    [beacon setAdvertisedData: data];
    return beacon;
}

@end
