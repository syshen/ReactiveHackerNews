//
//  HNClient.h
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>


@interface HNClient : AFHTTPRequestOperationManager

+ (instancetype) sharedClient;

- (RACSignal*) maxItemIdentity;
- (RACSignal*) topStories;
- (RACSignal*) itemWithIdentity:(NSInteger)identity;
//- (RACSignal*) userWithIdentity:(NSString*)userId;

@end
