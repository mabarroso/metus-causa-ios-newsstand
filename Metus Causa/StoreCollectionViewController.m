//
//  StoreCollectionViewController.m
//  Metus Causa
//
//  Created by mabarroso on 06/07/13.
//  Copyright (c) 2013 mabarroso. All rights reserved.
//

#import "StoreCollectionViewController.h"
#import "Publication.h"

@interface StoreCollectionViewController ()

@end

@implementation StoreCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
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

    // Collection
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [publication numberOfIssues];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cvCell" forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:103];
    [imageView setImage:[publication coverImage:index]];

    UIProgressView *downloadProgress = (UIProgressView *)[cell viewWithTag:104];

    UIImageView *downloadImageView = (UIImageView *)[cell viewWithTag:105];

    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publication issueId:index]];
    
    if(nkIssue.status==NKIssueContentStatusAvailable) {
        downloadProgress.alpha = 0.0;
        downloadImageView.alpha = 0.0;
    } else {
        if(nkIssue.status==NKIssueContentStatusDownloading) {
            downloadProgress.alpha = 0.7;
            downloadImageView.alpha = 0.0;
        } else {
            downloadProgress.alpha = 0.0;
            downloadImageView.alpha = 0.9;
        }
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {

    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    // possible actions: read or download
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publication issueId:indexPath.row]];
    // NSURL *downloadURL = [nkIssue contentURL];
    if(nkIssue.status==NKIssueContentStatusAvailable) {
        [self readIssue:nkIssue];
    } else if(nkIssue.status==NKIssueContentStatusNone) {
        [self downloadIssueAtIndex:indexPath.row];
    }
    
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
    self.collectionView.alpha=1.0;
    [self.collectionView reloadData];
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

-(void)readIssue:(NKIssue *)nkIssue {
    [[NKLibrary sharedLibrary] setCurrentlyReadingIssue:nkIssue];
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.delegate=self;
    previewController.dataSource=self;
    [self presentModalViewController:previewController animated:YES];
}

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
    [self.collectionView reloadData];
}

#pragma mark - NSURLConnectionDownloadDelegate

-(void)reloadItemsInConnection:(NSURLConnection *)connection {
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[[dnl.userInfo objectForKey:@"Index"] intValue] inSection:0];
    NSArray *indexPathArray = [NSArray arrayWithObject:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:indexPathArray];
}

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    // get asset
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[[dnl.userInfo objectForKey:@"Index"] intValue] inSection:0];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:104];
    progressView.alpha=0.7;
    progressView.progress=1.f*totalBytesWritten/expectedTotalBytes;
    NSLog(@"Update downloading %f",1.f*totalBytesWritten/expectedTotalBytes);    

    [self reloadItemsInConnection:connection];
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    [self reloadItemsInConnection:connection];
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    NSLog(@"Resume downloading %f",1.f*totalBytesWritten/expectedTotalBytes);
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    [self reloadItemsInConnection:connection];
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy file to destination URL
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *nkIssue = dnl.issue;
    NSString *contentPath = [publication downloadPathForIssue:nkIssue];
    NSError *moveError=nil;
    NSLog(@"File is being copied to %@",contentPath);
    
    if([[NSFileManager defaultManager] moveItemAtPath:[destinationURL path] toPath:contentPath error:&moveError]==NO) {
        NSLog(@"Error copying file from %@ to %@",destinationURL,contentPath);
    }
    
    // update the Newsstand icon
    UIImage *img = [publication coverImageForIssue:nkIssue];
    if(img) {
        [[UIApplication sharedApplication] setNewsstandIconImage:img];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    }
    
    [self reloadItemsInConnection:connection];
}

#pragma mark - QuickLook

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index {
    NKIssue *nkIssue = [[NKLibrary sharedLibrary] currentlyReadingIssue];
    NSURL *issueURL = [NSURL fileURLWithPath:[publication downloadPathForIssue:nkIssue]];
    NSLog(@"Issue URL: %@",issueURL);
    return issueURL;
}

@end
