//
//  CSocketConnection.m
//  Bussiness
//
//  Created by liukai on 14-8-4.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "CSocketConnection.h"
#import <AsyncSocket.h>
#import "LogInfo.h"

@interface CSocketConnection(){
    AsyncSocket *_asyncSocket;
    NSString *_ip;
    UInt16 _port;
}
@end
@implementation CSocketConnection
-(id)init{
    self = [super init];
    if (self) {
        _asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    return self;
}

-(void)dealloc{
    //断开连接
    [_asyncSocket disconnect];
}
-(BOOL)connectToHost:(NSString*)ip port:(UInt16)port{
    NSError *err = nil;
    if (![_asyncSocket connectToHost:ip onPort:port error:&err]) {
        DDLogError(@"socket连接服务%@:%d 失败，失败原因：%@",ip, port, err);
        return NO;
    }else
    {
        _ip = ip;
        _port = port;
        DDLogInfo(@"socket连接服务%@:%d 成功",ip, port);
    }
    return YES;
}

#pragma mark AsyncSocket delegate
-(void)onSocket:(AsyncSocket*)socket didReadData:(NSData *)data withTag:(long)tag{
    NSString *dataStr = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    DDLogInfo(@"socket收到数据%@:%d\n%@", _ip, _port, dataStr);
}
-(void)onSecket:(AsyncSocket*)socket willDisconnectWithError:(NSError*)err{
}
-(void)onSecketDidDisconnect:(AsyncSocket*)socket{
    DDLogInfo(@"断开连接%@:%d\n", _ip, _port);
}
@end
