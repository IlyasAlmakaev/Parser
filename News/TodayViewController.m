//
//  TodayViewController.m
//  News
//
//  Created by almakaev iliyas on 15.05.15.
//  Copyright (c) 2015 intent. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TFHpple.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"


@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UILabel *titleNews;
@property (weak, nonatomic) IBOutlet UILabel *dateNews;
@property (weak, nonatomic) IBOutlet UIImageView *imageNews;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.preferredContentSize = CGSizeMake(0, 102);
    [self parse];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)parse
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://live.goodline.info/guest"]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         TFHpple *parser = [[TFHpple alloc] initWithHTMLData:responseObject];
         
         NSString *pathQueryString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
         
         NSArray *nodes = [parser searchWithXPathQuery:pathQueryString];
         
         for (TFHppleElement *elements in nodes)
         {
             TFHppleElement *element = [elements firstChildWithClassName:@"wraps out-topic"];
             
             self.titleNews.text = [[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"].text;
             
        /*     self.news.title = [[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"].text;
             
             self.news.date = [[element firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
             
             self.news.image = [[[[elements firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"] objectForKey:@"src"];
             
             self.news.reference = [[[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"] objectForKey:@"href"];
             
             [self.newsContent addObject:self.news];*/
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error.localizedDescription);
     }];
    
    [operation start];
}


@end
