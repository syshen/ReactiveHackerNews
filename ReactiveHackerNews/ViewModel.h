//
//  ViewModel.h
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewModel : NSObject

@property (nonatomic, readonly) RACCommand *refreshCommand;

@end
