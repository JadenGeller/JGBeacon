//
//  ViewController.m
//  JGBeaconExample
//
//  Created by Jaden Geller on 1/20/14.
//
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) JGBeacon *beacon;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.beacon = [JGBeacon beacon];
    self.beacon.delegate = self;
    self.beacon.running = JGBeaconSendingAndReceiving;
 
}

-(void)receivedData:(NSData *)data{
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",self.textView.text,[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
}

-(void)connectedToBeacon:(NSUUID *)identifier{
    
}

-(void)disconnectedFromBeacon:(NSUUID *)identifier{
    
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
