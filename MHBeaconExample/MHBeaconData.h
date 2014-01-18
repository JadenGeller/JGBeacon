//
//  MHBeaconData.h
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import <Foundation/Foundation.h>

@interface MHBeaconData : NSObject

@property (nonatomic) NSString *localNameKey;
@property (nonatomic) NSData *manufacturerDataKey;
@property (nonatomic) NSDictionary *serviceDataKey;
@property (nonatomic) NSArray *serviceUUIDsKey;
@property (nonatomic) NSArray *overflowServiceUUIDsKey;
@property (nonatomic) NSNumber *txPowerLevelKey;
@property (nonatomic) NSNumber *isConnectable;
@property (nonatomic) NSArray *solicitedServiceUUIDsKey;

@property (readonly) NSDictionary *dictionaryValue;

-(void)setServiceUUIDKey:(NSString*)serviceUUIDKey; // use uuidgen

-(id)initWithLocalNameKey:(NSString*)localNameKey serviceUUIDKey:(NSString*)serviceUUIDKey;
+(MHBeaconData*)beaconDataWithLocalNameKey:(NSString*)localNameKey serviceUUIDKey:(NSString*)serviceUUIDKey;

@end
