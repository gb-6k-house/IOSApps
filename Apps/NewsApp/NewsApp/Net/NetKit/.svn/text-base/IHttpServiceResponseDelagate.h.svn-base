//
//  IHttpServiceResponseDelagate.h
//  Bussiness
//
//  Created by liukai on 14-7-18.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHttpConnection.h"

@protocol IHttpServiceResponseDelagate <NSObject>
@required
//http成功服务返回的数据
-(void)httpResponse:(NSData *) responseData connection:(id<IHttpConnection>)conn;
@optional
-(void)httpHead:(NSDictionary*)head connection:(id<IHttpConnection>)conn;
@end
