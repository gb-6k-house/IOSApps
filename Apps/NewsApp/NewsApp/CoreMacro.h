//
//  CoreMacro.h
//  Bussiness
//
//  Created by liukai on 14-7-18.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SINGLETON_DEFINE(className) \
\
+ (className *)sharedInstance; \

#define SINGLETON_IMPLEMENT(className) \
\
+ (className *)sharedInstance { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}
