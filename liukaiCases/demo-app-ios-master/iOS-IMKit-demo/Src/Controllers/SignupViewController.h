//
//  SignupViewController.h
//  iOS-IMKit-demo
//
//  Created by Heq.Shinoda on 14-6-5.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark Register TextField Tag enum
enum TAG_REGISTER_TEXTFIELD{
    
    Tag_EmailTextField  = 100,    //邮箱
    Tag_AccountTextField ,        //用户名
    Tag_TempPasswordTextField,    //登录密码
    Tag_ConfirmPasswordTextField, //确认登录密码
};

@interface SignupViewController : UIViewController

@end
