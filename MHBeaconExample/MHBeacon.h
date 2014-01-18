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

typedef enum {MHNotRunning, MHAdvertising, MHSearching, MHRunning} MHRunningMode;

@interface MHBeacon : NSObject <CBPeripheralManagerDelegate, CBCentralManagerDelegate>

@property (nonatomic) MHBeaconData *advertisedData;

/*
 * Getter: Returns (advertising || searching)
 * Setter: Sets advertising and searching
 */
@property (nonatomic) MHRunningMode runningMode;

-(void)run;
-(void)stop;

@property (nonatomic) BOOL advertising;
@property (nonatomic) BOOL searching;

@property (nonatomic, readonly) BOOL ready;

+(MHBeacon*)beacon;
-(id)init;

@end
