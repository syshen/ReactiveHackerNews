//
//  StoryViewModelTests.m
//  ReactiveHackerNews
//
//  Created by syshen on 3/3/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "HNClient.h"
#import "ReadabilityClient.h"
#import "StoryViewModel.h"

@interface StoryViewModelTests : XCTestCase

@end

@implementation StoryViewModelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNormalReturn {
    id HNClientMock = OCMPartialMock([HNClient sharedClient]);
    id RAClientMock = OCMPartialMock([ReadabilityClient sharedClient]);
    
    NSDictionary *HNRtn = @{@"by":@"andrewbarba",
                            @"descendants":@12,
                            @"id":@9135641,
                            @"kids":@[@9135772,@9135785],
                            @"score":@35,
                            @"text":@"",
                            @"time":@1425346972,
                            @"title":@"Io.js is one step closer to ARM64",
                            @"type":@"story",
                            @"url":@"https://github.com/iojs/io.js/blob/v1.x/CHANGELOG.md#2015-03-02-version-143-rvagg"
                            };
    OCMStub([HNClientMock itemWithIdentity:1000]).andReturn([RACSignal return:HNRtn]);
    
    NSDictionary *RARtn = @{
                            @"domain": @"patrick.georgi-clan.de",
                            @"next_page_id": [NSNull null],
                            @"url": @"http://patrick.georgi-clan.de/2015/02/17/intel-boot-guard/",
                            @"short_url": @"http://rdd.me/miee7j7a",
                            @"author": [NSNull null],
                            @"excerpt": @"<<excerpt>>",
                            @"direction": @"ltr",
                            @"word_count": @1118,
                            @"total_pages": @0,
                            @"content": @"a lot of content here",
                            @"date_published": @"2015-02-17 15:04:35",
                            @"dek": [NSNull null],
                            @"lead_image_url": [NSNull null],
                            @"title": @"Intel Boot Guard",
                            @"rendered_pages": @1};
    OCMStub([RAClientMock contentForUrl:[OCMArg any]]).andReturn([RACSignal return:RARtn]);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Content is loaded"];
    StoryViewModel *viewModel = [[StoryViewModel alloc] initWithIdentity:1000];
    
    [[viewModel.loadContentCommand.executionSignals flatten]
     subscribeNext:^(id x) {
        XCTAssert(viewModel.content, @"Readability content is not set");
        XCTAssert(([viewModel.content isEqualToString:@"<<excerpt>>"]), @"Readability response is not expected");
        [expectation fulfill];
    }];
    
    [[viewModel.loadStoryCommand execute:nil] subscribeNext:^(id x) {
        XCTAssert([viewModel.title isEqualToString:@"Io.js is one step closer to ARM64"], @"HN API response is not expected");
        XCTAssert([viewModel.date isEqualToString:@"09:42 03/03"], @"The date time format is wrong");
        XCTAssert([viewModel.url isEqualToString:HNRtn[@"url"]], @"URL is not expected");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Cannot be error");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


@end
