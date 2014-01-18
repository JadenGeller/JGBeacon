//
//  MHBeacon.h
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MHBeaconData.h"

@interface MHBeacon : NSObject <CBPeripheralManagerDelegate, CBCentralManagerDelegate>

@property (nonatomic) MHBeaconData *advertisedData;
@property (nonatomic) NSString *serviceIdentifier;

@property (nonatomic) BOOL advertising;
@property (nonatomic) BOOL searching;

@end
