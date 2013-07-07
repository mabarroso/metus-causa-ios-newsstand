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


    UIImageView *downloadImageView = (UIImageView *)[cell viewWithTag:105];

    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publication issueId:index]];
    
    if(nkIssue.status==NKIssueContentStatusAvailable) {
        downloadImageView.alpha = 0.0;
    } else {
        if(nkIssue.status==NKIssueContentStatusDownloading) {
            downloadImageView.alpha = 0.0;
        } else {
            downloadImageView.alpha = 0.7;
        }
    }
    
    return cell;

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

@end
