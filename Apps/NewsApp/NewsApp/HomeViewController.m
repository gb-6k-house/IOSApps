//
//  HomeViewController.m
//  NewsApp
//
//  Created by liukai on 14-11-19.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import "HomeViewController.h"
#import "CQQMasterService.h"
@interface HomeViewController ()
@property (strong, nonatomic) IBOutlet UIButton *leftBarBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBarBtn;
@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.leftBarBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.leftBarBtn.backgroundColor = [UIColor redColor];
    [self.leftBarBtn addTarget:self action:@selector(gotoLeftView:) forControlEvents:UIControlEventTouchUpInside];
    self.leftBarBtn.frame = CGRectMake(0, 5, 50, 33);
    self.rightBarBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightBarBtn addTarget:self action:@selector(gotoRightView:) forControlEvents:UIControlEventTouchUpInside];
    self.rightBarBtn.frame = CGRectMake(SCREEN_WIDTH-16-33, 5, 33, 33);
    self.rightBarBtn.backgroundColor = [UIColor greenColor];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarBtn];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarBtn];
    [self.navigationItem setLeftBarButtonItem:leftItem];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    [self.mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dajia.qq.com/"] ]];
 
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
- (void)gotoLeftView:(id)sender {
    [self.drawerCtrl setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}
- (IBAction)gotoRightView:(id)sender {
    [self.drawerCtrl setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionRight animated:YES allowUserInterruption:YES completion:nil];

}

@end
