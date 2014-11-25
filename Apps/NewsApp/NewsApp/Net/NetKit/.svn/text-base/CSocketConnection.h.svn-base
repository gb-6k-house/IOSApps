//
//  CSocketConnection.h
//  Bussiness
//
//  Created by liukai on 14-8-4.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CSocketConnection;
@protocol SocketConnectionDelegate <NSObject>
@optional
//接受数据到数据
-(void)onSocket:(CSocketConnection*)socket data:(NSData*)data;
@end

@interface CSocketConnection : NSObject
-(BOOL)connectToHost:(NSString*)ip port:(UInt16)port;
@property(nonatomic, assign)id<SocketConnectionDelegate> delegate;
@end
