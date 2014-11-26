//
//  DemoRichContentMessageViewController.m
//  iOS-IMKit-demo
//
//  Created by Gang Li on 10/20/14.
//  Copyright (c) 2014 RongCloud. All rights reserved.
//

#import "DemoRichContentMessageViewController.h"
#import "DemoChatsettingViewController.h"
#import "DemoPreviewViewController.h"
#import "RCIM.h"

@interface DemoRichContentMessageViewController ()

@end

@implementation DemoRichContentMessageViewController


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
    [self sendDebugRichMessage];
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

-(void)sendDebugRichMessage {
    RCRichContentMessage *message = [[RCRichContentMessage alloc] init];
    message.title = @"Yosemite崩溃的修复方法";
    message.digest = @"在新的优胜美地Yosemite中, 苹果使用了全新的安全机制, 叫做 Kext Signing 核心签名.这个签名认证机制将检查系统内所有的驱动程序的安全性";
    message.imageURL = @"http://images.macx.cn/forum/201410/18/051336drp3zwrrh35w5p4e.jpg";
    message.extra = @"extra data";

    [[RCIM sharedRCIM] sendMessage:self.conversationType
                          targetId:self.currentTarget
                           content:message
                          delegate:self];
}


@end
