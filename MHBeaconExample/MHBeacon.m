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
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        if (self.queuedAdvertisingValue) { // Tried to set advertising value earlier but couldn't; set now
            self.advertising = self.queuedAdvertisingValue.boolValue;
            self.queuedAdvertisingValue = nil;
        }
    }
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state==CBCentralManagerStatePoweredOn) {
        if (self.queuedSearchingValue) { // Tried to set searching value earlier but couldn't; set now
            self.searching = self.queuedSearchingValue.boolValue;
            self.queuedSearchingValue = nil;
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"%@ %@ %@", peripheral, advertisementData, RSSI);

}

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
                NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)};
                
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
