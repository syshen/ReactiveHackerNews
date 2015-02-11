//
//  ViewModel.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "ViewModel.h"
#import "HNClient.h"

@interface ViewModel ()
@property (nonatomic, strong) RACCommand *refreshCommand;
@end

@implementation ViewModel

- (RACCommand*) refreshCommand {
    if (_refreshCommand)
        return _refreshCommand;
    
    _refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[HNClient sharedClient] topStories];
    }];
    
    return _refreshCommand;
}
@end
