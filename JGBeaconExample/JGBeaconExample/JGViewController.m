//
//  JGViewController.m
//  JGBeaconExample
//
//  Created by Jaden Geller on 2/15/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGViewController.h"

@interface JGViewController ()

@property (nonatomic) JGBeacon *beacon;

@end

@implementation JGViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)receivedData:(NSData *)data{
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",self.textView.text,[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];

}

-(void)connectedToBeacon:(NSUUID *)identifier{
    
}

-(void)disconnectedFromBeacon:(NSUUID *)identifier{
    
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
