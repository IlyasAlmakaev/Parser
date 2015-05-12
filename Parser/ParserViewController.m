//
//  ParserViewController.m
//  Parser
//
//  Created by intent on 11/05/15.
//  Copyright (c) 2015 intent. All rights reserved.
//

#import "ParserViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "TFHpple.h"

@interface ParserViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *content;
@property int heightY;

@end

@implementation ParserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(back)];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.reference]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        TFHpple *parser = [[TFHpple alloc] initWithHTMLData:responseObject];
        
        NSString *pathQueryString = @"//div[@class='topic-content text']";
        
        NSArray *nodes = [parser searchWithXPathQuery:pathQueryString];
        
        TFHppleElement *node = nodes[0];
        
        NSMutableAttributedString *textNews = [[NSMutableAttributedString alloc] initWithString:@""];
        for (TFHppleElement *element in node.children)
        {
             if ([element.tagName isEqual:@"img"])
            {
                if (![textNews isEqual:@""])
                {
                    UITextView *contentText = [self buildText:textNews];
                    [self.content addSubview:contentText];
                    self.content.contentSize = CGSizeMake(self.view.frame.size.width, self.heightY);
                    
                    textNews = [[NSMutableAttributedString alloc] initWithString:@""];
                }
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.heightY, self.content.frame.size.width, self.content.frame.size.width*2/3)];
                imageView.contentMode = UIViewContentModeScaleToFill;
                [imageView setImageWithURL:[NSURL URLWithString:[element objectForKey:@"src"]]];
                
                [self.content addSubview:imageView];
                self.heightY += imageView.frame.size.height;
            }
            else
            {
                NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:@""];
                tempString = [self restructText:element];
                
                [textNews appendAttributedString:tempString];
            }
        }
        
        if (![textNews isEqual:@""])
        {
            UITextView *contentText = [self buildText:textNews];
            [self.content addSubview:contentText];
            self.content.contentSize = CGSizeMake(self.view.frame.size.width, self.heightY);
        } 
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    [operation start];
}

- (NSAttributedString *)restructText:(TFHppleElement *)node
{
    
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] initWithString:@""];
    if ([node isTextNode])
    {
        if ([node.parent.tagName characterAtIndex:0] == 'h')
        {
            return [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@\n", node.content]
                                                   attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:22.0f]}];
        }
        return [[NSAttributedString alloc] initWithString:node.content
                                               attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:20.0f]}];
    }
    else
    {
        if ([node hasChildren])
        {
            for (TFHppleElement *subNode in node.children)
            {
                if (![subNode.tagName isEqual:@"img"])
                    [resultString appendAttributedString:[self restructText: subNode]];
            }
        }
    }
    
    return resultString;
}

- (UITextView *)buildText: (NSMutableAttributedString *) string
{
    UITextView *contentText = [[UITextView alloc] initWithFrame:CGRectMake(0, self.heightY, self.content.frame.size.width, 10)];
    contentText.attributedText = string;
    contentText.userInteractionEnabled = FALSE;
    contentText.editable = FALSE;
    contentText.scrollEnabled = FALSE;
    
    CGSize size = [contentText systemLayoutSizeFittingSize:contentText.contentSize];
    CGRect textRect = CGRectMake(0, self.heightY, self.content.frame.size.width, size.height);
    contentText.frame = textRect;
    self.heightY += size.height;
    
    return contentText;
}

// Exit
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
