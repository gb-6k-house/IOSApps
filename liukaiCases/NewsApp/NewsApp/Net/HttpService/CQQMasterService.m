//
//  CQQMasterService.m
//  NewsApp
//
//  Created by liukai on 14-11-19.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import "CQQMasterService.h"
#define INTERFACE_QQMASTER_HOME @"http://dajia.qq.com"
@implementation CQQMasterService
-(void)getHomeInfoFor:(id<CQQMasterServiceDelegate>)delegate{
    [self doRequest:INTERFACE_QQMASTER_HOME paramer:nil httpMethod:GET constroller:delegate];
}
-(void)doServiceResponse:(NSData*)responseData  interface:(NSString*)interface  sequence:(ConnectionSequence)sequence{
    [super doServiceResponse:responseData interface:interface sequence:sequence];
}

@end
