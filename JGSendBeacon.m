//
//  JGSendBeacon.m
//  JGBeaconExample
//
//  Created by Jaden Geller on 1/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "JGSendBeacon.h"
#import "TransferService.h"

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif

#define NOTIFY_MTU      20

@interface JGSendBeacon () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *theData;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (nonatomic) NSMutableArray *dataToSend;

@property (nonatomic) BOOL shouldStartAdvertising;
@property (nonatomic) NSMutableArray *subscribers;

@end

@implementation JGSendBeacon

+(JGSendBeacon*)beacon{
    return [[JGSendBeacon alloc]init];
}

-(id)init{
    if (self = [super init]) {
        // Start up the CBPeripheralManager
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        _subscribers = [NSMutableArray array];
        _dataToSend = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Peripheral Methods

/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        
        // We're in CBPeripheralManagerStatePoweredOn state...
        NSLog(@"self.peripheralManager powered on.");
        
        // ... so build our service.
        
        // Start with the CBMutableCharacteristic
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                         properties:CBCharacteristicPropertyNotify
                                                                              value:nil
                                                                        permissions:CBAttributePermissionsReadable];
        
        // Then the service
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                           primary:YES];
        
        // Add the characteristic to the service
        transferService.characteristics = @[self.transferCharacteristic];
        
        // And add it to the peripheral manager
        [self.peripheralManager addService:transferService];
        
        if (self.shouldStartAdvertising) {
            self.advertising = YES;
        }

    }
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    [self.subscribers addObject:central];
    
    // Start sending
    if (!self.sending) [self sendData];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
    
    [self.subscribers removeObject:central];

}

-(void)sendData{
    if (self.dataToSend.count > 0 || self.theData) {
        _sending = YES;
        
        if (!self.theData) {
            [self sendNewData];
        }
        else{
            [self continueSendingData];
        }
    }
    else{
        _sending = NO;
        NSLog(@"Done sending items");
    }
}

-(void)sendNewData{
    NSLog(@"Send new data");
    self.theData = self.dataToSend[0];
    [self.dataToSend removeObjectAtIndex:0];
    self.sendDataIndex = 0;
    [self continueSendingData];

}

- (void)continueSendingData
{
    while ([self sendPacket]);
    
    if (self.sendDataIndex >= self.theData.length) {
        // Message completely sent
        // Attempt sending EOM now
        
        if ([self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
            // Successfully sent EOM
            NSLog(@"Sent EOM");

            
            self.theData = nil;
            [self sendData];
        }
        else _sending = NO; // something went wrong sending the EOM
    }
    else _sending = NO; // something went wrong sending a packet
}

// Returns bool indicating success
-(BOOL)sendPacket{
    NSInteger amountToSend = self.theData.length - self.sendDataIndex;
    if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
    else if (amountToSend <= 0) return NO; // done sending, time for EOM
    
    NSData *chunk = [NSData dataWithBytes:self.theData.bytes+self.sendDataIndex length:amountToSend];
    NSLog(@"Sent packet: %@", chunk);

    if ([self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
        self.sendDataIndex += amountToSend;
        return YES;
    }
    else return NO; // will later get called again by peripheralManagerIsReadyToUpdateSubscribers
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    if (!self.sending) [self sendData];
}


-(void)setAdvertising:(BOOL)advertising{
    _advertising = advertising;
    if (advertising) {
        if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
            [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
            self.shouldStartAdvertising = NO;
        }
        else{
            self.shouldStartAdvertising = YES;
        }
    }
    else{
        self.shouldStartAdvertising = NO;
        [self.peripheralManager stopAdvertising];
    }
}

-(void)queueDataToSend:(NSData*)data{
    [self.dataToSend addObject:data];
    if (!self.sending && self.subscribers.count > 0) [self sendData];
}

@end
