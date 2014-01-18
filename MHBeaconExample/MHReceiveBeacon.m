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
@property (nonatomic) CBPeripheral *discoveredPeripheral;
@property (nonatomic) NSMutableData *data;

@end

@implementation MHReceiveBeacon

-(id)init{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _data = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state==CBCentralManagerStatePoweredOn) {
        NSLog(@"FUCK");
    }
}

- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    if (self.discoveredPeripheral != peripheral) {
        // New peripheral
        
        // Save a local copy of the peripheral because ARC
        self.discoveredPeripheral = peripheral;
        
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cleanup];
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
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
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
        
        // Cancel subscription and disconnect
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        [self.centralManager cancelPeripheralConnection:peripheral];
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
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        // It's not the transfer characteristic
        
        // Notification has started
        if (!characteristic.isNotifying) {
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.discoveredPeripheral = nil;
    
    // We're disconnected, so start scanning again
    [self scan];
}

- (void)cleanup
{
    // Do if we're  connected
    if (self.discoveredPeripheral.state == CBPeripheralStateConnected) {
        
        // See if we are subscribed to a characteristic on the peripheral
        if (self.discoveredPeripheral.services != nil) {
            for (CBService *service in self.discoveredPeripheral.services) {
                if (service.characteristics != nil) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                            if (characteristic.isNotifying) {
                                // It is notifying, so unsubscribe
                                [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                                
                                // And we're done.
                                return;
                            }
                        }
                    }
                }
            }
        }
        
        // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];

    }
}

@end
