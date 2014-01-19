//
//  MHSendBeacon.h
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MHSendBeacon : NSObject

@property (nonatomic) NSMutableArray *sendQueue;
@property (nonatomic) BOOL advertising;

@end
