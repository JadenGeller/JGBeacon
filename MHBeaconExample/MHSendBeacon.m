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
@property (nonatomic) NSData *dataToSend;
@property (nonatomic) NSInteger sendDataIndex;
@property (nonatomic) BOOL waitingToSend;

@end

@implementation MHSendBeacon

-(id)init{
    if (self = [super init]) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        transferService.characteristics = @[self.transferCharacteristic];
        [self.peripheralManager addService:transferService];
        
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
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    [self sendData];
}

-(void)sendData:(NSData *)data{
    self.dataToSend = data;
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self startAdvertising];
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
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {

        if ([self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
            
            //Successfully sent
            sendingEOM = NO;
        }
    }
    else{
        //Send data
        
        if (self.sendDataIndex < self.dataToSend.length) {
            // Still data to send
            
            while (YES) {
                
                // Make the next chunk
                
                // Work out how big it should be
                NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
                
                // Can't be longer than 20 bytes
                if (amountToSend > BT_DATA_SIZE_LIMIT) amountToSend = BT_DATA_SIZE_LIMIT;
                
                // Copy out the data we want
                NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
                
                if ([self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
                    // Sent segment successfully
                    
                    // Update index
                    self.sendDataIndex += amountToSend;
                    
                    if (self.sendDataIndex >= self.dataToSend.length) {
                        // Was last section; send an EOM
                        
                        // Set this so if the send fails, we'll send it next time
                        sendingEOM = YES;
                        
                        if ([self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil]) {
                            // It sent, so no need to send again
                            sendingEOM = NO;
                        }
                    }
                }
                else return; // Error, so let's quit and wait
                
            }
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}

@end
