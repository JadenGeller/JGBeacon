//
//  MHViewController.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/18/14.
//
//

#import "MHViewController.h"
#import "MHSyncBeacon.h"

@interface MHViewController ()

@property (nonatomic) MHSyncBeacon *beacon;

@end

@implementation MHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.beacon = [MHSyncBeacon beacon];
    self.beacon.dataReceived = ^void (NSData *data){
        NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    };
    [self.beacon sendData:[@"hey" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.beacon sendData:[@"HOW ARE YOU DOING TODAY ARENT YOU DOING WELL CUZ ITS SATURDAY" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.beacon sendData:[@"WEll actulaly I DIDNT know THAT cuz NO SLEeep !!! anhghhahh!!!!" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.beacon sendData:[@"yo" dataUsingEncoding:NSUTF8StringEncoding]];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
