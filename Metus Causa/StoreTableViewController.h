//
//  StoreTableViewController.h
//  Metus Causa
//
//  Created by mabarroso on 16/06/13.
//  Copyright (c) 2013 mabarroso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreTableViewController : UITableViewController {
    NSMutableArray *_allEntries;
}

@property (retain) NSMutableArray *allEntries;

@end
