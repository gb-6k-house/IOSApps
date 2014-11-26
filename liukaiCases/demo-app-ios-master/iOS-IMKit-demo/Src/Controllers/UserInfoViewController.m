//
//  UserInfoViewController.m
//  iOS-IMKit-demo
//
//  Created by xugang on 8/21/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "UserInfoViewController.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(50,100 , 220, 50)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationTitle:@"用户资料"];
    
    [self.view addSubview:self.nameLabel];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 35)];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    
    [leftButton addTarget:self action:@selector(didCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    self.navigationItem.leftBarButtonItem=left;
    
    
}
-(void)didCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setNavigationTitle:(NSString *)title
{
    UILabel* titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLab.font = [UIFont systemFontOfSize:18];
    [titleLab setBackgroundColor:[UIColor clearColor]];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.tag = 1000;
    //[self.navigationController.navigationBar addSubview:titleLab];
    self.navigationItem.titleView=titleLab;
    
    titleLab.text = title;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
