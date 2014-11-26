//
//  CommonConfig.h
//  RongCloud
//
//  Created by Heq.Shinoda on 14-5-19.
//  Copyright (c) 2014年 iOS-IMKit-Demo. All rights reserved.
//

#ifndef RongCloud_CommonConfig_h
#define RongCloud_CommonConfig_h



#define FAKE_SERVER @"http://119.254.110.79:8080/"  // 登录服务器地址，请开发者配置

#define CHECK_PASSWORD_ENABLE 0

//当前版本
#define IOS_FSystenVersion            ([[[UIDevice currentDevice] systemVersion] floatValue])
#define IOS_DSystenVersion            ([[[UIDevice currentDevice] systemVersion] doubleValue])
#define IOS_SSystemVersion            ([[UIDevice currentDevice] systemVersion])

//当前语言
#define CURRENTLANGUAGE           ([[NSLocale preferredLanguages] objectAtIndex:0])


//是否Retina屏
#define isRetina                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) :NO)
//是否iPhone5
#define ISIPHONE                  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define ISIPHONE5                 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)


//-----------Notification-Macro Definination---------//
#define KNotificaitonPreviewPiecture @"KNotificaitonPreviewPiecture"
#define KNotificationCellReceiveNotification @"KNotificationCellReceiveNotification"

#endif//RongCloud_CommonConfig_h



