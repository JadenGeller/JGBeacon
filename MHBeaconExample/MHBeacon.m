//
//  MHBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHBeacon.h"

@interface MHBeacon ()

@property NSUInteger readyValue;

@property (nonatomic, readonly) CBPeripheralManager *peripheralManager;
@property (nonatomic, readonly) CBCentralManager *centralManager;

@end

@implementation MHBeacon

@synthesize readyValue = _readyValue;

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.readyValue |= MHAdvertising;
    }
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state==CBCentralManagerStatePoweredOn) {
        self.readyValue |= MHSearching;
    }
}

-(void)setReadyValue:(NSUInteger)readyValue{
    @synchronized(self)
    {
        _readyValue = readyValue;
        if (readyValue == MHRunning) {
            _ready = YES;
        }
    }
}

- (NSUInteger)readyValue
{
    @synchronized(self) {
        return _readyValue;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"RSSI: %d", [RSSI intValue]);

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
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

    }
    return self;
}

@end
