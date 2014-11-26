//
//  CQQMasterService.h
//  NewsApp
//
//  Created by liukai on 14-11-19.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import "CHttpServiceBase.h"
@protocol CQQMasterServiceDelegate <NSObject>
@end

@interface CQQMasterService : CHttpServiceBase
/*
 *获取腾讯大家，首页信息
 */
-(void)getHomeInfoFor:(id<CQQMasterServiceDelegate>)delegate;
@end
