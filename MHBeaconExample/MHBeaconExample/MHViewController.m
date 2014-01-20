//
//  MHViewController.m
//  MHBeaconExample
//
//  Created by Jaden Geller on 1/20/14.
//
//

#import "MHViewController.h"
#import "BTBeacon.h"

@interface MHViewController ()

@property (nonatomic) BTBeacon *beacon;

@end

@implementation MHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.beacon = [BTBeacon beacon];
    self.beacon.running = BTBeaconSendingAndReceiving;
    
    MHViewController __block *blockself = self;
    self.beacon.dataReceived = ^void (NSData *data){
        blockself.textView.text = [NSString stringWithFormat:@"%@\n%@",blockself.textView.text,[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendPress:(id)sender {
    [self.beacon queueDataToSend:[self.textField.text dataUsingEncoding:NSUTF8StringEncoding]];
    self.textField.text = @"";
}

-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    self.bottomSpacing.constant = keyboardFrameBeginRect.size.height;
}

-(void)keyboardWillHide:(NSNotification*)notification{
    self.bottomSpacing.constant = 0;
}

@end
