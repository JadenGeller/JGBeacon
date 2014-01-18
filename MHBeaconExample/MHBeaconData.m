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

@property (nonatomic) NSMutableDictionary *data;

@end

@implementation MHBeaconData

-(NSMutableDictionary*)data{
    if (!_data) {
        _data = [NSMutableDictionary dictionary];
    }
    return _data;
}

-(void)setLocalNameKey:(NSString *)localNameKey{
    [self updateObject:localNameKey forKey:CBAdvertisementDataLocalNameKey];
}

-(void)setManufacturerDataKey:(NSData *)manufacturerDataKey{
    [self updateObject:manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
}

-(void)setServiceDataKey:(NSDictionary *)serviceDataKey{
    [self updateObject:serviceDataKey forKey:CBAdvertisementDataServiceDataKey];
}

-(void)setServiceUUIDsKey:(NSArray *)serviceUUIDsKey{
    [self updateObject:serviceUUIDsKey forKey:CBAdvertisementDataServiceUUIDsKey];
}

-(void)setOverflowServiceUUIDsKey:(NSArray *)overflowServiceUUIDsKey{
    [self updateObject:overflowServiceUUIDsKey forKey:CBAdvertisementDataOverflowServiceUUIDsKey];
}

-(void)setTxPowerLevelKey:(NSNumber *)txPowerLevelKey{
    [self updateObject:txPowerLevelKey forKey:CBAdvertisementDataTxPowerLevelKey];
}

-(void)setIsConnectable:(NSNumber *)isConnectable{
    [self updateObject:isConnectable forKey:CBAdvertisementDataIsConnectable];
}

-(void)setSolicitedServiceUUIDsKey:(NSArray *)solicitedServiceUUIDsKey{
    [self updateObject:solicitedServiceUUIDsKey forKey:CBAdvertisementDataSolicitedServiceUUIDsKey];
}

-(void)updateObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (anObject) [self.data setObject:anObject forKey:aKey];
    else [self.data removeObjectForKey:aKey];
}

-(NSString*)localNameKey{
    return self.data[CBAdvertisementDataLocalNameKey];
}

-(NSData*)manufacturerDataKey{
    return self.data[CBAdvertisementDataManufacturerDataKey];
}

-(NSDictionary*)serviceDataKey{
    return self.data[CBAdvertisementDataServiceDataKey];
}

-(NSArray*)serviceUUIDsKey{
    NSArray *test = self.data[CBAdvertisementDataServiceUUIDsKey];
    return test;
}

-(NSArray*)overflowServiceUUIDsKey{
    return self.data[CBAdvertisementDataOverflowServiceUUIDsKey];
}

-(NSNumber*)txPowerLevelKey{
    return self.data[CBAdvertisementDataTxPowerLevelKey];
}

-(NSNumber*)isConnectable{
    return self.data[CBAdvertisementDataIsConnectable];
}

-(NSArray*)solicitedServiceUUIDsKey{
    return self.data[CBAdvertisementDataSolicitedServiceUUIDsKey];
}

-(NSDictionary*)dictionaryValue{
    return self.data.copy;
}

-(void)setServiceUUIDKey:(NSString*)serviceUUIDKey{
    self.serviceUUIDsKey = @[[CBUUID UUIDWithString:serviceUUIDKey]];
}

-(id)initWithLocalNameKey:(NSString*)localNameKey serviceUUIDKey:(NSString*)serviceUUIDKey{
    if (self = [super init]) {
        self.localNameKey = localNameKey;
        [self setServiceUUIDKey:serviceUUIDKey];
    }
    return self;
}

+(MHBeaconData*)beaconDataWithLocalNameKey:(NSString*)localNameKey serviceUUIDKey:(NSString*)serviceUUIDKey{
    return [[MHBeaconData alloc] initWithLocalNameKey:localNameKey serviceUUIDKey:serviceUUIDKey];
}

@end
