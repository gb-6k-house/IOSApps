//
//  UICommonMacro.h
//  Bussiness
//
//  Created by liukai on 14-7-21.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>


#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)


#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define AFTER_VIEW_Y(view) (view.frame.origin.y+view.frame.size.height)
#define AFTER_VIEW_X(view) (view.frame.origin.x+view.frame.size.width)
#define BASE_VIEW_X(view) (view.frame.origin.x)
#define BASE_VIEW_Y(view) (view.frame.origin.y)
#define BASE_VIEW_WIDTH(view) (view.frame.size.width)
#define BASE_VIEW_HEIGHT(view) (view.frame.size.height)

#define GET_IMAGE(IMAGE_NAME) [UIImage imageNamed:IMAGE_NAME]
#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0F green:G/255.0F blue:B/255.0F alpha:A]
#define GET_FONT(size) [UIFont systemFontOfSize:size]
#define GET_VIEW_BY_NibName(name)\
[[[NSBundle mainBundle]loadNibNamed:name owner:self options:nil]firstObject];
//系统版本号
#define Sys_Version  ([[UIDevice currentDevice].systemVersion floatValue])

