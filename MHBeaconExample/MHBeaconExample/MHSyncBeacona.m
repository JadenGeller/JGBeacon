//
//  MHSyncBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHSyncBeacon.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString * const TRANSFER_SERVICE_UUID = @"0DC02E8E-FB88-4D3E-B82A-9FAFDB4BFB7A";

@interface MHSyncBeacon ()

@property (nonatomic, readonly) CBPeripheralManager *peripheralManager;
@property (nonatomic, readonly) CBCentralManager *centralManager;

@end

@implementation MHSyncBeacon
//
//-(void)peripheralEnteredProximity:(CBPeripheral*)peripheral{
//    
//    //decide who sends first (send random number in inital greeting/discovery)
//    //either send -> receive or receive -> send
//    
//    //RECIEVE - BOTH CASES: add if not already present
//    //          IF WE ARE FIRST: if already present, mark as recieved from this person in context
//    //          BOTH CASES: Send new things no already present neighbors
//    
//    //SEND - loop though our messsages and push them
//    //       IF WE ARE SECOND: don't push those marked as already sent
//}
//
//-(NSDictionary*)dataWithMessageText:(NSString*)message{
//    return @{MHUserNameKey: self.name, MHMessageKey : message};
//}
//
//-(void)sendMessage:(NSDictionary*)message toPeripheral:(CBPeripheral*)peripheral{
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
//    [self sendData:data toPeripheral:peripheral];
//}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // Start with the CBMutableCharacteristic
    //self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    //transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}

-(id)init{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

-(MHSyncBeacon*)syncBeacon{
    MHSyncBeacon *beacon = [[MHSyncBeacon alloc]init];
//    
//    MHBeaconData *data = [MHBeaconData beaconData];
//    data.localNameKey = self.name;
//    data.serviceUUIDsKey = @[MHService];
    
//    [beacon setAdvertisedData: data];
    return beacon;
}

@end
