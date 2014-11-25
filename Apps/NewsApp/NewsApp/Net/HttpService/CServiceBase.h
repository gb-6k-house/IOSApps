//
//  CServiceBase.h
//  Bussiness
//
//  Created by liukai on 14-9-3.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>


#define MY_PAGE_SIZE 20 //分页查询本地数据的个数
/*
 * 服务基类，所以服务请求继承该类
 */
@interface CServiceBase : NSObject
/**
 *广播消息，TOKEN刷新完成，刷新TOKEN时需要调用该方法
 */
-(void)broadcastNotification:(NSString*)notifyName;

//HTTP请求的通知中心，
+(NSNotificationCenter*)defaulNotificationCenter;

@end
