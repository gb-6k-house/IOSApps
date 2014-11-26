//
//  IHttpManager.h
//  Bussiness
//
//  Created by liukai on 14-7-18.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHttpConnection.h"
#import "IHttpServiceResponseDelagate.h"

@protocol IHttpManager <NSObject>
@required
/**
 *
 *@url
 *@body 请求http的数据
 *@method
 *@response 响应的代理
 *@
 */
-(id<IHttpConnection>)doRequest:(NSString*)url
                           body:(NSData*) body
                     httpMethod:(HttpMethod)method
                       response:(id<IHttpServiceResponseDelagate>)response;
/**
 *上传文件请求
 */
-(id<IHttpConnection>)upLoadFile:(NSString*)fileName
                             url:(NSString*)url
                         paramer:(NSDictionary*) paramer
                        fileData:(NSData*)fileData
                        response:(id<IHttpServiceResponseDelagate>)response;

//取消响应，当响应对象销毁时，需要调用该方法
-(void)cancelResponse:(id<IHttpServiceResponseDelagate>)response;
//删除一个连接
-(void)removeConnction:(id<IHttpConnection>)conn;
@end
