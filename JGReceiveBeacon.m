//
//  JGReceiveBeacon.m
//  JGBeaconExample
//
//  Created by Jaden Geller on 1/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "JGReceiveBeacon.h"
#import "TransferService.h"

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif

@interface JGReceiveBeacon () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray *connectedPeripherals;
@property (strong, nonatomic) NSMutableData *data;

@property (nonatomic) BOOL shouldStartScanning;

@end

@implementation JGReceiveBeacon

+(JGReceiveBeacon*)beacon{
    return [[JGReceiveBeacon alloc]init];
}

-(id)init{
    if (self = [super init]) {
        // Start up the CBCentralManager
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        // And somewhere to store the incoming data
        _data = [[NSMutableData alloc] init];

        _connectedPeripherals = [NSMutableArray array];
    }
    return self;
}

/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"Central manager powered on");
        if (self.shouldStartScanning){
            NSLog(@"Started scanning");
            self.scanning = YES;
        }
    }
    
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
//    if (RSSI.integerValue > -15) {
//        return;
//    }
//    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
//    if (RSSI.integerValue < -35) {
//        return;
//    }

    
    // Ok, it's in range - have we already seen it?
    if (![self.connectedPeripherals containsObject:peripheral]) {
        
        NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        [self.connectedPeripherals addObject: peripheral];
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    //[self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
         
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        //[self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@",service);
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //[self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        NSLog(@"Discovered characteristic %@", characteristic);
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            
            NSLog(@"Correct characteristic");
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        // We have, so show the data,
        if (self.dataReceived) self.dataReceived(self.data);
        self.data.length = 0;
        
        // Cancel our subscription to the characteristic
        //[peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        //[self.centralManager cancelPeripheralConnection:peripheral];
    }
    else{
        // Otherwise, just add the data on to what we already have
        [self.data appendData:characteristic.value];
    }
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
}


/** The peripheral letting us know whether our subscribe/
 ribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        // Notification has started
        if (characteristic.isNotifying) {
            NSLog(@"Notification began on %@", characteristic);
        }
        
        // Notification has stopped
        else {
            // so disconnect from the peripheral
            NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
    }
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    [self.connectedPeripherals removeObject:peripheral];
    
    // We're disconnected, so start scanning again
    //self.scanning = YES;
}


/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
//- (void)cleanup
//{
//    // Don't do anything if we're not connected
//    if (!self.discoveredPeripheral.state == CBPeripheralStateConnected) {
//        return;
//    }
//    
//    // See if we are subscribed to a characteristic on the peripheral
//    if (self.discoveredPeripheral.services != nil) {
//        for (CBService *service in self.discoveredPeripheral.services) {
//            if (service.characteristics != nil) {
//                for (CBCharacteristic *characteristic in service.characteristics) {
//                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
//                        if (characteristic.isNotifying) {
//                            // It is notifying, so unsubscribe
//                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
//                            
//                            // And we're done.
//                            return;
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
//    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
//}

-(void)setScanning:(BOOL)scanning{
    _scanning = scanning;
    if (scanning) {
        if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
            
            // TO DO: Find way to make this @NO without messing up the app because this wastes battery life
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                        options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
            NSLog(@"Scanning started");
            self.shouldStartScanning = NO;
        }
        else{
            self.shouldStartScanning = YES;
        }
    }
    else{
        self.shouldStartScanning = NO;
        [self.centralManager stopScan];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices{
    self.data.length = 0;
}

@end
