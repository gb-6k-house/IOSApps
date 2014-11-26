//
//  CHttpServiceBase.m
//  Bussiness
//
//  Created by liukai on 14-7-16.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "CHttpServiceBase.h"
#import "LogInfo.h"
#import "CServiceManager.h"
#define INVALID_TOKEN 620 //TOKEN失效
//当前连接状态
typedef NS_ENUM(NSInteger, CHttpServiceBaseStatus){
    CHttpServiceBaseStatusNormal = 0, //正常状态
    CHttpServiceBaseStatusRefreshingToken = 1 //等待刷新TOKEN
};
//Token状态
typedef NS_ENUM(NSInteger, TokenStatus){
    TokenStatusNormal = 0, //正常状态
    TokenStatusTokenInValid = 1, //token失效状态
    TokenStatusRefreshing = 2 //正在刷新TOKEN
};

@interface CHttpServiceBase(){
    NSMutableDictionary * _viewCtrls; //请求的页面
    NSMutableArray *_waitingRequestConn; //等待刷新TOKE请求的http连接
}
@property(nonatomic, assign)CHttpServiceBaseStatus status;
@end;
@implementation CHttpServiceBase

//暂时用全局变量保存TOKEN状态
TokenStatus g_tokenStatu = TokenStatusNormal;

//获取Token信息
+(NSString*)getToken{
   return [[CHttpManager sharedInstance] getToken];
}
//设置Token信息
+(void)setToken:(NSString*)token{
    [[CHttpManager sharedInstance] setToken:token];
}
-(void)dealloc{
    [[CHttpManager sharedInstance] cancelResponse:self];
    [[CHttpServiceBase defaulNotificationCenter] removeObserver:self];
}
-(id)init{
    self = [super init];
    if (self) {
        _viewCtrls = [[NSMutableDictionary alloc] init];
        _waitingRequestConn = [[NSMutableArray alloc] init];
        self.status = CHttpServiceBaseStatusNormal;
    }
    return self;
}


-(void)doRequest:(NSString*)url paramer:(NSString*) paramer httpMethod:(HttpMethod)method constroller:(id)controller {

    NSData * data = nil;
    if (GET == method){
        url = [NSString stringWithFormat:@"%@?%@",url,paramer];
    }else{
        if (paramer
            && ![@"" isEqualToString:paramer]) {
            //urlencode 转码
            NSString *enString =(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)paramer, NULL, NULL, kCFStringEncodingUTF8));
            data = [enString dataUsingEncoding:NSUTF8StringEncoding];
        }
        
    }
    DDLogInfo(@"当前请求url: %@，参数: %@", url, paramer);
    CHttpConnection *connt = [[CHttpManager sharedInstance] doRequest:url body:data httpMethod:method response:self];
    //保存服务接口
    [connt settingConnection:@{INTERFACE: url, CONNECTION_ID:[NSNumber numberWithUnsignedLong:connt.index]}];
    [self addController:controller sequence:connt.index];
    [[CHttpManager sharedInstance] startConnection:connt];

}
const int  MB = 1024*1024;
-(void)upLoadImage:(NSString*)url paramer:(NSDictionary*) paramer
             image:(UIImage*)image
       constroller:(id)controller{
    DDLogInfo(@"%@", url);
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    //图片大5M则压缩
    if ([imageData length] >= 5*MB) {
        imageData = UIImageJPEGRepresentation(image, 0.8);
    }
    CHttpConnection *connt = [[CHttpManager sharedInstance] upLoadFile:@"IMAGE.JPG" url:url paramer:paramer fileData:imageData response:self];
    [connt settingConnection:@{INTERFACE: url, CONNECTION_ID:[NSNumber numberWithUnsignedLong:connt.index]}]; //保存服务接口
    [self addController:controller sequence:connt.index];
    [[CHttpManager sharedInstance] startConnection:connt];

}


-(NSString*)getResponse:(NSData*)responseData{
    return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}

-(void)httpResponse:(NSData *) responseData connection:(id<IHttpConnection>)conn{
    NSDictionary *dic = [conn getConfig];
    FETCH_RECODE_MSG
    /*
     *TOKEN失效，刷新TOKEN,必须包含条件self.status == CHttpServiceBaseStatusRefreshingToken,
     *防止刷新TOKEN之前的其他请求返回，TOKEN失效，而导致循环刷新TOKEN
     */
    if (INVALID_TOKEN == retCode && !self.status == CHttpServiceBaseStatusRefreshingToken) {
        DDLogInfo(@"%s捕获接口：%@，请求异常 %@", object_getClassName(self), [dic objectForKey:INTERFACE], msg);
    }
    //
   [self doServiceResponse:responseData interface:[dic objectForKey:INTERFACE] sequence:[[dic objectForKey:CONNECTION_ID] unsignedLongValue]];

    
}

-(void)doServiceResponse:(NSData*)responseData  interface:(NSString*)interface  sequence:(ConnectionSequence)sequence{
    DDLogInfo(@"%@ 服务返回数据：%@", interface, [self getResponse:responseData]);
    
}
-(void)addController:(id)controller sequence:(ConnectionSequence) sequence{
    @synchronized(self){
        if (!controller) {
            return;
        }
        for (id ctrl in _viewCtrls) {
            if (controller == ctrl) {
                return;
            }
        }
        [_viewCtrls setObject:controller forKey:[NSNumber numberWithUnsignedLong:sequence]];
    }
}

-(void)removeController:(id)controller{
    @synchronized(self){
        for (id key in _viewCtrls.allValues) {
            if ([_viewCtrls objectForKey:key] == controller){
                //界面删除时，删除由于TOKEN刷新，阻塞的HTTP请求
                for (CHttpConnection *conn in _waitingRequestConn) {
                    if (conn.index == [key longValue]) {
                        [_waitingRequestConn removeObject:conn];
                    }
                }
                [_viewCtrls removeObjectForKey:key];
                break;
            }
        }
    }
}
-(id)findController:(ConnectionSequence)sequence{
    @synchronized(self){
        return [_viewCtrls objectForKey:[NSNumber numberWithUnsignedLong:sequence]];
    }
}

@end
