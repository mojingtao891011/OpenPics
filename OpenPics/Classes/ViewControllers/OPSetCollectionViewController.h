//
//  OPSetCollectionViewController.h
//  OpenPics
//
//  Created by PJ Gray on 6/22/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPItemCollectionViewController.h"

@class OPItem;
@interface OPSetCollectionViewController : OPItemCollectionViewController

@property (strong, nonatomic) OPItem* setItem;

@end
