//
//  ParserTableViewController.m
//  Parser
//
//  Created by Admin on 06.05.15.
//  Copyright (c) 2015 intent. All rights reserved.
//

#import "ParserTableViewController.h"
#import "TFHpple.h"
#import "News.h"
#import "ParserTableViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "ParserViewController.h"

@interface ParserTableViewController ()

@property (strong, nonatomic) NSMutableArray *newsContent;
@property (strong, nonatomic) ParserViewController *parserViewController;
@property (strong, nonatomic) UINavigationController *parserNavigationController;
@property int pageNumber;
@property (strong, nonatomic) AppDelegate *appD;
@property News *news;

@end

@implementation ParserTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.newsContent = [[NSMutableArray alloc] init];
        self.pageNumber = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Новости";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ParserTableViewCell" bundle:nil] forCellReuseIdentifier:@"idCell"];
    
    self.appD = [[AppDelegate alloc] init];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    [refresh addTarget:self action:@selector(parse) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self parse];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.news = [NSEntityDescription insertNewObjectForEntityForName:@"News"
                                               inManagedObjectContext:self.appD.managedOC];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.newsContent.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCell"];
    
    if (cell == nil)
    {
        cell = [[ParserTableViewCell alloc] init]; // or your custom initialization
    }
    
    self.news = [self.newsContent objectAtIndex:indexPath.row];
    
    [cell.titleLabel setText:self.news.title];
    cell.dateLabel.text = [self.news.date stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [cell.imageLabel setImageWithURL:[NSURL URLWithString:self.news.image]];

    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.parserViewController = [[ParserViewController alloc] init];
    
    self.news = [self.newsContent objectAtIndex:indexPath.row];
    self.parserViewController.reference = self.news.reference;
    
    self.parserNavigationController = [[UINavigationController alloc] initWithRootViewController:self.parserViewController];
    [self presentViewController:self.parserNavigationController animated:YES completion:nil];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];
    if(indexPath.row == totalRow -1)
    {
        [self parse];
        self.pageNumber += 1;
    }
}

- (void)parse
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.goodline.info/guest/page%i", (self.pageNumber)]]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         TFHpple *parser = [[TFHpple alloc] initWithHTMLData:responseObject];
         
         NSString *pathQueryString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
         
         NSArray *nodes = [parser searchWithXPathQuery:pathQueryString];
         
         for (TFHppleElement *elements in nodes)
         {
             self.news = [NSEntityDescription insertNewObjectForEntityForName:@"News"
                                                       inManagedObjectContext:self.appD.managedOC];
             
             TFHppleElement *element = [elements firstChildWithClassName:@"wraps out-topic"];
             
             self.news.title = [[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"].text;
             
             self.news.date = [[element firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
             
             self.news.image = [[[[elements firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"] objectForKey:@"src"];
             
             self.news.reference = [[[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"] objectForKey:@"href"];
             
             [self.newsContent addObject:self.news];
         }
         
         [self.tableView reloadData];
         [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.5];
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error.localizedDescription);
     }];
    
    [operation start];
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

@end
