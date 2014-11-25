//
//  CServiceBase.m
//  Bussiness
//
//  Created by liukai on 14-9-3.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "CServiceBase.h"

@implementation CServiceBase

+(NSNotificationCenter*)defaulNotificationCenter{
    static NSNotificationCenter *shareNotification = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareNotification = [[NSNotificationCenter alloc] init];
    });
    return shareNotification;
}

-(void)broadcastNotification:(NSString*)notifyName;
{
    [[CServiceBase defaulNotificationCenter] postNotificationName:notifyName object:nil];
    
}
@end


/*
 #define PARAMETER_NULL 901 // 参数不允许为空

 #define WRONG_VERIFY_CODE 20005  // 验证码错误
 #define VERIFY_CODE_TIMEOUT 20006 // 验证码已过期
 
 #define  UNKOWN_ERROR 20009 // 未知错误
 #define ILLEGAL_MOBILE 20010  // 无效的手机号码
 #define SEND_SMS_FAIL 20012  // 发送短信失败！
 
 #define USER_PHONE_BINDED 30001  // 用户手机已绑定
 #define USER_NAME_EXIST 30008  // 用户名已经存在
 #define PHONE_REGEX_ERROR 30009  // 手机号格式有问题
 #define AUTH_MAX_TRY 30010  // 验证失败且超过次
 */

//根据服务器返回的错误码   获得错误信息   实现