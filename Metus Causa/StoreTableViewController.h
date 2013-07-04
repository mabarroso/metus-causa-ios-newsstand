//
//  APPMasterViewController.h
//  RSSreader
//
//  Created by Rafael Garcia Leiva on 08/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>
#import <QuickLook/QuickLook.h>
#import "Publication.h"


@interface StoreTableViewController : UITableViewController <NSXMLParserDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate> {
    Publication *publication;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *waitButton;    
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
