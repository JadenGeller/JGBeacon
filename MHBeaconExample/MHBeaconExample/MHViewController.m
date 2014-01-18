//
//  MHViewController.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHViewController.h"
#import "MHSyncBeacon.h"
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
    MHBeaconData *data = [MHBeaconData beaconData];
    
    data.localNameKey = @"Hi";
    data.serviceUUIDsKey = @[@"4902FB43-3A20-4835-88FB-5C2A269579DD"];
    beacon.advertisedData = data;
    
    [beacon run];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
