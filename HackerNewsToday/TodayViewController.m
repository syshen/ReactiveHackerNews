//
//  TodayViewController.m
//  HackerNewsToday
//
//  Created by syshen on 3/8/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "TodayViewController.h"
#import "HNClient.h"
#import "RHNTodayCell.h"
#import <NotificationCenter/NotificationCenter.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic, strong) RACSignal *fetchSignal;
@property (nonatomic, weak) IBOutlet UILabel *errorPrompt;
@end

static CGFloat kCellHeight = 70.0f;

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.preferredContentSize = CGSizeMake(0, 0);
    [self loadArchivedData];
    self.preferredContentSize = CGSizeMake(0, self.stories.count * kCellHeight);
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView registerNib:[UINib nibWithNibName:@"RHNTodayCell" bundle:nil] forCellReuseIdentifier:@"RHNTodayCell"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void) loadArchivedData {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger idx = 0; idx < 10; idx++) {
        NSString *filename = [NSString stringWithFormat:@"story%02d", (int)idx];
        NSURL *fileURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:filename];

        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        if (data) {
            NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [array addObject:dict];
        }
    }
    self.stories = [NSMutableArray arrayWithArray:array];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stories.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RHNTodayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RHNTodayCell" forIndexPath:indexPath];
    NSDictionary *story = self.stories[indexPath.row];
    cell.titleLabel.text = story[@"title"];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d", (int)[story[@"score"] integerValue]];
    cell.commentLabel.text = [NSString stringWithFormat:@"%d", (int)[story[@"kids"] count]];
    cell.nameLabel.text = story[@"by"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *story = self.stories[indexPath.row];
    [self.extensionContext openURL:[NSURL URLWithString:story[@"url"]] completionHandler:nil];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    NSLog(@"ask to load new content");
    completionHandler(NCUpdateResultNewData);
    
    @weakify(self);
    [[[HNClient sharedClient] topStories] subscribeNext:^(NSArray *topStories) {
        
        @strongify(self);
        NSArray *top5 = [topStories subarrayWithRange:NSMakeRange(0, 5)];
        NSMutableArray *storySignals = [NSMutableArray array];
        NSInteger index = 0;
        for (NSNumber *storyId in top5) {
            [storySignals addObject:[[[HNClient sharedClient] itemWithIdentity:storyId.integerValue] map:^id(NSDictionary *response) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:response];
                @strongify(self);
                
                NSString *filename = [NSString stringWithFormat:@"story%02d", (int)index];
                NSURL *fileURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:filename];
                [data writeToURL:fileURL atomically:YES];
                
                return @(YES);
            }]];
            
            index ++;
        }
        
        if (storySignals.count) {
            self.fetchSignal = [RACSignal combineLatest:storySignals];
            [self.fetchSignal  subscribeNext:^(id x) {
                @strongify(self);
                self.errorPrompt.hidden = YES;
                [self loadArchivedData];
                self.preferredContentSize = CGSizeMake(0, storySignals.count * kCellHeight);
                [self.tableView reloadData];
                completionHandler(NCUpdateResultNewData);
            } error:^(NSError *error) {
                NSLog(@"failed to load: %@", error);
                self.errorPrompt.hidden = NO;
                completionHandler(NCUpdateResultFailed);
            }];
        } else {
            completionHandler(NCUpdateResultNoData);
        }
    }];
    

}

@end
