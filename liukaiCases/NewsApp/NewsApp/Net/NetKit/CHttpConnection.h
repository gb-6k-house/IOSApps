//  每一个http请求连接
//  CHttpConnection.h
//  Bussiness
//
//  Created by liukai on 14-7-17.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHttpManager.h"
#import "IHttpServiceResponseDelagate.h"
#import "IHttpConnection.h"
typedef unsigned long ConnectionSequence;
#define HTTP_ERROR -100
@interface CHttpConnection : NSObject<IHttpConnection>

@property(nonatomic, retain) id<IHttpManager> manager;
@property(nonatomic, assign) ConnectionSequence index;
@property(nonatomic, assign) NSTimeInterval timeOutSeconds;
@property(nonatomic, weak) id<IHttpServiceResponseDelagate> response;
@property(nonatomic, copy) NSString *token;
@property(nonatomic, copy) NSString *url;
@end
