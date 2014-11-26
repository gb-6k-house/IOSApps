//
//  CServiceManager.m
//  yhcServerCoreLib
//
//  Created by liukai on 14-9-24.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "CServiceManager.h"
@implementation CServiceManager
static NSString *server_ip = nil;
+(void)configWithIp:(NSString*)ip{
    server_ip  = [ip copy];
}
+(NSString*)serverIp{
    return server_ip;
}
@end
