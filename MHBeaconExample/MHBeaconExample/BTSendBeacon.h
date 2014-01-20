//
//  BTSendBeacon.h
//  BTLE Transfer
//
//  Created by Jaden Geller on 1/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTSendBeacon : NSObject

@property (nonatomic) BOOL advertising;
@property (nonatomic, readonly) BOOL sending;

-(void)queueDataToSend:(NSData*)data;

+(BTSendBeacon*)beacon;

@end
