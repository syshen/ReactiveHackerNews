//
//  CardView.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "CardView.h"
@interface CardView()
@property (nonatomic, strong) StoryViewModel *viewModel;
@end
@implementation CardView

- (void) awakeFromNib {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // Corner Radius
    self.layer.cornerRadius = 10.0;
    
}

- (void)bindViewModel:(StoryViewModel *)viewModel {
    self.viewModel = viewModel;
 
    @weakify(self);

    RAC(self.titleLabel, font) = [[RACObserve(self.viewModel, title) filter:^BOOL(id value) {
        return value != nil;
    }] map:^id(NSString *title) {
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Bold" size:20]}];
        if (size.width > (self.titleLabel.frame.size.width * 2))
            return [UIFont fontWithName:@"AvenirNext-Bold" size:16];
        else
            return [UIFont fontWithName:@"AvenirNext-Bold" size:20];
    }];
    
    [[[RACObserve(self.viewModel, title) deliverOnMainThread] filter:^BOOL(id value) {
        return value!=nil;
    }] subscribeNext:^(NSString *title) {
        @strongify(self);
        self.titleLabel.text = title;
    }];
    
    RAC(self.authorLabel, text) = [RACObserve(self.viewModel, author) deliverOnMainThread];
//    RAC(self.dateLabel, text) = [RACObserve(self.viewModel, date) deliverOnMainThread];
    RAC(self.contextTextView, text) = [RACObserve(self.viewModel, content) deliverOnMainThread];
    RAC(self.commentLabel, text) = [[RACObserve(self.viewModel, commentCount) map:^id(NSNumber *value) {
        return [NSString stringWithFormat:@"%d", value.intValue];
    }] deliverOnMainThread];
    RAC(self.scoreLabel, text) = [[RACObserve(self.viewModel, score) map:^id(NSNumber *value) {
        return [NSString stringWithFormat:@"%d", value.intValue];
    }] deliverOnMainThread];
    
    [self.viewModel.loadStoryCommand execute:nil];

}

@end