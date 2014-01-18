//
//  MHBeaconData.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHBeaconData.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface MHBeaconData ()

{
    NSMutableDictionary *data;
}

@end

@implementation MHBeaconData

-(void)setLocalNameKey:(NSString *)localNameKey{
    [self updateObject:localNameKey forKey:CBAdvertisementDataLocalNameKey];
}

-(void)setManufacturerDataKey:(NSData *)manufacturerDataKey{
    [self updateObject:manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
}

-(void)setServiceDataKey:(NSDictionary *)serviceDataKey{
    [self updateObject:serviceDataKey forKey:CBAdvertisementDataServiceDataKey];
}

-(void)setDataServiceUUIDsKey:(NSArray *)serviceUUIDsKey{
    [self updateObject:serviceUUIDsKey forKey:CBAdvertisementDataServiceUUIDsKey];
}

-(void)setDataOverflowServiceUUIDsKey:(NSArray *)overflowServiceUUIDsKey{
    [self updateObject:overflowServiceUUIDsKey forKey:CBAdvertisementDataOverflowServiceUUIDsKey];
}

-(void)setDataTxPowerLevelKey:(NSNumber *)txPowerLevelKey{
    [self updateObject:txPowerLevelKey forKey:CBAdvertisementDataTxPowerLevelKey];
}

-(void)setDataIsConnectable:(NSNumber *)isConnectable{
    [self updateObject:isConnectable forKey:CBAdvertisementDataIsConnectable];
}

-(void)setDataSolicitedServiceUUIDsKey:(NSArray *)solicitedServiceUUIDsKey{
    [self updateObject:solicitedServiceUUIDsKey forKey:CBAdvertisementDataSolicitedServiceUUIDsKey];
}

-(void)updateObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (anObject) [data setObject:anObject forKey:aKey];
    else [data removeObjectForKey:aKey];
}

-(NSString*)localNameKey{
    return data[CBAdvertisementDataLocalNameKey];
}

-(NSData*)manufacturerDataKey{
    return data[CBAdvertisementDataManufacturerDataKey];
}

-(NSDictionary*)serviceDataKey{
    return data[CBAdvertisementDataServiceDataKey];
}

-(NSArray*)serviceUUIDsKey{
    return data[CBAdvertisementDataServiceUUIDsKey];
}

-(NSArray*)overflowServiceUUIDsKey{
    return data[CBAdvertisementDataOverflowServiceUUIDsKey];
}

-(NSNumber*)txPowerLevelKey{
    return data[CBAdvertisementDataTxPowerLevelKey];
}

-(NSNumber*)isConnectable{
    return data[CBAdvertisementDataIsConnectable];
}

-(NSArray*)solicitedServiceUUIDsKey{
    return data[CBAdvertisementDataSolicitedServiceUUIDsKey];
}

-(NSDictionary*)dictionaryValue{
    return data.copy;
}

@end
