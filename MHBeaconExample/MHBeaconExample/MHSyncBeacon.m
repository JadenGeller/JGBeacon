//
//  MHSyncBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHSyncBeacon.h"

NSString * const MHServiceGreet = @"506FB99E-ECFD-498E-91BC-12CB60840559";
NSString * const MHServiceSync = @"857824DE-F732-410C-B79B-191308489345";
NSString * const MHLocalKeyName = @"com.MH.SyncBeacon";

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

-(MHSyncBeacon*)syncBeacon{
    MHSyncBeacon *beacon = [[MHSyncBeacon alloc]init];
}

@end
