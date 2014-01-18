//
//  MHViewController.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHViewController.h"
#import "MHBeacon.h"
#import "MHBeaconData.h"

@interface MHViewController ()
{
    MHBeacon *beacon;
}

@end

@implementation MHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    beacon = [MHBeacon beacon];
    [beacon setAdvertisedData: [MHBeaconData beaconDataWithLocalNameKey:@"Test" serviceUUIDKey:MHServiceDiscover]];
    beacon.didDiscoverPeripheral = ^void(CBPeripheral *peripheral, NSDictionary *advertisementData,NSNumber *RSSI){
        NSLog(@"%@",RSSI);
    };
    
    [beacon run];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
