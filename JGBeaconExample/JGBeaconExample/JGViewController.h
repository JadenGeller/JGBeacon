//
//  JGViewController.h
//  JGBeaconExample
//
//  Created by Jaden Geller on 2/15/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGBeacon.h"

@interface JGViewController : UIViewController <JGBeaconDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
