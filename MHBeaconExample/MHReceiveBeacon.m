//
//  MHReceiveBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHReceiveBeacon.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface MHReceiveBeacon () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic) CBCentralManager *centralManager;
@property (nonatomic) NSMutableSet *syncedPeripherals;
@property (nonatomic) NSMutableData *data;

@end

@implementation MHReceiveBeacon

-(id)init{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _data = [[NSMutableData alloc] init];
        _syncedPeripherals = [NSMutableSet set];
    }
    return self;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state==CBCentralManagerStatePoweredOn) {
        [self scan];
    }
}

- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if (![self.syncedPeripherals containsObject:peripheral]) {
        // New peripheral
        
        // Save a local copy of the peripheral because ARC
        [self.syncedPeripherals addObject:peripheral];
        
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.centralManager stopScan];
    
    // Clear data
    [self.data setLength:0];
    
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    if ([stringFromData isEqualToString:@"EOM"]) {
        // End of mesages
                
        self.dataReceived(self.data.copy);
        
        // Cancel subscription and disconnect and clear
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        self.data = [NSMutableData data];
        //[self.centralManager cancelPeripheralConnection:peripheral];

    }
    else{
        [self.data appendData:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices{
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.syncedPeripherals removeObject:peripheral];
    
    // We're disconnected, so start scanning again
    [self scan];
}

@end
