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

NSString * const kUUID = @"2F082B0F-4B5C-48C9-81A2-FF6EAA1FB521";

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
    [beacon setAdvertisedData:[MHBeaconData beaconDataWithLocalNameKey:@"Test" serviceUUIDKey:kUUID]];
    [beacon run];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
