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

@implementation Publication

@synthesize ready;

-(id)init {
    self = [super init];
    if(self) {
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
    return [[feeds objectAtIndex:index] objectForKey:@"name"];
}

-(NSString *)number:(NSInteger)index {
    return [[feeds objectAtIndex:index] objectForKey:@"number"];
}

-(NSString *)title:(NSInteger)index {
    return [[feeds objectAtIndex:index] objectForKey:@"title"];
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

@end
