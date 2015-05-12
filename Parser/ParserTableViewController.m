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

@end

@implementation ParserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Новости";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ParserTableViewCell" bundle:nil] forCellReuseIdentifier:@"idCell"];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    [refresh addTarget:self action:@selector(parse) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self parse];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    News *thisNews= [self.newsContent objectAtIndex:indexPath.row];
    
    [cell.titleLabel setText:thisNews.title];
    cell.dateLabel.text = [thisNews.date stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [cell.imageLabel setImageWithURL:[NSURL URLWithString:thisNews.image]];

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
    
    News *thisNews= [self.newsContent objectAtIndex:indexPath.row];
    self.parserViewController.reference = thisNews.reference;
    
    self.parserNavigationController = [[UINavigationController alloc] initWithRootViewController:self.parserViewController];
    [self presentViewController:self.parserNavigationController animated:YES completion:nil];
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
        
        // Push parsing elements to arrays
        NSMutableArray *container = [[NSMutableArray alloc] initWithCapacity:0];
        for (TFHppleElement *elements in nodes)
        {
            News *news = [[News alloc] init];
            [container addObject:news];
            
            TFHppleElement *element = [elements firstChildWithClassName:@"wraps out-topic"];
            
            news.title = [[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"].text;
            
            news.date = [[element firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
            
            news.image = [[[[elements firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"] objectForKey:@"src"];
            
            news.reference = [[[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"] objectForKey:@"href"];
            
            self.newsContent = container;
            
            [self.tableView reloadData];
            [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.5];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    [operation start];
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
