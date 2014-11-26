//
//  UserDataModel.h
//  RongCloud
//
//  Created by Heq.Shinoda on 14-5-5.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KUserDataModel_Key_UserID       @"userId"
#define KUserDataModel_Key_UserName     @"userName"
#define KUserDataModel_Key_UserEmail    @"cookie"

@interface UserDataModel : NSObject

@property(nonatomic, strong) NSString* userId;
@property(nonatomic, strong) NSString* username;
@property(nonatomic, strong) NSString* userEmail;
@property(nonatomic, strong) NSString* usernamePinyin;
@property(nonatomic, strong) NSString* portraitPath;

-(id)initWithUserData:(NSString*)aUID userName:(NSString*)aUName userNamePY:(NSString*)aUNPY portrait:(NSString*)aPortrait user_Email:(NSString*)aUserEmail;
@end


//-----User Manager----//
@interface UserManager : NSObject
@property(strong, atomic) UserDataModel* mainUser;
+(UserManager*)shareMainUser;
@end
