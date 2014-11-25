//
//  CHttpConnection.m
//  Bussiness
//
//  Created by liukai on 14-7-17.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "CHttpConnection.h"
#import <ASIHTTPRequest.h>
#import <ASIFormDataRequest.h>
#import "LogInfo.h"
@interface CHttpConnection(){
    NSMutableData *_responseData;
    NSDictionary* _config;
    NSMutableDictionary*_httpHeadDic;
    BOOL  _requstFinished; //请求完成；
    NSString *_imei;//
}
@property(nonatomic, retain) ASIHTTPRequest* request;
@property(nonatomic, retain) NSData* bodyData; //请求的数据
@property(nonatomic, retain) NSData* fileData; //文件请求的数据
@property(nonatomic, copy)NSString* fileName; //文件请求的名称
@property(nonatomic, retain)NSDictionary* paramar;//请求参数
@property(nonatomic, assign)HttpMethod method;//请求的方法

@end;
@implementation CHttpConnection

-(id)init{
    self = [super init];
    if (self) {
        _responseData = [[NSMutableData alloc] init];
        _timeOutSeconds = 15.0f; //超时缺省15秒
        _requstFinished = NO;
        _httpHeadDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(void)dealloc{
       //取消请求
    [self.request clearDelegatesAndCancel];
}
-(ASIHTTPRequest*)getASIHTTPRequest:(NSData*) body
                         httpMethod:(HttpMethod)method
                                url:(NSString*)url{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    if (POST== method) {
        [request setRequestMethod:@"POST"];
    }else{
        [request setRequestMethod:@"GET"];
    }
    //连接重用设置
    [request setShouldAttemptPersistentConnection:NO];
    [request setTimeOutSeconds:_timeOutSeconds];
    if (NULL != body) {
        NSMutableData * data = [NSMutableData dataWithData:body];
        [request setPostBody:data];
    }
    return request;
}

-(ASIFormDataRequest*)getASIFormDataRequest:(NSData*)data
                                  fileName:(NSString*)fileName
                                       url:(NSString*)url
                                   paramar:(NSDictionary*) paramar{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    //连接重用设置
    [request setShouldAttemptPersistentConnection:NO];
    [request setTimeOutSeconds:_timeOutSeconds];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    for (NSString *key in paramar) {
        [request setPostValue:[paramar objectForKey:key] forKey:key];
    }
    [request addData:data withFileName:fileName andContentType:nil forKey:@"file"];
    return request;
}
-(id<IHttpConnection>)initHttpRequestWithData:(NSData*) body
                                   httpMethod:(HttpMethod)method
                                          url:(NSString*)url{
    self = [self init];
    if (self) {
        self.bodyData = body;
        self.method = method;
        self.url = url;
        self.request = [self getASIHTTPRequest:body httpMethod:method url:url];
    }
    return self;
}
//初始一个文件上传请求
-(id)initUpLoadFileRequestWithFile:(NSData*)data fileName:(NSString*)fileName  url:(NSString*)url paramar:(NSDictionary*) paramar{
    self = [self init];
    if (self) {
        self.fileData = data;
        self.url = url;
        self.fileName = fileName;
        self.paramar = paramar;
        self.request = [self getASIFormDataRequest:data fileName:fileName url:url paramar:paramar];
    }
    return self;
}
-(void)setToken:(NSString *)token{
    _token = [token copy];
    [_httpHeadDic setValue:self.token forKey:@"TOKEN"];
    [self.request setRequestHeaders:_httpHeadDic];
}
-(void)setIMEI:(NSString *)imei{
    _imei = [imei copy];
    [_httpHeadDic setValue:_imei forKey:@"IMEI"];
    [self.request setRequestHeaders:_httpHeadDic];

}
-(void)setTimeOutSeconds:(NSTimeInterval)timeOutSeconds{
    _timeOutSeconds = timeOutSeconds;
    [self.request setTimeOutSeconds:self.timeOutSeconds];
}


#pragma mark ASIHTTPRequest delegate

- (void)requestFinished:(ASIHTTPRequest *)request{
    _requstFinished = YES;
    if (self.response
        && [self.response respondsToSelector:@selector(httpResponse:connection:)]
         ){
        [self.response httpResponse:_responseData connection:self];
    }
    //请求完成，删除当前请求
    [_responseData setData:nil];
    [self.manager removeConnction:self];
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    if (self.response
        && [self.response respondsToSelector:@selector(httpHead:connection:)]
        ){
        [self.response httpHead:responseHeaders connection:self];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    NSString *failedStr = [NSString stringWithFormat:@"{\"retcode\":%d,\"message\":\"网络异常，请检查网络环境\"}", HTTP_ERROR];
    NSData *responseData = [failedStr dataUsingEncoding:NSUTF8StringEncoding];
    DDLogError(@"http服务请求出错:code = %d, msg: %@",     [request responseStatusCode],[request responseString]);
    if (self.response
        && [self.response respondsToSelector:@selector(httpResponse:connection:)]
        ){
        [self.response httpResponse:responseData connection:self];
    }
    //请求完成，删除当前请求
    [self.manager removeConnction:self];
}

-(void)startAsynchronous{
    if (_requstFinished) {
        DDLogInfo(@"重新发起HTTP请求成功");
        if ([self.request isKindOfClass:[ASIFormDataRequest class]]) {
            self.request = [self getASIFormDataRequest:self.fileData fileName:self.fileName url:self.url paramar:self.paramar];
        }else{
            self.request = [self getASIHTTPRequest:self.bodyData httpMethod:self.method url:self.url];
        }
    }
    [self.request startAsynchronous];
}
- (void)requestRedirected:(ASIHTTPRequest *)request{
    
}
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    [_responseData appendData:data];
}
-(void)settingConnection:(NSDictionary*)config{
    _config = config;
}
-(NSDictionary*)getConfig{
    return _config;
}


@end
