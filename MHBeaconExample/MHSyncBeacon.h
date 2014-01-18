//
//  MHSyncBeacon.h
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import <Foundation/Foundation.h>

@interface MHSyncBeacon : NSObject 

-(void)sendData:(NSData*)data;
@property (nonatomic, copy) void (^dataReceived)(NSData *data);

-(id)init;
+(MHSyncBeacon*)beacon;

@end
