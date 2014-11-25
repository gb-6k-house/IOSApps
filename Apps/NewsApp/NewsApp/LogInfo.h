//
//  LogInfo.h
//  Bussiness
//
//  Created by liukai on 14-7-23.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDLog.h>
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


