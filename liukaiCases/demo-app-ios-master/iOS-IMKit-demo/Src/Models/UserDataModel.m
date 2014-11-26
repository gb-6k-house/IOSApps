//
//  UserDataModel.m
//  RongCloud
//
//  Created by Heq.Shinoda on 14-5-5.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "UserDataModel.h"


@implementation UserDataModel
@synthesize userId, username, usernamePinyin, portraitPath;
-(id)init
{
    self = [super init];
    return self;
}

-(id)initWithUserData:(NSString*)aUID userName:(NSString*)aUName userNamePY:(NSString*)aUNPY portrait:(NSString*)aPortrait user_Email:(NSString*)aUserEmail

{
    self = [super init];
    if(self)
    {
        self.userId = aUID;
        self.username = aUName;
        self.usernamePinyin = aUNPY;
        self.userEmail = aUserEmail;
        self.portraitPath = aPortrait;
    }
    return self;
}

@end

//-----User Manager----//
static UserManager *pUserManagerInst = nil;

@implementation UserManager
@synthesize mainUser;

+(UserManager*)shareMainUser
{
    @synchronized(self)
    {
        if(pUserManagerInst == nil)
        {
            pUserManagerInst = [[UserManager alloc] init];
            pUserManagerInst.mainUser = nil;
        }
    }
    return pUserManagerInst;
}

@end