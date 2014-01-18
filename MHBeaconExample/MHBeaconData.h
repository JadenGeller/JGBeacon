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
@property (nonatomic) NSArray *dataServiceUUIDsKey;
@property (nonatomic) NSArray *dataOverflowServiceUUIDsKey;
@property (nonatomic) NSNumber *dataTxPowerLevelKey;
@property (nonatomic) NSNumber *dataIsConnectable;
@property (nonatomic) NSArray *dataSolicitedServiceUUIDsKey;

@property (nonatomic, readonly) NSDictionary *dictionaryValue;

@end
