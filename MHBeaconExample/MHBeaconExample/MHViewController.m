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

@end

@implementation MHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    MHBeacon *beacon = [MHBeacon scheduledBeacon];
    [beacon setAdvertisedData:[MHBeaconData beaconDataWithLocalNameKey:@"Test" serviceUUIDKey:@"2F082B0F-4B5C-48C9-81A2-FF6EAA1FB521"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
