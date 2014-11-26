//
//  DemoChatViewController.m
//  iOS-IMKit-demo
//
//  Created by xugang on 8/30/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "DemoChatViewController.h"
#import "DemoChatsettingViewController.h"
#import "DemoPreviewViewController.h"


@implementation DemoChatViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //自定义导航标题颜色
    [self setNavigationTitle:self.currentTargetName textColor:[UIColor whiteColor]];
    
    //自定义导航左右按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonItemPressed:)];
    [leftButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    if (!self.enableSettings) {
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        //自定义导航左右按钮
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonItemPressed:)];
        [rightButton setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

-(void)leftBarButtonItemPressed:(id)sender
{
    [super leftBarButtonItemPressed:sender];
}
-(void)rightBarButtonItemPressed:(id)sender{
    DemoChatsettingViewController *temp = [[DemoChatsettingViewController alloc]init];
    temp.targetId = self.currentTarget;
    temp.conversationType = self.conversationType;
    temp.portraitStyle = RCUserAvatarCycle;
    [self.navigationController pushViewController:temp animated:YES];
}

-(void)showPreviewPictureController:(RCMessage*)rcMessage{
    
    DemoPreviewViewController *temp=[[DemoPreviewViewController alloc]init];
    temp.rcMessage = rcMessage;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:temp];
    
    //导航和原有的配色保持一直
    UIImage *image= [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    
    [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)onBeginRecordEvent{
    DebugLog(@"录音开始");
}
-(void)onEndRecordEvent{
    DebugLog(@"录音结束");
}

@end
