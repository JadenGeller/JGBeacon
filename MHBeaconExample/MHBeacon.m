//
//  MHBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHBeacon.h"

@interface MHBeacon ()

@property (nonatomic) NSUInteger readyValue;

@property (nonatomic) NSNumber *queuedAdvertisingValue;
@property (nonatomic) NSNumber *queuedSearchingValue;

@property (nonatomic, readonly) CBPeripheralManager *peripheralManager;
@property (nonatomic, readonly) CBCentralManager *centralManager;

@end

@implementation MHBeacon

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSLog(@"MEH2");
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        if (self.queuedAdvertisingValue) { // Tried to set advertising value earlier but couldn't; set now
            self.advertising = self.queuedAdvertisingValue.boolValue;
            self.queuedAdvertisingValue = nil;
        }
    }
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"MEH");
    if(central.state==CBCentralManagerStatePoweredOn) {
        if (self.queuedSearchingValue) { // Tried to set searching value earlier but couldn't; set now
            self.searching = self.queuedSearchingValue.boolValue;
            self.queuedSearchingValue = nil;
        }
    }
}

-(void)sendData:(NSData*)data{
    NSArray *peripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:self.advertisedData.serviceUUIDsKey];
    for (CBPeripheral *peripheral in peripherals) {
        [self sendData:data toPeripheral:peripheral];
    }
}

-(void)sendData:(NSData *)data toPeripheral:(CBPeripheral *)peripheral{
    
    for(CBService *service in peripheral.services)
    {
        if([service.UUID isEqual:self.advertisedData.serviceUUIDsKey])
        {
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                NSLog(@"%@",characteristic);
            }
        }
    }
    //    [peripheral writeValue:data forCharacteristic: type:<#(CBCharacteristicWriteType)#>]
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"MEH4");
    [self sendData:nil];
}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
//    [peripheral respondToRequest:request withResult:<#(CBATTError)#>];
//}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
//    
//}

-(void)setAdvertisedData:(MHBeaconData *)advertisedData{
    if (advertisedData != _advertisedData) {
        if (self.runningMode) {
            MHRunningMode pastRunningMode = self.runningMode;
            self.runningMode = MHNotRunning;
            
            _advertisedData = advertisedData;
            
            self.runningMode = pastRunningMode;
        }
        else{
            _advertisedData = advertisedData;
        }
    }
}

-(void)setAdvertising:(BOOL)advertising{
    if (advertising != _advertising) {
        if (!advertising) {
            [self.peripheralManager stopAdvertising];
            _advertising = NO;
        }
        else if (self.advertisedData) {
            if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
                [self.peripheralManager startAdvertising:self.advertisedData.dictionaryValue];
                _advertising = YES;
            }
            else{
                self.queuedAdvertisingValue = @YES; // Start advertising later; not ready yet
            }
        }
    }
}

-(void)setSearching:(BOOL)searching{
    if (searching != _searching) {
        if (!searching) {
            [_centralManager stopScan];
            _searching = NO;
        }
        else if (self.advertisedData){
            if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
                NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)};
                
                [_centralManager scanForPeripheralsWithServices:self.advertisedData.serviceUUIDsKey options:scanOptions];
                _searching = YES;
            }
            else{
                self.queuedSearchingValue = @YES; // Start advertising later; not ready yet
            }
        }
    }
}

-(void)setRunningMode:(MHRunningMode)running{
    self.advertising = (running == MHRunning) || (running == MHAdvertising);
    self.searching = (running == MHRunning) || (running == MHSearching);
}

-(void)run{
    self.runningMode = MHRunning;
}

-(void)stop{
    self.runningMode = MHNotRunning;
}

+(MHBeacon*)beacon{
    return [[MHBeacon alloc]init];
}

-(id)init{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];


    }
    return self;
}

@end
