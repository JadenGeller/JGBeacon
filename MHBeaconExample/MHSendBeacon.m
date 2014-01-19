//
//  MHSendBeacon.m
//  MHBeaconExample
//

#import "MHSendBeacon.h"
#import "TransferService.h"

#define BT_DATA_SIZE_LIMIT 20

@interface MHSendBeacon () <CBPeripheralManagerDelegate>

@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (nonatomic) NSMutableArray *dataToSend;
@property (nonatomic, readonly) NSData *currentData;
@property (nonatomic) NSInteger sendDataIndex;
@property (nonatomic) BOOL waitingToSend;
@property (nonatomic) CBMutableService *transferService;

@end

@implementation MHSendBeacon

-(id)init{
    if (self = [super init]) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _dataToSend = [NSMutableArray array];
        _transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    }
    return self;
}

-(NSData*)currentData{
    return (NSData*)self.dataToSend[0];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn && peripheral) {
        NSLog(@"S - I'm ready to go!");

        if (!self.transferService) {
            self.transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
            self.transferService.characteristics = @[self.transferCharacteristic];
            [peripheral addService:self.transferService];
        }
        
        if (self.waitingToSend) {
            self.waitingToSend = NO;
            [self startAdvertising];
        }

    }
    else{
        //Should probably handle these cases
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    self.sendDataIndex = 0;
    [self sendData];
}

-(void)sendData:(NSData *)data{
    NSLog(@"You requested to send this data %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    [self.dataToSend addObject:data];
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"And we are ready for it");
        if (!self.peripheralManager.isAdvertising) {
            NSLog(@"Just a second");
            [self startAdvertising];
        }
    }
    else{
        NSLog(@"But you have to wait");
        self.waitingToSend = YES;
    }
}

-(void)startAdvertising{
    NSLog(@"S - I'm advertising--no adblock!.");
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
}

-(void)stop{
    NSLog(@"S - Who dood, what's with that adblock.");
    [self.peripheralManager stopAdvertising];
}

- (void)sendData
{
    NSLog(@"S - Ready to begin sending with count of %lu", (unsigned long)self.dataToSend.count);
    if (self.dataToSend.count > 0) {
        BOOL stillSending = self.sendDataIndex < self.currentData.length;
        
        if (stillSending) {
            NSLog(@"S - Sending packets pew pew pew");
            while ([self keepSending]);
        }
        
        if (!stillSending) {
            NSLog(@"S - I'll end that message for you dood");

            if ([self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
                NSLog(@"S - Ended successfully");

                [self.dataToSend removeObjectAtIndex:0];
                if (self.dataToSend.count > 0)
                {
                    NSLog(@"S - Time for another round");
                    self.sendDataIndex = 0;
                    [self sendData];
                }
            }
            
        }
    }
    else NSLog(@"S - Shucks, all out of data to send...");
}

-(BOOL)keepSending{
    NSInteger amountToSend = self.currentData.length - self.sendDataIndex;
    if (amountToSend > BT_DATA_SIZE_LIMIT) amountToSend = BT_DATA_SIZE_LIMIT;
    
    NSData *chunk = [NSData dataWithBytes:self.currentData.bytes+self.sendDataIndex length:amountToSend];
    
    NSLog(@"S - Will send this one");
    if ([self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
        NSLog(@"S - Did send this one");
        self.sendDataIndex += amountToSend;
        return YES;
    }
    else{
        NSLog(@"S - Fuck shit no that was bad.");
        return NO;
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    NSLog(@"S - Oops, messed up sending. I'll try again.");
    [self sendData];
}

@end
