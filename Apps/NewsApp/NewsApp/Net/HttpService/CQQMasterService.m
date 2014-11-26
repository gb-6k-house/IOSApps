//
//  CQQMasterService.m
//  NewsApp
//
//  Created by liukai on 14-11-19.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import "CQQMasterService.h"
#import "LogInfo.h"
#import "NSData+XML.h"

#define INTERFACE_QQMASTER_HOME @"http://dajia.qq.com"

@implementation CQQMasterService
-(void)getHomeInfoFor:(id<CQQMasterServiceDelegate>)delegate{
    [self doRequest:INTERFACE_QQMASTER_HOME paramer:nil httpMethod:GET constroller:delegate];
}

/*
 *网络请求得到返回之后的回调方法
 *@param responseData  网络返回数据
 *@param interface  请求的接口
 *@param sequence 请求的唯一ID，根据ID号可以查询上层的代理
 */

-(void)doServiceResponse:(NSData*)responseData  interface:(NSString*)interface  sequence:(ConnectionSequence)sequence{
    [super doServiceResponse:responseData interface:interface sequence:sequence];
    if (IS_INTERFACE(INTERFACE_QQMASTER_HOME)) {
        //QQ大家首页返回
        [self doHomeResponse:responseData identify:sequence];
    }
}

-(void)printXMLNodeName:(GDataXMLElement*)element{
    DDLogInfo(@"%@", element.name);
    for (GDataXMLElement *node in element.children) {
        [self printXMLNodeName:node];
    }
}
/*
 *解析首页返回的网络数据
 */
-(void)doHomeResponse:(NSData *)responseData identify:(ConnectionSequence)identify{
    if (responseData) {
        GDataXMLDocument *html = [responseData ObjectFromHTMLData];
        GDataXMLElement *htmlRoot = html.rootElement;
        [self printXMLNodeName:htmlRoot];
    }
}

@end
