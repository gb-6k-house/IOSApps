//
//  CServiceManager.h
//  yhcServerCoreLib
//
//  Created by liukai on 14-9-24.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*负责底层API服务的基本配置*/
@interface CServiceManager : NSObject
/*
 *配置服务IP地址
 */
+(void)configWithIp:(NSString*)ip;
/*
 *获取服务器IP地址
 */
+(NSString*)serverIp;

@end
