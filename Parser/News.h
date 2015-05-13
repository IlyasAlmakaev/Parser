//
//  News.h
//  Parser
//
//  Created by almakaev iliyas on 13.05.15.
//  Copyright (c) 2015 intent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface News : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * reference;

@end
