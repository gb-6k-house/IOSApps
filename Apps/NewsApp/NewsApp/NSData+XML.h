//
//  NSData+XML.h
//  NewsApp
//
//  Created by liukai on 14-11-26.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GDataXMLNode.h>
@interface NSData (XML)
-(GDataXMLDocument*)ObjectFromHTMLData;

@end
