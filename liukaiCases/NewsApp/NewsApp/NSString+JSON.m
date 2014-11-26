//
//  NSString+JSON.m
//  Bussiness
//
//  Created by liukai on 14-8-15.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "NSString+JSON.h"
#import "LogInfo.h"


@implementation NSString (JSON)
-(id)objectFromJSONString{
    NSData * jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    return jsonObject;
}

@end
