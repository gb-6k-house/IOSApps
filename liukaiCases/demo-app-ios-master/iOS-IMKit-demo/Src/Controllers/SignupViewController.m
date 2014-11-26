//
//  SignupViewController.m
//  iOS-IMKit-demo
//
//  Created by Heq.Shinoda on 14-6-5.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import "SignupViewController.h"
#import "MMProgressHUD.h"
#import "RCHttpRequest.h"
#import "DemoUIConstantDefine.h"
#import "DemoCommonConfig.h"

@interface RCTextField : UITextField
@end

@interface SignupViewController ()<UITextFieldDelegate,HttpConnectionDelegate>

@end

@implementation RCTextField
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y + 8,
                      bounds.size.width - 20, bounds.size.height - 16);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end


@implementation SignupViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)cancelSignup {
    [self invalidateFirstResponders];
    [self dismissViewControllerAnimated:YES completion:nil];
}


/**
 *	@brief	键盘出现
 *
 *	@param 	aNotification 	参数
 */
- (void)keyboardWillShow:(NSNotification *)aNotification

{
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.frame = CGRectMake(0.f, -35.f, self.view.frame.size.width, self.view.frame.size.height);
        
    }completion:nil] ;
    
}

/**
 *	@brief	键盘消失
 *
 *	@param 	aNotification 	参数
 */
- (void)keyboardWillHide:(NSNotification *)aNotification {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
    }completion:nil];
    
}

-(void)configureNavigationBar {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil)
                                                                     style:UIBarButtonItemStylePlain target:self
                                                                    action:@selector(cancelSignup)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    title.font = [UIFont systemFontOfSize:18];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = NSLocalizedString(@"注册", nil);
    self.navigationItem.titleView = title;
    [self.view setBackgroundColor:RGBCOLOR(230, 230, 230)];
    [self configureNavigationBar];
    [self configViews];
}

-(void)configViews {
    
    UIView *signupFormContainer = [[UIView alloc] initWithFrame:CGRectZero];

    RCTextField *emailField= [[RCTextField alloc] initWithFrame:CGRectZero];
    emailField.tag = Tag_EmailTextField;
    emailField.returnKeyType = UIReturnKeyNext;
    emailField.delegate = self;
    emailField.placeholder = NSLocalizedString(@"输入邮箱", nil);
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    emailField.layer.borderWidth = 1.f;
    emailField.layer.cornerRadius = 4.f;
    emailField.backgroundColor = [UIColor whiteColor];

    RCTextField *usernameField = [[RCTextField alloc] initWithFrame:CGRectZero];
    usernameField.tag = Tag_AccountTextField;
    usernameField.returnKeyType = UIReturnKeyNext;
    usernameField.delegate = self;
    usernameField.placeholder = NSLocalizedString(@"输入昵称（4－12个字母）", nil);
    usernameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    usernameField.layer.borderWidth = 1.f;
    usernameField.layer.cornerRadius = 4.f;
    usernameField.backgroundColor = [UIColor whiteColor];

    
    RCTextField *passwordField = [[RCTextField alloc] initWithFrame:CGRectZero];
    passwordField.tag = Tag_TempPasswordTextField;
    passwordField.returnKeyType = UIReturnKeyDone;
    passwordField.secureTextEntry = YES;
    passwordField.delegate = self;
    passwordField.placeholder = NSLocalizedString(@"输入密码（6-16个字符，区分大小写）", nil);
    passwordField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    passwordField.layer.borderWidth = 1.f;
    passwordField.layer.cornerRadius = 4.f;
    passwordField.backgroundColor = [UIColor whiteColor];


    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton addTarget:self action:@selector(handleSignup:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *buttonImage = [[UIImage imageNamed:@"regist_view_reg_btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.f, 7.f, 7.f, 7.f)];
    [submitButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [submitButton setTitle:NSLocalizedString(@"同意并注册", nil) forState:UIControlStateNormal];
    [submitButton setTitleColor:HEXCOLOR(0x585858) forState:UIControlStateNormal];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [submitButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    [signupFormContainer addSubview:emailField];
    [signupFormContainer addSubview:usernameField];
    [signupFormContainer addSubview:passwordField];
    [signupFormContainer addSubview:submitButton];
    [self.view addSubview:signupFormContainer];
    
    signupFormContainer.translatesAutoresizingMaskIntoConstraints = NO;
    emailField.translatesAutoresizingMaskIntoConstraints = NO;
    usernameField.translatesAutoresizingMaskIntoConstraints = NO;
    passwordField.translatesAutoresizingMaskIntoConstraints = NO;
    submitButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(signupFormContainer, emailField, usernameField, passwordField, submitButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[signupFormContainer]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:signupFormContainer
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.f
                                                           constant:40]];
    NSArray *constraints = [[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[emailField]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views] arrayByAddingObjectsFromArray:
                            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[usernameField]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views]] arrayByAddingObjectsFromArray:
                            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[passwordField]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views]] arrayByAddingObjectsFromArray:
                            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[submitButton]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views]] arrayByAddingObjectsFromArray:
                            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[emailField(45)]-10-[usernameField(45)]-10-[passwordField(45)]-40-[submitButton(45)]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views]];
    
    [signupFormContainer addConstraints:constraints];
    
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
}

- (void)handleSignup:(id)sender {
    if ([self checkValidityTextField]) {
        [self registToFakeServer];
    }
}

- (BOOL)checkValidityTextField
{
    if ([(UITextField *)[self.view viewWithTag:Tag_EmailTextField] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_EmailTextField] text] isEqualToString:@""]) {
        [self alertTitle:@"提示" message:@"邮箱不能为空" delegate:self cancelBtn:@"取消" otherBtnName:nil];
        return NO;
    }
    if ([(UITextField *)[self.view viewWithTag:Tag_AccountTextField] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_AccountTextField] text] isEqualToString:@""]) {
        [self alertTitle:@"提示" message:@"用户名不能为空" delegate:self cancelBtn:@"取消" otherBtnName:nil];
        return NO;
    }
    if ([(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text] isEqualToString:@""]) {
        [self alertTitle:@"提示" message:@"用户密码不能为空" delegate:self cancelBtn:@"取消" otherBtnName:nil];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate Method

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
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
                
                if ([[textField text] length] < 6) {
                    
                    [self alertTitle:@"提示" message:@"请输入6－16位的密码！" delegate:nil cancelBtn:@"取消" otherBtnName:nil];
                    return;
                }
                else if ([[textField text] length] >16)
                {
                    [self alertTitle:@"提示" message:@"请输入6－16位的密码！" delegate:nil cancelBtn:@"取消" otherBtnName:nil];
                    textField.text = [textField.text substringToIndex:16];
                    return;
                }
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
    //邮箱
    [[self.view viewWithTag:Tag_EmailTextField] resignFirstResponder];
    //用户名
    [[self.view viewWithTag:Tag_AccountTextField] resignFirstResponder];
    //temp密码
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

-(void)registToFakeServer
{
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithStatus:@"正在提交注册……"];
    NSString* userName = (NSString*)[(UITextField *)[self.view viewWithTag:Tag_AccountTextField] text];
    NSString* userEmail = [(UITextField *)[self.view viewWithTag:Tag_EmailTextField] text];
    NSString* userPSWord= [(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text];
    NSString* strParams = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"email",userEmail,@"password",userPSWord, @"username",userName];
    [[RCHttpRequest defaultHttpRequest] httpConnectionWithURL:[NSString stringWithFormat:@"%@reg",FAKE_SERVER] bodyData:[strParams dataUsingEncoding:NSUTF8StringEncoding] delegate:self];
}


#pragma mark - HttpConnectionDelegate
- (void)responseHttpConnectionSuccess:(RCHttpRequest *)request
{
    if(request.response.statusCode == 200)
    {
        NSError* error = nil;
        NSDictionary * regDataDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:&error];
        DebugLog(@"TTT %@",regDataDict);
        [MMProgressHUD dismissWithSuccess:@"注册成功！"];
        [self cancelSignup];
    }
    else
    {
        [MMProgressHUD dismiss];
        DebugLog(@"Connection Result:%@",request.response);
        [self alertTitle:@"提示" message:[NSString stringWithFormat:@"注册帐号失败 : %d",(int)request.response.statusCode ] delegate:nil cancelBtn:@"确定" otherBtnName:nil];
    }
    
}

- (void)responseHttpConnectionFailed:(RCHttpRequest *)request didFailWithError:(NSError *)error
{
    [MMProgressHUD dismiss];
    [self alertTitle:@"提示" message:@"网络原因，注册帐号失败" delegate:nil cancelBtn:@"确定" otherBtnName:nil];
}

@end
