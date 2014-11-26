//
//  SigninViewController.m
//  iOS-IMKit-demo
//
//  Created by Heq.Shinoda on 14-6-5.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import "SigninViewController.h"
#import "RCUserInfo.h"

#import "SignupViewController.h"
#import "MMProgressHUD.h"

#import "DemoUIConstantDefine.h"

#import "UserDataModel.h"

#import "DemoCommonConfig.h"
#import "HomeViewController.h"

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define NAVI_BAR_HEIGHT 44.0f

@interface SigninViewController () <RCIMFriendsFetcherDelegate, RCIMUserInfoFetcherDelegagte>
@property(nonatomic, strong) NSMutableArray *allFriendsArray;
@end

@implementation SigninViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0.f, -35.f, self.view.frame.size.width, self.view.frame.size.height);
    }completion:nil] ;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
    }completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [self configViews];
    loginToken = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)configViews
{
    [self.view setBackgroundColor:HEXCOLOR(0x59B1DA)];
    UIImage *rongLogoImage = [[UIImage imageNamed:@"login_view_logo"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImageView *rongLogo = [[UIImageView alloc] initWithImage:rongLogoImage];
    [self.view addSubview:rongLogo];
    
    UIImage *inputBackgroundImage = [[UIImage imageNamed:@"input_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f)];
    UIImageView *inputBackground = [[UIImageView alloc] init];
    [inputBackground setImage:inputBackgroundImage];
    inputBackground.userInteractionEnabled = YES;
    [self.view addSubview:inputBackground];
    
    UIImage *seperatorImage = [[UIImage imageNamed:@"split_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
    UIImageView *seperator = [[UIImageView alloc] initWithImage:seperatorImage];
    [inputBackground addSubview:seperator];
    
    UIImage *usernameIconImage = [[UIImage imageNamed:@"user_icon"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.f, 3.f, 3.f, 3.f)];
    UIImageView *usernameIcon = [[UIImageView alloc] initWithImage:usernameIconImage];
    [inputBackground addSubview:usernameIcon];
    
    UIImage *passwordIconImage = [[UIImage imageNamed:@"password_icon"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.f, 3.f, 3.f, 3.f)];
    UIImageView *passwordIcon = [[UIImageView alloc] initWithImage:passwordIconImage];
    [inputBackground addSubview:passwordIcon];
    
    
    
    
    UITextField *usernameTextField = [[UITextField alloc] init];
    usernameTextField.tag = Tag_EmailTextField;
    usernameTextField.textColor = [UIColor whiteColor];
    usernameTextField.returnKeyType = UIReturnKeyNext;
    usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    usernameTextField.delegate = self;
    if ([usernameTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = HEXCOLOR(0xffffff);
        usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"用户名", nil)
                                                                                  attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        usernameTextField.placeholder = NSLocalizedString(@"用户名", nil);
    }
    usernameTextField.text = [self getDefaultUser];
    [inputBackground addSubview:usernameTextField];
    
    
    UITextField *passwordTextField = [[UITextField alloc] init];
    passwordTextField.tag = Tag_TempPasswordTextField;
    passwordTextField.textColor = [UIColor whiteColor];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.delegate = self;
    if ([passwordTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = HEXCOLOR(0xffffff);
        passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"密码", nil)
                                                                                  attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        passwordTextField.placeholder = NSLocalizedString(@"密码", nil);
    }
    passwordTextField.text = [self getDefaultUserPwd];
    [inputBackground addSubview:passwordTextField];
    
    
    UIEdgeInsets buttonEdgeInsets = UIEdgeInsetsMake(7.f, 7.f, 7.f, 7.f);
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setBackgroundImage:[[UIImage imageNamed:@"login_view_login_btn_bg"] resizableImageWithCapInsets:buttonEdgeInsets] forState:UIControlStateNormal];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [loginButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.view addSubview:loginButton];
    
    
    UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupButton addTarget:self action:@selector(prepareForSignup:) forControlEvents:UIControlEventTouchUpInside];
    [signupButton setBackgroundImage:[[UIImage imageNamed:@"login_view_regist_btn_bg"] resizableImageWithCapInsets:buttonEdgeInsets] forState:UIControlStateNormal];
    [signupButton setTitle:@"注册" forState:UIControlStateNormal];
    [signupButton setTitleColor:HEXCOLOR(0x585858) forState:UIControlStateNormal];
    signupButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [signupButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.view addSubview:signupButton];
    
    
    UILabel *buildVersionLabel = [[UILabel alloc] init];
    [buildVersionLabel setFont:[UIFont systemFontOfSize:10]];
    [buildVersionLabel setTextAlignment:NSTextAlignmentCenter];
    [buildVersionLabel setBackgroundColor:[UIColor clearColor]];
    [buildVersionLabel setTextColor:[UIColor whiteColor]];
    NSString * buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSString *buildVersionTextFormat = NSLocalizedString(@"version: %@", nil);
    [buildVersionLabel setText:[NSString stringWithFormat:buildVersionTextFormat, buildVersion]];
    [self.view addSubview:buildVersionLabel];
    
    UILabel *shortVersionLabel = [[UILabel alloc] init];
    [shortVersionLabel setFont:[UIFont systemFontOfSize:10]];
    [shortVersionLabel setTextAlignment:NSTextAlignmentCenter];
    [shortVersionLabel setBackgroundColor:[UIColor clearColor]];
    [shortVersionLabel setTextColor:[UIColor whiteColor]];
    
    NSString * shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNumberTextFormat = NSLocalizedString(@"version: %@", nil);
    [shortVersionLabel setText:[NSString stringWithFormat:buildNumberTextFormat,shortVersion]];
    
    [self.view addSubview:shortVersionLabel];
    
    //!\warning before using autolayout, disable autoresizingmask constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(rongLogo, inputBackground, loginButton, signupButton, buildVersionLabel, shortVersionLabel);
    NSDictionary *formViews = NSDictionaryOfVariableBindings(seperator, usernameIcon, passwordIcon, usernameTextField, passwordTextField);
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    rongLogo.translatesAutoresizingMaskIntoConstraints = NO;
    inputBackground.translatesAutoresizingMaskIntoConstraints = NO;
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    signupButton.translatesAutoresizingMaskIntoConstraints = NO;
    buildVersionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    shortVersionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    seperator.translatesAutoresizingMaskIntoConstraints = NO;
    usernameIcon.translatesAutoresizingMaskIntoConstraints = NO;
    passwordIcon.translatesAutoresizingMaskIntoConstraints = NO;
    usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    

    NSArray *inputHorizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[seperator]-0-|"
                                                                                   options:NSLayoutFormatAlignAllCenterY
                                                                                   metrics:nil
                                                                                     views:formViews];
    
    NSArray *inputHorizontalConstraint2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[usernameIcon(26)]-[usernameTextField]-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:formViews];
    NSArray *inputHorizontalConstraint3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[passwordIcon(26)]-[passwordTextField]-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:formViews];
    
    
    NSArray *inputVerticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-11-[usernameIcon]-7-[seperator]-7-[passwordIcon]-11-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:formViews];
    NSArray *inputVerticalConstraints3 =  [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-11-[usernameTextField]-7-[seperator]-7-[passwordTextField]-11-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:formViews];
    
    NSArray *inputConstraints = [[[[inputHorizontalConstraints1 arrayByAddingObjectsFromArray: inputHorizontalConstraint2]
                                    arrayByAddingObjectsFromArray: inputHorizontalConstraint3]
                                  arrayByAddingObjectsFromArray: inputVerticalConstraints2]
                                 arrayByAddingObjectsFromArray: inputVerticalConstraints3];
    
    [inputBackground addConstraints:inputConstraints];

    
    
    NSArray *constraintsVertical1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[rongLogo]-30-[inputBackground(89)]-30-[loginButton]-9-[signupButton]-20-[buildVersionLabel]-[shortVersionLabel]"
                                                                              options:NSLayoutFormatAlignAllCenterX
                                                                              metrics:nil
                                                                                views:views];
    
    NSArray *constraintsHorizontal1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-28-[inputBackground]-28-|"
                                                                              options:NSLayoutFormatAlignAllCenterX
                                                                              metrics:nil
                                                                                views:views];
    NSArray *constraintsHorizontal2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-28-[loginButton]-28-|"
                                                                              options:NSLayoutFormatAlignAllCenterX
                                                                              metrics:nil
                                                                                views:views];
    NSArray *constraintsHorizontal3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-28-[signupButton]-28-|"
                                                                              options:NSLayoutFormatAlignAllCenterX
                                                                              metrics:nil
                                                                                views:views];
    NSLayoutConstraint *signupButtonConstraints = [NSLayoutConstraint constraintWithItem:signupButton
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:loginButton
                                                                               attribute:NSLayoutAttributeWidth
                                                                              multiplier:1.f
                                                                                constant:0];
    NSArray *constraintsCollection = [[[[[NSArray arrayWithArray:constraintsVertical1]
                                      arrayByAddingObjectsFromArray:constraintsHorizontal1]
                                      arrayByAddingObjectsFromArray:constraintsHorizontal2]
                                      arrayByAddingObjectsFromArray:constraintsHorizontal3]
                                      arrayByAddingObject:signupButtonConstraints];
    
    [self.view addConstraints:constraintsCollection];
}

-(NSString*)getDefaultUser
{
    NSString* defaultUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"RC_LAST_USERNAME"];
    return defaultUser;
}

-(NSString*)getDefaultUserPwd
{
    NSString* defaultUserPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"RC_LAST_USERPWD"];
    return defaultUserPwd;
}

-(void)setDefaultUser:(NSString*)user pwd:(NSString*)pwd
{
    if(user == nil)
    {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"RC_LAST_USERNAME"];
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:@"RC_LAST_USERPWD"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)login:(id)sender
{
    if ([self checkValidityTextField]) {
        [self invalidateFirstResponders];
        [self loginToFakeServer];
    }
    NSString* userEmail = [(UITextField *)[self.view viewWithTag:Tag_EmailTextField] text];
    NSString* userPSWord= [(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text];
    [self setDefaultUser:userEmail pwd:userPSWord];
}

-(void)loginToFakeServer
{
    NSString* userEmail = [(UITextField *)[self.view viewWithTag:Tag_EmailTextField] text];
    NSString* userPSWord= [(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text];
    NSString* deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
    //----登录server----//
    NSString* strParams = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"email",userEmail,@"password",userPSWord, @"deviceid",(deviceToken==nil?@"":deviceToken)];
    
    self.loginRequest = [[RCHttpRequest alloc]init];
    self.loginRequest.tag = 1000;
    
    [self.loginRequest httpConnectionWithURL:[NSString stringWithFormat:@"%@login",FAKE_SERVER]
                                    bodyData:[strParams dataUsingEncoding:NSUTF8StringEncoding]
                                    delegate:self];
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:@"正在登录" status:@"……" cancelBlock:nil];
}


#pragma mark - RegisterBtnClicked Method
- (void)prepareForSignup:(id)sender {
    [self invalidateFirstResponders];
    SignupViewController* regVC = [[SignupViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:regVC];
    UIImage *image= [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self presentViewController:navigationController animated:YES completion:nil];
}

/**
 *	@brief	验证文本框是否为空
 */
#pragma mark checkValidityTextField Null
- (BOOL)checkValidityTextField
{
    if ([(UITextField *)[self.view viewWithTag:Tag_EmailTextField] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_EmailTextField] text] isEqualToString:@""]) {
        
        [self alertTitle:@"提示" message:@"邮箱不能为空" delegate:self cancelBtn:@"取消" otherBtnName:nil];
        
        return NO;
    }
    if ([(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text] isEqualToString:@""]) {
        
        [self alertTitle:@"提示" message:@"用户密码不能为空" delegate:self cancelBtn:@"取消" otherBtnName:nil];
        
        return NO;
    }
    if (![self isValidateEmail:[(UITextField *)[self.view viewWithTag:Tag_EmailTextField] text]]) {
        
        [self alertTitle:@"提示" message:@"邮箱格式不正确" delegate:nil cancelBtn:@"取消" otherBtnName:nil];
        return NO;
    }
#if CHECK_PASSWORD_ENABLE
    if ([[(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text] length] < 6) {
        
        [self alertTitle:@"提示" message:@"用户密码小于6位！" delegate:nil cancelBtn:@"取消" otherBtnName:nil];
        return NO;
    }
#endif//CHECK_PASSWORD_ENABLE
    
    return YES;
    
}

#pragma mark - UITextFieldDelegate Method

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case Tag_EmailTextField:
        {
            if ([textField text] != nil && [[textField text] length]!= 0) {
                
                if (![self isValidateEmail:textField.text]) {
                    
                    [self alertTitle:@"提示" message:@"邮箱格式不正确" delegate:nil cancelBtn:@"取消" otherBtnName:nil];
                    return;
                }
                
            }
        }
            break;
        case Tag_TempPasswordTextField:
        {
            if ([textField text] != nil && [[textField text] length]!= 0) {
#if CHECK_PASSWORD_ENABLE
                if ([[textField text] length] < 6) {
                    
                    [self alertTitle:@"提示" message:@"用户密码小于6位！" delegate:nil cancelBtn:@"取消" otherBtnName:nil];
                    return;
                }
#endif//CHECK_PASSWORD_ENABLE
            }
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - touchMethod
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
    [self invalidateFirstResponders];
}

#pragma mark - PrivateMethod
- (void)invalidateFirstResponders{
    
    //用户名
    [[self.view viewWithTag:Tag_EmailTextField] resignFirstResponder];
    //密码
    [[self.view viewWithTag:Tag_TempPasswordTextField] resignFirstResponder];
}


-(UILabel *)labelWithFrame:(CGRect)frame withTitle:(NSString *)title titleFontSize:(UIFont *)font textColor:(UIColor *)color backgroundColor:(UIColor *)bgColor alignment:(NSTextAlignment)textAlignment{
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = bgColor;
    label.textAlignment = textAlignment;
    return label;
    
}

-(UIAlertView *)alertTitle:(NSString *)title message:(NSString *)msg delegate:(id)aDeleagte cancelBtn:(NSString *)cancelName otherBtnName:(NSString *)otherbuttonName{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:aDeleagte cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName, nil];
    [alert show];
    return alert;
}

//利用正则表达式验证邮箱的合法性
-(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
    
}

#pragma mark - HttpConnectionDelegate
- (void)responseHttpConnectionSuccess:(RCHttpRequest *)request
{
    if (1000 == request.tag) {
        if(request.response.statusCode == 200)
        {
            NSError* error = nil;
            NSDictionary * regDataDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:&error];
            
            NSString* token = regDataDict[@"token"];
            loginToken = token;
            
            UserDataModel* curUser = [[UserDataModel alloc] initWithUserData:[NSString stringWithFormat:@"%d",[regDataDict[KUserDataModel_Key_UserID] intValue]] userName:regDataDict[KUserDataModel_Key_UserName] userNamePY:@"" portrait:@"" user_Email:regDataDict[KUserDataModel_Key_UserEmail]];
            [UserManager shareMainUser].mainUser = curUser;
            
            RCUserInfo *userInfo = [RCUserInfo new];
            userInfo.userId = regDataDict[KUserDataModel_Key_UserID];
            userInfo.name = regDataDict[KUserDataModel_Key_UserName];
            [self requestFriendsList];
        }
        else
        {
            [MMProgressHUD dismiss];
            DebugLog(@"Connection Result:%@",request.response);
            [self alertTitle:@"提示"
                     message:[NSString stringWithFormat:@"帐号或密码错误，无法登录 : %d",(int)request.response.statusCode ]
                    delegate:nil
                   cancelBtn:@"确定"
                otherBtnName:nil];
        }

    }else{
        
        if(request.response.statusCode == 200)
        {
            NSError* error = nil;
            NSArray * regDataArray = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:&error];
            
//            DebugLog(@"%@",regDataArray);
            
            self.allFriendsArray = [[NSMutableArray alloc]initWithCapacity:0];
            for(int i= 0;i <regDataArray.count;i++){
                
                NSDictionary *dic = regDataArray[i];
                RCUserInfo *userInfo = [RCUserInfo new];
                NSNumber *idNum = dic[@"id"];
                userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                userInfo.portraitUri = dic[@"portrait"];
                userInfo.name = dic[@"username"];
                //----好友列表中将自己排除掉。
                if([[UserManager shareMainUser].mainUser.userId isEqualToString:userInfo.userId])
                {
                    continue;
                }
                [self.allFriendsArray addObject:userInfo];
            }
            
            //----为刘备or吕蒙不同环境预留。----//
            typeof(self) __weak weakSelf = self;
            
            //使用DEMO注意：更换appkey，一定要更换对应的连接token，如果token未做变化，默认会从融云测试环境获取，照成appkey和token不一致
            [RCIM connectWithToken:loginToken completion:^(NSString *userId) {
                [MMProgressHUD dismissWithSuccess:@"登录成功!"];
                HomeViewController *temp = [[HomeViewController alloc]init];
                temp.currentUserId = userId;
                [weakSelf.navigationController pushViewController:temp animated:YES];
            } error:^(RCConnectErrorCode status) {
                if(status == 0)
                {
                    [MMProgressHUD dismissWithSuccess:@"登录成功!"];
                    HomeViewController *temp = [[HomeViewController alloc]init];
                    [weakSelf.navigationController pushViewController:temp animated:YES];
                }
                else
                {
                    [MMProgressHUD dismissWithSuccess:[NSString stringWithFormat:@"登录失败！\n Code: %d！", (int)status]];
                }
            }];
            [RCIM setFriendsFetcherWithDelegate:self];
            [RCIM setUserInfoFetcherWithDelegate:self isCacheUserInfo:NO];
        }
        else
        {
            self.allFriendsArray = nil;
        }
        
       
    }
}

- (void)responseHttpConnectionFailed:(RCHttpRequest *)connection didFailWithError:(NSError *)error
{
    if (1000 == connection.tag) {
        [MMProgressHUD dismiss];
        [self alertTitle:@"提示" message:@"网络原因，登录失败" delegate:nil cancelBtn:@"确定" otherBtnName:nil];
    }
    
}

-(void)requestFriendsList
{
    //获取好友列表
    NSString *url = [NSString stringWithFormat:@"%@%@",FAKE_SERVER,@"friends"];
    
    NSString* strParams = [NSString stringWithFormat:@"cookie=%@",[UserManager shareMainUser].mainUser.userEmail];
    NSLog(@"http reuqest body %@",strParams);
    self.friendRquest = [[RCHttpRequest alloc]init];
    self.friendRquest.tag = 1001;
    [self.friendRquest httpConnectionWithURL:url bodyData:[strParams dataUsingEncoding:NSUTF8StringEncoding] delegate:self];
}


#pragma mark - RCConnectFinishedDelegate
-(void)responseConnectSuccess:(NSString *)userId
{
    DebugLog(@"DEMO: currerntUserId: %@",userId);
    [MMProgressHUD dismissWithSuccess:@"登录成功!"];
    
    
    HomeViewController *temp = [[HomeViewController alloc]init];
    
    [self.navigationController pushViewController:temp animated:YES];
}

-(void)responseConnectError:(RCConnectErrorCode)status
{
    if(status == 0)
    {
        [MMProgressHUD dismissWithSuccess:@"登录成功!"];
        HomeViewController *temp = [[HomeViewController alloc]init];
        [self.navigationController pushViewController:temp animated:YES];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MMProgressHUD dismissWithSuccess:[NSString stringWithFormat:@"登录失败！\n Code: %d！",(int)status]];
        });
    }
}

#pragma mark - RCIMFriendsFetcherDelegate method
-(NSArray *)getFriends
{
    return self.allFriendsArray;
}

#pragma mark - RCIMUserInfoFetcherDelegagte method
-(RCUserInfo *)getUserInfoWithUserId:(NSString *)userId
{
    RCUserInfo *user  = nil;
    if([userId length] == 0)
        return nil;
    for(RCUserInfo *u in self.allFriendsArray)
    {
        if([u.userId isEqualToString:userId])
        {
            user = u;
            break;
        }
    }
    return user;
}

@end
