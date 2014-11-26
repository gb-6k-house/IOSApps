//
//  RightViewController.m
//  NewsApp
//
//  Created by liukai on 14-11-19.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import "RightViewController.h"
#import "CQQMasterService.h"

@interface RightViewController ()<CQQMasterServiceDelegate>
@property (strong , nonatomic)CQQMasterService *qqMasterService;

@end

@implementation RightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loadHomeData:(id)sender {
    self.qqMasterService = [[CQQMasterService alloc] init];
    [self.qqMasterService getHomeInfoFor:self];

}

@end
