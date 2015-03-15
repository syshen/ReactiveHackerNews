//
//  InterfaceController.m
//  ReactiveHackerNews WatchKit Extension
//
//  Created by syshen on 3/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "InterfaceController.h"
#import "HNClient.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface NewsRowController: NSObject
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *titleLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *scoreLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *commentLabel;
@end

@implementation NewsRowController

@end

@interface InterfaceController()
@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic, weak) IBOutlet WKInterfaceTable *tableView;
@property (nonatomic, strong) RACSignal *fetchSignal;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    @weakify(self);
    [[[HNClient sharedClient] topStories] subscribeNext:^(NSArray *top100) {
        NSArray *top10 = [top100 subarrayWithRange:NSMakeRange(0, 10)];
    
        @strongify(self);
        self.stories = [NSMutableArray array];
        
        NSMutableArray *storySignals = [NSMutableArray array];
        for (NSNumber *storyId in top10) {
            [storySignals addObject:[[[HNClient sharedClient] itemWithIdentity:storyId.integerValue] map:^id(NSDictionary *response) {
                @strongify(self);
                [self.stories addObject:response];
                
                return @(YES);
            }]];
            
        }
        
        if (storySignals.count) {
            self.fetchSignal = [RACSignal combineLatest:storySignals];
            [[self.fetchSignal deliverOnMainThread] subscribeNext:^(id x) {
                @strongify(self);
                [self reloadTableView];
            } error:^(NSError *error) {
                @strongify(self);
                [self showError];
            }];
        }
        
    }];
}

- (void) reloadTableView {

    [self.tableView setNumberOfRows:self.stories.count withRowType:@"default"];
    for (NSInteger idx = 0; idx < self.stories.count; idx++) {
        NewsRowController *row = [self.tableView rowControllerAtIndex:idx];

        NSDictionary *story = self.stories[idx];
        [row.titleLabel setText:story[@"title"]];
        [row.scoreLabel setText:[NSString stringWithFormat:@"%d", (int)[story[@"score"] intValue]]];
        [row.commentLabel setText:[NSString stringWithFormat:@"%d", (int)[story[@"kids"] count]]];
    }
    
}

- (void) showError {
    [self.tableView setNumberOfRows:1 withRowType:@"default"];
    NewsRowController *row = [self.tableView rowControllerAtIndex:0];
    [row.titleLabel setText:@"Cannot load"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



