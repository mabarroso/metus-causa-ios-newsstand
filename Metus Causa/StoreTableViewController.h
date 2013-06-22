//
//  APPMasterViewController.h
//  RSSreader
//
//  Created by Rafael Garcia Leiva on 08/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>

@interface StoreTableViewController : UITableViewController <NSXMLParserDelegate> {
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *waitButton;    
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
