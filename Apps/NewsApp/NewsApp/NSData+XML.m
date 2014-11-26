//
//  NSData+XML.m
//  NewsApp
//
//  Created by liukai on 14-11-26.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import "NSData+XML.h"

@implementation NSData (XML)
-(GDataXMLDocument*)ObjectFromHTMLData{
    return [[GDataXMLDocument alloc] initWithHTMLData:self error:nil];
    
}

@end
