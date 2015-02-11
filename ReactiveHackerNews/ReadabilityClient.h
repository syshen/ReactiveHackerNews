//
//  ReadabilityClient.h
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ReadabilityClient : AFHTTPRequestOperationManager

+ (instancetype) sharedClient;

- (RACSignal*) contentForUrl:(NSString*)urlString;

@end
