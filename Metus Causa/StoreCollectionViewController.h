//
//  StoreCollectionViewController.h
//  Metus Causa
//
//  Created by mabarroso on 06/07/13.
//  Copyright (c) 2013 mabarroso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>
#import <QuickLook/QuickLook.h>
#import "Publication.h"

@interface StoreCollectionViewController : UICollectionViewController <NSXMLParserDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate> {
    Publication *publication;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *waitButton;
}

@end
