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
    [self.dataToSend addObject:data];
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        if (!self.peripheralManager.isAdvertising) {
            [self startAdvertising];
        }
    }
    else{
        self.waitingToSend = YES;
    }
}

-(void)startAdvertising{
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
}

-(void)stop{
    [self.peripheralManager stopAdvertising];
}

- (void)sendData
{
    NSLog(@"%@",self.dataToSend);
    BOOL stillSending = self.sendDataIndex < self.currentData.length;
    
    if (stillSending) {
        while ([self keepSending]);
    }
    
    if (!stillSending) {
        if ([self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
            
            [self.dataToSend removeObjectAtIndex:0];
            if (self.dataToSend.count > 0)
            {
                self.sendDataIndex = 0;
                [self sendData];
            }
        }

    }
}

-(BOOL)keepSending{
    NSInteger amountToSend = self.currentData.length - self.sendDataIndex;
    if (amountToSend > BT_DATA_SIZE_LIMIT) amountToSend = BT_DATA_SIZE_LIMIT;
    
    NSData *chunk = [NSData dataWithBytes:self.currentData.bytes+self.sendDataIndex length:amountToSend];
    
    if ([self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
        self.sendDataIndex += amountToSend;
        return YES;
    }
    else{
        return NO;
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}

@end
