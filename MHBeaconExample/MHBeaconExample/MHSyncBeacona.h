//
//  MHSyncBeacon.h
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface MHSyncBeacon : NSObject <CBPeripheralManagerDelegate, CBCentralManagerDelegate>

@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *messages;

@end
