//
//  Publication.h
//  Metus Causa
//
//  Created by mabarroso on 22/06/13.
//  Copyright (c) 2013 mabarroso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>
#include "TargetConditionals.h"

extern  NSString *PublicationDidUpdateNotification;
extern  NSString *PublicationFailedUpdateNotification;

@interface Publication : NSObject {
    NSArray *issues;
}

@property (nonatomic,readonly,getter = isReady) BOOL ready;

+(Publication *)getInstance;
-(void)getIssuesList;
-(NSInteger)numberOfIssues;
-(NSString *)issueId:(NSInteger)index;
-(NSString *)name:(NSInteger)index;
-(NSString *)number:(NSInteger)index;
-(NSString *)title:(NSInteger)index;
-(NSString *)date:(NSInteger)index;
-(UIImage *)coverImage:(NSInteger)index;
-(NSString *)content:(NSInteger)index;
-(UIImage *)coverImageForIssue:(NKIssue *)nkIssue;
-(NSString *)downloadPathForIssue:(NKIssue *)nkIssue;
-(void)addAllIssuesInNewsstand;

@end
