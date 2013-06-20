//
//  APPMasterViewController.m
//  RSSreader
//
//  Created by Rafael Garcia Leiva on 08/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "StoreTableViewController.h"
#import "DetailViewController.h"

@interface StoreTableViewController () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *name;
    NSMutableString *title;
    NSMutableString *date;
    NSMutableString *cover;
    NSMutableString *content;
    NSString *element;
}
@end

@implementation StoreTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    feeds = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://circulo.almianos.net/newsstand/metuscausa.xml"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text=[[feeds objectAtIndex:indexPath.row] objectForKey:@"name"];

    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:102];
    subtitleLabel.text=[[feeds objectAtIndex:indexPath.row] objectForKey:@"cover"];

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:103];
    NSString *url=[[feeds objectAtIndex:indexPath.row] objectForKey:@"cover"];
    NSURL *imageURL = [NSURL URLWithString:[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    [imageView setImage:image];
    
    return cell;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        item    = [[NSMutableDictionary alloc] init];
        name    = [[NSMutableString alloc] init];
        title   = [[NSMutableString alloc] init];
        date    = [[NSMutableString alloc] init];
        cover   = [[NSMutableString alloc] init];
        content = [[NSMutableString alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:name forKey:@"name"];
        [item setObject:title forKey:@"title"];
        [item setObject:date forKey:@"date"];
        [item setObject:cover forKey:@"cover"];
        [item setObject:content forKey:@"content"];
        
        [feeds addObject:[item copy]];
        
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"name"]) {
        [name appendString:string];
    } else if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"date"]) {
        [date appendString:string];
    } else if ([element isEqualToString:@"cover"]) {
        [cover appendString:string];
    } else if ([element isEqualToString:@"content"]) {
        [content appendString:string];
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    [self.tableView reloadData];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
        [[segue destinationViewController] setUrl:string];
        
    }
}

@end
