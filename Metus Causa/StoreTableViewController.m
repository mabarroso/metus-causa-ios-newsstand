//
//  APPMasterViewController.m
//  RSSreader
//
//  Created by Rafael Garcia Leiva on 08/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "StoreTableViewController.h"
#import "DetailViewController.h"
#import "Publication.h"

@interface StoreTableViewController ()

@end

@implementation StoreTableViewController

@synthesize tableView=tableView_;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    publication = [[Publication alloc] init];
    
    // define right bar button items
    refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadIssues)];
    UIActivityIndicatorView *loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivity startAnimating];
    waitButton = [[UIBarButtonItem alloc] initWithCustomView:loadingActivity];
    [waitButton setTarget:nil];
    [waitButton setAction:nil];
    
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    // left bar button item
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashContent)];

    [self loadIssues];
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
    return [publication numberOfIssues];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSInteger index = indexPath.row;

    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text=[publication name:index];

    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:102];
    subtitleLabel.text=[publication title:index];

    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publication issueId:index]];

    UIProgressView *downloadProgress = [UIProgressView new];
    downloadProgress.tag = 201;
    downloadProgress.frame = CGRectMake(cell.frame.origin.x + cell.frame.size.width - 100 - 5,
                                        5,
                                        100, 30);
    downloadProgress.progress = 1.f*70/100;
    [cell.contentView addSubview:downloadProgress];
    
    UILabel *downloadLabel = [UILabel new];
    downloadLabel.tag = 202;
    [downloadLabel setText:@"Download"];
    downloadLabel.frame = CGRectMake(cell.frame.origin.x + cell.frame.size.width - 100 - 5,
                                     0 + ((cell.frame.size.height - 30) / 2),
                                     100, 30);
    downloadLabel.backgroundColor= [UIColor clearColor];
    [cell.contentView addSubview:downloadLabel];

    if(nkIssue.status==NKIssueContentStatusAvailable) {
        subtitleLabel.alpha=1.0;
        downloadProgress.alpha=0.0;
        downloadLabel.alpha=0.0;
    } else {
        if(nkIssue.status==NKIssueContentStatusDownloading) {
            downloadProgress.alpha=1.0;
            subtitleLabel.alpha=1.0;
            downloadLabel.alpha=0.0;
        } else {
            downloadProgress.alpha=0.0;
            subtitleLabel.alpha=1.0;
            downloadLabel.alpha=1.0;
        }
    }

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:103];    
    [imageView setImage:[publication coverImage:index]];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // possible actions: read or download
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publication issueId:indexPath.row]];
    // NSURL *downloadURL = [nkIssue contentURL];
    if(nkIssue.status==NKIssueContentStatusAvailable) {
//        [self readIssue:nkIssue];
    } else if(nkIssue.status==NKIssueContentStatusNone) {
        [self downloadIssueAtIndex:indexPath.row];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publication issueId:indexPath.row]];
    if(nkIssue.status!=NKIssueContentStatusAvailable) {
        return false;
    } else {
        return true;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
//        [[segue destinationViewController] setUrl:string];
        
    }
}

#pragma mark - Trash content

// remove all downloaded magazines
-(void)trashContent {
    NSLog(@"TODO: trashContent");
}

#pragma mark - Publisher interaction

-(void)loadIssues {
    [self.navigationItem setRightBarButtonItem:waitButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publicationReady:) name:PublicationDidUpdateNotification object:publication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publicationFailed:) name:PublicationFailedUpdateNotification object:publication];
    [publication getIssuesList];
}

-(void)showIssues {
    [self.navigationItem setRightBarButtonItem:refreshButton];
    tableView_.alpha=1.0;
    [tableView_ reloadData];
}

-(void)publicationReady:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublicationDidUpdateNotification object:publication];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublicationFailedUpdateNotification object:publication];
    [self showIssues];
}

-(void)publicationFailed:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublicationDidUpdateNotification object:publication];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublicationFailedUpdateNotification object:publication];
    NSLog(@"%@",not);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Cannot get issues from publisher server."
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
    //[alert release];
    [self.navigationItem setRightBarButtonItem:refreshButton];
}

#pragma mark - Issue actions

-(void)downloadIssueAtIndex:(NSInteger)index {
    NSLog(@"download %@", [publication issueId:index]);
    NSLog(@"content %@", [publication content:index]);
    
    NSString *url=[publication content:index];

    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publication issueId:index]];
    NSURL *downloadURL = [NSURL URLWithString:url];
    if(!downloadURL) return;
    NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
    NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:req];
    [assetDownload downloadWithDelegate:self];
    [assetDownload setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:index],@"Index",
                                nil]];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];    
}

@end
