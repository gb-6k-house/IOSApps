//
//  LeftViewController.h
//  NewsApp
//
//  Created by liukai on 14-11-19.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBaseViewController.h"
#import <MSDynamicsDrawerViewController.h>

@interface LeftViewController : UIBaseViewController
@property(weak, nonatomic)MSDynamicsDrawerViewController *drawerCtrl;

@end
