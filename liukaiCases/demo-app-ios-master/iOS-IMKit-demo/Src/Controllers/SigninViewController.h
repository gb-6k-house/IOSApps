//
//  SigninViewController.h
//  iOS-IMKit-demo
//
//  Created by Heq.Shinoda on 14-6-5.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHttpRequest.h"
#import "RCIM.h"

@interface SigninViewController : UIViewController<HttpConnectionDelegate,UITextFieldDelegate>
{
    NSString* loginToken;
}

@property (nonatomic,strong) RCHttpRequest *loginRequest;
@property (nonatomic,strong) RCHttpRequest *friendRquest;


@end
