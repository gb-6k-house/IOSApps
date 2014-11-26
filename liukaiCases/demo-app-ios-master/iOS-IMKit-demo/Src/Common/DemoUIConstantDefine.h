//
//  UIConstantDefine.h
//  RongCloud
//
//  Created by Heq.Shinoda on 14-5-17.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#ifndef RongCloud_UIConstantDefinition_h
#define RongCloud_UIConstantDefinition_h

//-----------UI-Macro Definination---------//
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define IMAGENAEM(Value) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(Value, nil) ofType:nil]]

#define IMAGE_BY_NAMED(value) [UIImage imageNamed:NSLocalizedString((value), nil)]

#define SCREEN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height
#define SCREEN_WIDTH  [[UIScreen mainScreen] applicationFrame].size.width

#endif//RongCloud_UIConstantDefinition_h
