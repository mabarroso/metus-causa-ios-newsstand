//
//  Publication.m
//  Metus Causa
//
//  Created by mabarroso on 22/06/13.
//  Copyright (c) 2013 mabarroso. All rights reserved.
//

#import "Publication.h"

NSString *PublicationDidUpdateNotification = @"PublicationDidUpdate";
NSString *PublicationFailedUpdateNotification = @"PublicationFailedUpdate";

@interface Publication () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *name;
    NSMutableString *number;
    NSMutableString *title;
    NSMutableString *description;
    NSMutableString *date;
    NSMutableString *cover;
    NSMutableString *content;
    NSString *element;
}
@end

static Publication *publicationInstance = NULL;

@implementation Publication

@synthesize ready;

+(Publication *)getInstance {
    if ( !publicationInstance || publicationInstance == NULL ) {
        publicationInstance = [[Publication alloc] init];
    }
    return publicationInstance;
}

-(id)init {
    if ( self = [super init] )
    {
        ready = NO;
        issues = nil;
    }
    return self;
}

-(void)dealloc {
    //[issues release];
    //[super dealloc];
}

-(void)getIssuesList {
    NSLog(@"getIssuesList");
    feeds = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://circulo.almianos.net/newsstand/metuscausa.xml"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

-(NSInteger)numberOfIssues {
    if([self isReady] && feeds) {
        return [feeds count];
    } else {
        return 0;
    }
}

-(NSString *)issueId:(NSInteger)index {
    NSString *issueId = [[feeds objectAtIndex:index] objectForKey:@"name"];
    issueId = [issueId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    issueId = [issueId stringByAppendingString:[[feeds objectAtIndex:index] objectForKey:@"number"]];
    issueId = [issueId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return issueId;
}

-(NSString *)name:(NSInteger)index {
    return [[[feeds objectAtIndex:index] objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)number:(NSInteger)index {
    return [[[feeds objectAtIndex:index] objectForKey:@"number"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)title:(NSInteger)index {
    return [[[feeds objectAtIndex:index] objectForKey:@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)date:(NSInteger)index {
    return [[[feeds objectAtIndex:index] objectForKey:@"date"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(UIImage *)coverImage:(NSInteger)index {
    NSString *url=[[feeds objectAtIndex:index] objectForKey:@"cover"];
    NSURL *imageURL = [NSURL URLWithString:[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

-(NSString *)content:(NSInteger)index {
    NSString *url = [[feeds objectAtIndex:index] objectForKey:@"content"];
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return url;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        item        = [[NSMutableDictionary alloc] init];
        name        = [[NSMutableString alloc] init];
        number      = [[NSMutableString alloc] init];
        title       = [[NSMutableString alloc] init];
        description = [[NSMutableString alloc] init];
        date        = [[NSMutableString alloc] init];
        cover       = [[NSMutableString alloc] init];
        content     = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        [item setObject:name forKey:@"name"];
        [item setObject:number forKey:@"number"];
        [item setObject:title forKey:@"title"];
        [item setObject:description forKey:@"description"];
        [item setObject:date forKey:@"date"];
        [item setObject:cover forKey:@"cover"];
        [item setObject:content forKey:@"content"];
        
        [feeds addObject:[item copy]];
        
        [self addIssuesInNewsstand:(feeds.count-1)];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([element isEqualToString:@"name"]) {
        [name appendString:string];
    } else if ([element isEqualToString:@"number"]) {
        [number appendString:string];
    } else if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"description"]) {
        [description appendString:string];
    } else if ([element isEqualToString:@"date"]) {
        [date appendString:string];
    } else if ([element isEqualToString:@"cover"]) {
        [cover appendString:string];
    } else if ([element isEqualToString:@"content"]) {
        [content appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    ready = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PublicationDidUpdateNotification object:self];
    });
}

-(void)addIssuesInNewsstand:(NSInteger)index {
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NSString *issueName = [self issueId:index];
    NKIssue *nkIssue = [nkLib issueWithName:issueName];
    if(!nkIssue) {
        // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *issueDateString= [[self date:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDate *issueDate = [dateFormat dateFromString:issueDateString];
            
        nkIssue = [nkLib addIssueWithName:issueName date:issueDate];
    }
    NSLog(@"Issue: %@",nkIssue);
}

-(void)addAllIssuesInNewsstand {
    NSInteger n = [self numberOfIssues];
    for (NSInteger i = 0; i < n; i++) {
        [self addIssuesInNewsstand:i];
    }
}

-(UIImage *)coverImageForIssue:(NKIssue *)nkIssue {
    NSString *name = nkIssue.name;
    for(NSDictionary *issueInfo in issues) {
        if([name isEqualToString:[issueInfo objectForKey:@"Name"]]) {
            NSString *coverPath = [issueInfo objectForKey:@"Cover"];
            NSString *coverName = [coverPath lastPathComponent];
            NSString *coverFilePath = [CacheDirectory stringByAppendingPathComponent:coverName];
            UIImage *image = [UIImage imageWithContentsOfFile:coverFilePath];
            return image;
        }
    }
    return nil;
}

-(NSString *)downloadPathForIssue:(NKIssue *)nkIssue {
    return [[nkIssue.contentURL path] stringByAppendingPathComponent:@"magazine.pdf"];
}

@end
