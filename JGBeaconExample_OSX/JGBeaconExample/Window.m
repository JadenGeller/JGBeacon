//
//  Window.m
//  JGBeaconExample
//
//  Created by Jaden Geller on 2/15/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "Window.h"

@interface Window ()

@property (nonatomic) JGBeacon *beacon;

@end

@implementation Window

- (IBAction)sendClick:(id)sender {
    [self.beacon queueDataToSend:[self.sendText.stringValue dataUsingEncoding:NSUTF8StringEncoding]];
    self.sendText.stringValue = @"";

}

-(void)setup{
    self.beacon = [JGBeacon beacon];
    self.beacon.delegate = self;
    self.beacon.running = JGBeaconSendingAndReceiving;

}

-(void)receivedData:(NSData *)data{
    
    self.textView.string = [NSString stringWithFormat:@"%@\n%@",self.textView.string,[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    
}

-(void)connectedToBeacon:(NSUUID *)identifier{
    
}

-(void)disconnectedFromBeacon:(NSUUID *)identifier{
    
}


@end
