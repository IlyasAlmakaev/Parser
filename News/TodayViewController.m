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
#import "ParserViewController.h"


@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel *titleNews;
@property (weak, nonatomic) IBOutlet UILabel *dateNews;
@property (weak, nonatomic) IBOutlet UIImageView *imageNews;

/*@property (strong, nonatomic) ParserViewController *parserViewController;
@property (strong, nonatomic) UINavigationController *parserNavigationController;
@property (strong, nonatomic) NSString *reference;*/

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.preferredContentSize = CGSizeMake(0, 102);
    
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    [self parse];
    completionHandler(NCUpdateResultNewData);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   /* self.parserViewController = [[ParserViewController alloc] init];
    
    self.parserViewController.reference = self.reference;
    
    self.parserNavigationController = [[UINavigationController alloc] initWithRootViewController:self.parserViewController];
    [self presentViewController:self.parserNavigationController animated:YES completion:nil];*/
    NSLog(@"Go to full news");
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
         
         TFHppleElement *elements = [nodes objectAtIndex:0];

         TFHppleElement *element = [elements firstChildWithClassName:@"wraps out-topic"];
             
         self.titleNews.text = [[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"].text;
             
         NSString *dateString = [[element firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
         self.dateNews.text = [dateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             
         NSString *imageString = [[[[elements firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"] objectForKey:@"src"];
         [self.imageNews setImageWithURL:[NSURL URLWithString:imageString]];
         
 //        self.reference = [[[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"] objectForKey:@"href"];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error.localizedDescription);
     }];
    
    [operation start];
}


@end
