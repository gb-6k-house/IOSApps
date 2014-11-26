//
//  NSString+XMl.h
//  yhcServerCoreLib
//
//  Created by liukai on 14-9-19.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
@interface NSString (XMl)
-(GDataXMLDocument*)ObjectFromXmlString;
@end
