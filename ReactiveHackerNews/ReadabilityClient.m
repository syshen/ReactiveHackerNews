//
//  ReadabilityClient.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "ReadabilityClient.h"
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import <AFNetworking2-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>


static NSString * apiKey = @"2d5e41f25276913e37f21615e91ae67f37b31848";

@interface ReadabilityClient()
@end

@implementation ReadabilityClient

+ (instancetype) sharedClient {
    static ReadabilityClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[ReadabilityClient alloc] init];
    });
    return client;
}

- (instancetype) init {
    self = [super initWithBaseURL:[NSURL URLWithString:@"http://readability.com/api/content/v1/"]];

    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    self.responseSerializer = responseSerializer;

    return self;
}

- (RACSignal*) contentForUrl:(NSString *)urlString {
    static NSString *endpoint = @"parser";
    return [[[self rac_GET:endpoint parameters:@{@"url": urlString, @"token": apiKey}] reduceEach:^id (AFHTTPRequestOperation *op, NSDictionary *response){
        return response;
    }] deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
}

@end
