//
//  NSString+XMl.m
//  yhcServerCoreLib
//
//  Created by liukai on 14-9-19.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "NSString+XMl.h"
@implementation NSString (XMl)
-(GDataXMLDocument*)ObjectFromXmlString{
    return [[GDataXMLDocument alloc] initWithXMLString:self error:nil];
}
@end
