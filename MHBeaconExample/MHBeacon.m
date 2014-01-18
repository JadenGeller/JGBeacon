//
//  MHBeacon.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHBeacon.h"

@interface MHBeacon ()

@property (nonatomic) CBPeripheralManager *peripheralManager;

@end

@implementation MHBeacon

@synthesize peripheralManager = _peripheralManager;

-(CBPeripheralManager*)peripheralManager{
    if (!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return _peripheralManager;
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
}

-(void)setAdvertisedData:(MHBeaconData *)advertisedData{
    if (self.advertising) { // Stop advertising during change
        self.advertising = NO;
        _advertisedData = advertisedData;
        self.advertising = YES;
    }
    else{
        _advertisedData = advertisedData;
    }
}

-(void)setAdvertising:(BOOL)advertising{
    if (!advertising) {
        [self.peripheralManager stopAdvertising];
        _advertising = NO;
    }
    else if (self.advertisedData) {
        [self.peripheralManager startAdvertising:self.advertisedData.dictionaryValue];
        _advertising = YES;
    }
}

@end
