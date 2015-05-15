//
//  NewsView.m
//  Parser
//
//  Created by almakaev iliyas on 15.05.15.
//  Copyright (c) 2015 intent. All rights reserved.
//

#import "NewsView.h"

@implementation NewsView

+ (id)newsView
{
    NewsView *newsView = [[[NSBundle mainBundle] loadNibNamed:@"NewsView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([newsView isKindOfClass:[NewsView class]])
        return newsView;
    else
        return nil;
}

@end
