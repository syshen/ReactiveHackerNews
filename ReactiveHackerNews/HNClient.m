//
//  HNClient.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "HNClient.h"
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import <AFNetworking2-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>

@interface HNClient ()
@end

@implementation HNClient

+ (instancetype) sharedClient {

    static HNClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL * apiURL = [[NSURL URLWithString:@"https://hacker-news.firebaseio.com"] URLByAppendingPathComponent:@"v0"];
        client = [[HNClient alloc] initWithBaseURL: apiURL];
        
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        client.responseSerializer = responseSerializer;
        
#ifdef DEBUG
        [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
        [[AFNetworkActivityLogger sharedLogger] startLogging];
#endif
        
    });
    return client;
}

- (RACSignal*) maxItemIdentity {
    return [[[self rac_GET:@"maxitem.json" parameters:nil] reduceEach:^id(AFHTTPRequestOperation *op, NSString * response) {
        return response;
    }] deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
}

- (RACSignal*) topStories {
    return [[[self rac_GET:@"topstories.json" parameters:nil] reduceEach:^id(AFHTTPRequestOperation *op, NSArray * response) {
        return response;
    }] deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
}

- (RACSignal*) itemWithIdentity:(NSInteger)identity {
    NSString *endpoint = [NSString stringWithFormat:@"item/%ld.json", identity];
    return [[[self rac_GET:endpoint parameters:nil] reduceEach:^id (AFHTTPRequestOperation *op, NSDictionary *response) {
        return response;
    }] deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
}

- (RACSignal*) userWithIdentity:(NSString *)userId {
    NSString *endpoint = [NSString stringWithFormat:@"user/%@.json", userId];
    return [[[self rac_GET:endpoint parameters:nil] reduceEach:^id (AFHTTPRequestOperation *op, NSDictionary *response) {
        return response;
    }] deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
}
@end
