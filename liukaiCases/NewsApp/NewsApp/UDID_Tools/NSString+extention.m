//
//  NSString+extention.m
//  yhcServerCoreLib
//
//  Created by liukai on 14-9-20.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "NSString+extention.h"

@implementation NSString (extention)
-(int)strcmp:(NSString*)t{
    return strcmp([self cStringUsingEncoding:NSASCIIStringEncoding], [t cStringUsingEncoding:NSASCIIStringEncoding]);
}

@end
