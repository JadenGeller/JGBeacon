//
//  MHBeaconData.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHBeaconData.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation MHBeaconData

-(NSDictionary*)dictionaryValue{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.localNameKey) {
        [dictionary setObject:self.localNameKey forKey:CBAdvertisementDataLocalNameKey];
    }
    if (self.manufacturerDataKey) {
        [dictionary setObject:self.manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
    }
    if (self.serviceDataKey) {
        [dictionary setObject:self.manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
    }
    if (self.dataServiceUUIDsKey) {
        [dictionary setObject:self.manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
    }
    if (self.dataOverflowServiceUUIDsKey) {
        [dictionary setObject:self.manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
    }
    if (self.dataTxPowerLevelKey) {
        [dictionary setObject:self.manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
    }
    if (self.dataIsConnectable) {
        [dictionary setObject:self.manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
    }
    if (self.dataSolicitedServiceUUIDsKey) {
        [dictionary setObject:self.manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
    }
    if (self.manufacturerDataKey) {
        [dictionary setObject:self.manufacturerDataKey forKey:CBAdvertisementDataManufacturerDataKey];
    }
    
    return dictionary;
}

@end
