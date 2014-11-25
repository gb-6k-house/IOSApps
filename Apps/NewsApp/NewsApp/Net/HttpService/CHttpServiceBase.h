// 服务接口请求基类，请求是线程安全的
//
//  CHttpServiceBase.h
//  Bussiness
//
//  Created by liukai on 14-7-16.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHttpTypeDefine.h"
#import  "IHttpServiceResponseDelagate.h"
#import "CHttpManager.h"
#import "CHttpConnection.h"
#import "NSString+JSON.h"
#import "CServiceBase.h"
#import <UIKit/UIKit.h>


#define INTERFACE @"INTERFACE"
#define CONNECTION_ID @"ID"
//定义宏，提取服务返回的retcode+message
#define FETCH_RECODE_MSG  NSString *jsonStr = [self getResponse:responseData];\
                         NSDictionary *jsonDic = [jsonStr objectFromJSONString];\
                         long retCode = [[jsonDic objectForKey:@"retcode"] longValue];\
                         NSString *msg = [jsonDic objectForKey:@"message"];

#define IS_INTERFACE(inter) [inter isEqualToString:interface]

//缺省超时设置为15s
@interface CHttpServiceBase : CServiceBase<IHttpServiceResponseDelagate>
//获取Token信息
+(NSString*)getToken;
//设置Token信息
+(void)setToken:(NSString*)token;
//获取服务返回的字符串
-(NSString*)getResponse:(NSData*)responseData;
/**
 * 服务接口请求
 *@interface 服务接口
 *@paramer 服务请求参数
 */
-(void)doRequest:(NSString*)url paramer:(NSString*) paramer httpMethod:(HttpMethod)method
     constroller:(id)controller ;
/**
 *文件上传接口
 */
-(void)upLoadImage:(NSString*)url paramer:(NSDictionary*) paramer
         image:(UIImage*)image
       constroller:(id)controller;

/**
 * 添加请求的ViewController
 */
-(void)addController:(id)controller sequence:(ConnectionSequence) sequence;

/**
 *删除页面, 界面如果有网络请求，在界面销毁时必须调用该方法，取消页面的效应
 */
-(void)removeController:(id)controller;

-(id)findController:(ConnectionSequence)sequence;
/**
 *服务接口返回处理函数, 子类重载该方法完成请求之后的数据处理
 *@interface服务接口
 *@identify 请求http连接ID
 */
-(void)doServiceResponse:(NSData*)responseData  interface:(NSString*)interface  sequence:(ConnectionSequence)sequence;
//TOKEN失效之后的处理函数, 登陆模块可以启动重新刷新TOKEN机制
-(void)doAfterTokenInvilide;
@end
