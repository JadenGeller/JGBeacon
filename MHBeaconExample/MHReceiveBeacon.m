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
@property (nonatomic) NSMutableDictionary *data;

-(NSMutableData*)dataForPeripheral:(CBPeripheral*)peripheral;

@end

@implementation MHReceiveBeacon

-(NSMutableData*)dataForPeripheral:(CBPeripheral*)peripheral{
    NSMutableData *data = (NSMutableData*)self.data[peripheral];
    if (!data) {
        data = [NSMutableData data];
        self.data[peripheral] = data;
    }
    return data;
}

-(id)init{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _data = [[NSMutableDictionary alloc] init];
        _syncedPeripherals = [NSMutableSet set];
    }
    return self;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state==CBCentralManagerStatePoweredOn) {
        NSLog(@"R - Ready to go");
        [self scan];
    }
}

- (void)scan
{
    NSLog(@"R - Scanning");

    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // CONNECT TO THE DEVICES HERE
    
    if (![self.syncedPeripherals containsObject:peripheral]) {
        // New peripheral
        NSLog(@"R - Connecting to %@", peripheral);

        // Save a local copy of the peripheral because ARC
        [self.syncedPeripherals addObject:peripheral];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // Clear data
    [self dataForPeripheral:peripheral].length = 0;
    NSLog(@"R - Connected to %@", peripheral);

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
        NSLog(@"R - Found characteristic %@ in service %@ for peripheral %@",characteristic, service, peripheral.name);

        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"R - Will notify for characteristic %@", characteristic);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"R - Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"R - Looks like we got something...");
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"R - %@, aka %@ maybe.", characteristic.value, stringFromData);

    if ([stringFromData isEqualToString:@"EOM"]) {
        // End of mesages
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataReceived([self dataForPeripheral:peripheral].copy);

        });
        
        // Cancel subscription and disconnect and clear
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        [self dataForPeripheral:peripheral].length = 0;
        //[self.centralManager cancelPeripheralConnection:peripheral];

    }
    else{
        [[self dataForPeripheral:peripheral] appendData:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"R - Error changing notification state: %@", error.localizedDescription);
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
