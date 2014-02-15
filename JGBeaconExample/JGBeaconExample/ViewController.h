//
//  ViewController.h
//  JGBeaconExample
//
//  Created by Jaden Geller on 1/20/14.
//
//

#import <UIKit/UIKit.h>
#import "JGBeacon.h"

@interface ViewController : UIViewController <JGBeaconDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
