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

@interface ParserTableViewController ()

@property (strong, nonatomic) NSMutableArray *title;

@end

@implementation ParserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ParserTableViewCell" bundle:nil] forCellReuseIdentifier:@"idCell"];

    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://live.goodline.info/guest"]];
    
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        TFHpple *parser = [[TFHpple alloc] initWithHTMLData:responseObject];
        
        //     self.title = (NSArray*)responseObject;
        
        //     [self.tableView reloadData];
        
        //     NSLog(@"%@", self.title);
        
        
        
        // Way for parsing
        
        NSString *titleXpathQueryString = @"//h2[@class='topic-title word-wrap']/a";
        
        NSArray *titleNodes = [parser searchWithXPathQuery:titleXpathQueryString];
        
        
        // Push parsing elements to arrays
        NSMutableArray *container = [[NSMutableArray alloc] initWithCapacity:0];
        for (TFHppleElement *element in titleNodes)
        {
            News *news = [[News alloc] init];
            [container addObject:news];
            
            news.title = [element text];
            
            self.title = container;
            
            [self.tableView reloadData];
            
            NSString *test = [self.title objectAtIndex:0];
            
            NSLog(@"%@", news.title);
        }

        
        
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", error.localizedDescription);
        
    }];
    
    [operation start];
    
    // Url for parsing
  /*  NSURL *Url = [NSURL URLWithString:@"http://live.goodline.info/guest"];
    NSData *HtmlData = [NSData dataWithContentsOfURL:Url];
    
    // Parser
    TFHpple *parser = [TFHpple hppleWithHTMLData:HtmlData];
    
    // Way for parsing
    NSString *titleXpathQueryString = @"//h2[@class='topic-title word-wrap']/a";
    NSArray *titleNodes = [parser searchWithXPathQuery:titleXpathQueryString];
    
    // Push parsing elements to arrays
    NSMutableArray *container = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in titleNodes)
    {
        News *news = [[News alloc] init];
        [container addObject:news];
        
        news.title = [element text];
        
        self.title = container;
        
        [self.tableView reloadData];
        
        NSString *test = [self.title objectAtIndex:0];

        NSLog(@"%@", news.title);
    }*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.title.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    ParserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCell"];
    
    if (cell == nil) {
        cell = [[ParserTableViewCell alloc] init]; // or your custom initialization
    }
    
    News *thisNews= [self.title objectAtIndex:indexPath.row];
    
    NSLog(@"%@", thisNews.title);
    
    [cell.titleLabel setText:thisNews.title];
    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102;
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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
