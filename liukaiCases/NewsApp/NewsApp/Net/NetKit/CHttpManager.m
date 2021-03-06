//
//  CHttpManager.m
//  Bussiness
//
//  Created by liukai on 14-7-17.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "CHttpManager.h"
#import "CHttpConnection.h"
#import "NSData+AES.h"

#define TIME_OUT_SECONDS 15 //网络超时15秒
static NSString * IMEI_Encrypt_Key = @"E238DAEDE32442CF8746C3B141CBD07A";

@interface CHttpManager(){
    
    unsigned long _sequence;
    NSMutableDictionary * _connectDic;
    NSString *_imei;
    
}
-(void)addConnction:(CHttpConnection*)conn;
@end;
static NSString * gToken = NULL;
@implementation CHttpManager

SINGLETON_IMPLEMENT(CHttpConnection)

-(id)init{
    self = [super init];
    if (self){
        _sequence = 0;
        _connectDic = [[NSMutableDictionary alloc] init];
        _timeOutSeconds = 15;
        //加密
//        if (_imei && ![@"" isEqualToString:_imei]) {
//            NSData *imeiData = [_imei dataUsingEncoding:NSUTF8StringEncoding];
//            NSData *key =  [NSData stringToByte:IMEI_Encrypt_Key];
//            imeiData = [imeiData AES128EncryptWithKey:key];
//            _imei = [NSData byteToString:imeiData];
//        }

    }
    return self;
}

-(NSString*)getToken{
    return gToken;
}
-(void)setToken:(NSString*)token{
    gToken = token;
}

-(void)addConnction:(id<IHttpConnection>)conn{
    @synchronized(self){
        if (![_connectDic objectForKey:conn]) {
            _sequence++;
            ((CHttpConnection*)conn).index = _sequence;
            [_connectDic setObject:conn forKey:[NSNumber numberWithUnsignedLong:_sequence]];
        }
        
    }
}
-(void)removeConnction:(id<IHttpConnection>)conn{
    @synchronized(self){
        [_connectDic removeObjectForKey:[NSNumber numberWithUnsignedLong:((CHttpConnection*)conn).index]];
    }
}

-(void)cancelResponse:(id<IHttpServiceResponseDelagate>)response{
    @synchronized(self){
        NSArray *keys = [_connectDic allKeys];
        for (id akey in keys) {
            CHttpConnection * conn = [_connectDic objectForKey:akey];
            if (response == conn.response) {
                [_connectDic removeObjectForKey:akey];
            }
        }
    }
}

-(id<IHttpConnection>)doRequest:(NSString*)url
            body:(NSData*) body
      httpMethod:(HttpMethod)method
        response:(id<IHttpServiceResponseDelagate>)response;{
    CHttpConnection *conn =  [[CHttpConnection alloc] initHttpRequestWithData:body httpMethod:method url:url];
    [conn setTimeOutSeconds:TIME_OUT_SECONDS];
    [conn setToken:[self getToken]];
    [conn setIMEI:_imei];
    [conn setResponse:response];
    [self addConnction:conn];
    return conn;
}

-(id<IHttpConnection>)upLoadFile:(NSString*)fileName
                             url:(NSString*)url
                         paramer:(NSDictionary*) paramer
                        fileData:(NSData*)fileData
                        response:(id<IHttpServiceResponseDelagate>)response{
    CHttpConnection *conn =  [[CHttpConnection alloc] initUpLoadFileRequestWithFile:fileData
                                                                           fileName:fileName
                                                                                url:url
                                                                      paramar:paramer];
    [conn setTimeOutSeconds:TIME_OUT_SECONDS];
    [conn setToken:[self getToken]];
    [conn setResponse:response];
    [self addConnction:conn];
    return conn;
}
-(void)startConnection:(id<IHttpConnection>) conn{
    [conn setTimeOutSeconds:TIME_OUT_SECONDS];
    [conn setToken:[self getToken]];
    [self addConnction:conn];
    [conn startAsynchronous];
}





@end
