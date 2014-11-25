//
//  IHttpConnection.h
//  Bussiness
//
//  Created by liukai on 14-7-18.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IHttpConnection <NSObject>
@required
/**
 *
 *@url
 *@body 请求http的数据
 *@method
 *@response 响应的代理
 *@
 */
-(id<IHttpConnection>)initHttpRequestWithData:(NSData*) body
                                      httpMethod:(HttpMethod)method
                                             url:(NSString*)url;

/**
 *开始异步请求
 */
-(void)startAsynchronous;
/*
 */
//文件上传请求
-(void)setToken:(NSString *)token;
-(void)setIMEI:(NSString *)imei;
-(void)setTimeOutSeconds:(NSTimeInterval)timeOutSeconds;
@optional
-(id<IHttpConnection>)initUpLoadFileRequestWithFile:(NSData*)data
                                           fileName:(NSString*)fileName
                                                url:(NSString*)url
                                            paramar:(NSDictionary*) paramar;
@optional

//配置连接信息,比如接口类型等
-(void)settingConnection:(NSDictionary*)config;
-(NSDictionary*)getConfig;
@end
