//
//  DemoChatListViewController.m
//  iOS-IMKit-demo
//
//  Created by xugang on 8/30/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "DemoChatListViewController.h"
#import "DemoChatViewController.h"
#import "DemoGroupListViewController.h"

@implementation DemoChatListViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    //自定义导航标题颜色
    [self setNavigationTitle:@"会话" textColor:[UIColor whiteColor]];
    //自定义导航左右按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonItemPressed:)];
    [leftButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftButton;
    //自定义导航左右按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonItemPressed:)];
    [rightButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightButton;
    
 }


-(void)leftBarButtonItemPressed:(id)sender
{
    [super leftBarButtonItemPressed:sender];
}

/**
 *  重载右边导航按钮的事件
 *
 *  @param sender <#sender description#>
 */
-(void)rightBarButtonItemPressed:(id)sender
{
    //跳转好友列表界面，可是是融云提供的UI组件，也可以是自己实现的UI
    RCSelectPersonViewController *temp = [[RCSelectPersonViewController alloc]init];
    //控制多选
    temp.isMultiSelect = YES;
    temp.portaitStyle = RCUserAvatarCycle;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:temp];
    //导航和的配色保持一直
    UIImage *image= [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    temp.delegate = self;
//    [self presentModalViewController:nav animated:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)didSelectedPersons:(NSArray*)selectedArray viewController:(RCSelectPersonViewController *)viewController
{
    if(selectedArray == nil || selectedArray.count == 0)
    {
        DebugLog(@"Select person array is nil");
        return;
    }
    int count = (int)selectedArray.count;
    
    
    //只选择一个人得时候,创建单人聊天
    if (1 == count) {
        RCUserInfo* userInfo = selectedArray[0];
        [self startPrivateChat:userInfo];
    }
    //选择多个人得时候
    else if(count  > 1){
        
        [self startDiscussionChat:selectedArray];
        
    }
    
}

/**
 *  启动一对一聊天
 *
 *  @param userInfo
 */
-(void)startPrivateChat:(RCUserInfo*)userInfo{
    
    DemoChatViewController* chat = [self getChatController:userInfo.userId conversationType:ConversationType_PRIVATE];
    if (nil == chat) {
        chat =[[DemoChatViewController alloc]init];
        chat.portraitStyle = RCUserAvatarCycle;
        [self addChatController:chat];
    }
    
    chat.currentTarget = userInfo.userId;
    chat.currentTargetName = userInfo.name;
    chat.conversationType = ConversationType_PRIVATE;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *  启动讨论组
 *
 *  @param userInfos
 */
-(void)startDiscussionChat:(NSArray*)userInfos{
    
    NSMutableString *discussionName = [NSMutableString string] ;
    NSMutableArray *memberIdArray =[NSMutableArray array];
    NSInteger count = userInfos.count ;
    for (int i=0; i<count; i++) {
        RCUserInfo *userinfo = userInfos[i];
        //NSString *name = userinfo.name;
        if (i == userInfos.count - 1) {
            [discussionName appendString:userinfo.name];
        }else{
            [discussionName  appendString:[NSString stringWithFormat:@"%@%@",userinfo.name,@","]];
        }
        [memberIdArray addObject:userinfo.userId];
        
    }
    //创建讨论组
    [[RCIMClient sharedRCIMClient]createDiscussion:discussionName userIdList:memberIdArray completion:^(RCDiscussion *discussInfo) {
        DebugLog(@"create discussion ssucceed!");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DemoChatViewController* chat = [self getChatController:discussInfo.discussionId conversationType:ConversationType_PRIVATE];
            if (nil == chat) {
                chat =[[DemoChatViewController alloc]init];
                chat.portraitStyle = RCUserAvatarCycle;
                [self addChatController:chat];
            }
            
            chat.currentTarget = discussInfo.discussionId;
            chat.currentTargetName = discussInfo.discussionName;
            chat.conversationType = ConversationType_DISCUSSION;
            [self.navigationController pushViewController:chat animated:YES];
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DebugLog(@"DISCUSSION_INVITE_FAILED %d",status);
            UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:@"创建讨论组失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        });
    }];
}

/**
 *  重载选择表格事件
 *
 *  @param conversation
 */
-(void)onSelectedTableRow:(RCConversation*)conversation{
    
    
    if(conversation.conversationType == ConversationType_GROUP)
    {
        DemoGroupListViewController* groupVC = [[DemoGroupListViewController alloc] init];
        self.currentGroupListView = groupVC;
        groupVC.portraitStyle = RCUserAvatarCycle;
        [self.navigationController pushViewController:groupVC animated:YES];
        return;
    }
    //该方法目的延长会话聊天UI的生命周期
    DemoChatViewController* chat = [self getChatController:conversation.targetId conversationType:conversation.conversationType];
    if (nil == chat) {
        chat =[[DemoChatViewController alloc]init];
        chat.portraitStyle = RCUserAvatarCycle;
        [self addChatController:chat];
    }
    chat.currentTarget = conversation.targetId;
    chat.conversationType = conversation.conversationType;
    //chat.currentTargetName = curCell.userNameLabel.text;
    chat.currentTargetName = conversation.conversationTitle;
    [self.navigationController pushViewController:chat animated:YES];
}

@end
