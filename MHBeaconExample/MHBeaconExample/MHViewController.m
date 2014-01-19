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
{
    int num;
}

@property (nonatomic) MHSyncBeacon *beacon;

@end

@implementation MHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.beacon = [MHSyncBeacon beacon];
    
    __block MHViewController *blockSelf = self;
    self.beacon.dataReceived = ^void (NSData *data){
        blockSelf.textView.text = [NSString stringWithFormat:@"%@\n%@",blockSelf.textView.text,[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    };

    
}
- (IBAction)testPress:(id)sender {
    num++;
    [self.beacon sendData:[@"HELLO" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
