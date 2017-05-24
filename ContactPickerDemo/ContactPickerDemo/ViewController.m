//
//  ViewController.m
//  ContactPickerDemo
//
//  Created by C on 2017/5/19.
//  Copyright © 2017年 C. All rights reserved.
//

#import "ViewController.h"

#import <ContactsUI/ContactsUI.h>

@interface ViewController () <CNContactPickerDelegate>

@property(nonatomic,strong) UILabel * phoneNumLabel;

@property(nonatomic,strong) UILabel * nameLabel;

@property(nonatomic,strong) UILabel * addressLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = [UIButton new];
    button.frame = CGRectMake((375 - 100) * 0.5, 100, 100, 50);
    [button setTitle:@"通讯录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(clickPickerButtonWith:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UILabel * name = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame) + 50, 200, 50)];
    name.center = CGPointMake(button.center.x, name.center.y);
    name.textColor = [UIColor redColor];
    name.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:name];
    self.nameLabel = name;
    
    UILabel * phone = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(name.frame) + 50, 200, 50)];
    phone.center = CGPointMake(button.center.x, phone.center.y);
    phone.textColor = [UIColor redColor];
    phone.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:phone];
    self.phoneNumLabel = phone;
    
    UILabel * address = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(phone.frame) + 50, 200, 50)];
    address.center = CGPointMake(button.center.x, address.center.y);
    address.textColor = [UIColor redColor];
    address.font = phone.font;
    [self.view addSubview:address];
    self.addressLabel = address;
}

- (void)clickPickerButtonWith:(UIButton *)sender
{
    // 先查看用户对通讯录授权状态
    // CNContactStore 是对联系人进行操作的类 理解为通讯录对象
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) { // 用户还没有授权
        // 请求授权
        CNContactStore * store = [CNContactStore new];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted == YES) {
                NSLog(@"用户同意授权");
                [self showContactPickerController];
            }else {
                NSLog(@"用户拒绝授权");
                [self showAlert];
            }
        }];
    }else if (status == CNAuthorizationStatusDenied) { // 拒绝授权
        [self showAlert];
    }else if (status == CNAuthorizationStatusRestricted) { // 受限制的授权
        [self showAlert];
    }else if (status == CNAuthorizationStatusAuthorized) { // 已经授权
        [self showContactPickerController];
    }
}

- (void)showContactPickerController
{
    CNContactPickerViewController * controller = [CNContactPickerViewController new];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

- (void)showAlert
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的通讯录暂未允许访问，请去设置->隐私里面授权 嘻嘻" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"嗯呐" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark - ContactPicker代理方法
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker
{
    NSLog(@"取消选取联系人");
}

// 选取联系人信息（不展开详情）
/******* 选取联系人的不展开详情和展开详情的代理方法都写了的时候，展开详情的代理方法就不执行。 *******/

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
//{
//    if (contact.familyName != nil && contact.givenName != nil) {
//        self.nameLabel.text = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
//    }
//    
//    //CNLabeledValue 是联系人手机号属性的对象 里面包含标签和值 是对应的
//    for (CNLabeledValue * labeledValue in contact.phoneNumbers) {
//        // CNLabeledValue中的label属性是联系人手机号的标识 比如：手机 住宅 工作 但是根据手机设置语言不同 可能会有中英文的字符串
//        NSString * label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
//        if ([label isEqualToString:@"mobile"] || [label isEqualToString:@"手机"]) {
//            // CNPhoneNumber 是一个不可变对象 里面存手机号
//            CNPhoneNumber * phoneNum = labeledValue.value;
//            NSString * phoneNumStr = phoneNum.stringValue;
//            self.phoneNumLabel.text = phoneNumStr;
//        }else {
//            self.phoneNumLabel.text = @"木有手机号";
//        }
//    }
//}

// 选取联系人信息（进入详情）
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    /*
    // 单独获取姓名
    CNContact * contact = contactProperty.contact;
    NSString * name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    NSLog(@"%@",name);
    
    // 单独获取号码
    CNPhoneNumber * phoneValue= contactProperty.value;
    NSString * phoneNumber = phoneValue.stringValue;
    NSLog(@"%@--%@",name, phoneNumber);
    
    // 单独获取地址
    CNPostalAddress * addressValue = contactProperty.value;
    NSLog(@"%@-%@",addressValue.city,addressValue.street);
    */
    
    /******* 以上三个获取都是单独的事件 如果在获取号码的时候再实现获取地址 就会崩溃 下面是组合方法 *******/
    
    /* 全部的key值
    // 姓名前缀
    CNContactNamePrefixKey
    // 名
    CNContactGivenNameKey
    // 中间名
    CNContactMiddleNameKey
    // 姓
    CNContactFamilyNameKey
    // 婚前姓
    CNContactPreviousFamilyNameKey
    // 姓名后缀
    CNContactNameSuffixKey
    // 昵称
    CNContactNicknameKey
    // 公司
    CNContactOrganizationNameKey
    // 部门
    CNContactDepartmentNameKey
    // 职位
    CNContactJobTitleKey
    // 名字拼音或音标
    CNContactPhoneticGivenNameKey
    // 中间名拼音或音标
    CNContactPhoneticMiddleNameKey
    // 姓拼音或音标
    CNContactPhoneticFamilyNameKey
    // 公司拼音或音标
    CNContactPhoneticOrganizationNameKey
    // 生日
    CNContactBirthdayKey
    // 农历
    CNContactNonGregorianBirthdayKey
    // 备注
    CNContactNoteKey
    // 图片
    CNContactImageDataKey
    // 缩略图
    CNContactThumbnailImageDataKey
    // 图片是否允许访问
    CNContactImageDataAvailableKey
    // 类型
    CNContactTypeKey
    // 号码
    CNContactPhoneNumbersKey
    // 电子邮件
    CNContactEmailAddressesKey
    // 地址
    CNContactPostalAddressesKey
    // 日期
    CNContactDatesKey
    // URL
    CNContactUrlAddressesKey                    
    // 关联人
    CNContactRelationsKey                       
    // 社交
    CNContactSocialProfilesKey                  
    // 即时通讯
    CNContactInstantMessageAddressesKey
    */
    
    CNContact * contact = contactProperty.contact;
    
    /******* 如果不设置ContactPicker的keys就是全选 *******/
//    NSArray * keys = @[CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactPostalAddressesKey];
//    picker.displayedPropertyKeys = keys;
    
    // 获取姓名
    self.nameLabel.text = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
    NSLog(@"姓名--->%@%@",contact.familyName,contact.givenName);
    // 获取号码
    for (CNLabeledValue * labeledValue in contact.phoneNumbers) {
        NSLog(@"labeledValue--->%@",labeledValue);
        NSString * label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
        if ([label isEqualToString:@"mobile"] || [label isEqualToString:@"手机"]) {
            CNPhoneNumber * phone = labeledValue.value;
            self.phoneNumLabel.text = phone.stringValue;
            NSLog(@"电话号--->%@",phone.stringValue);
        }
    }
    // 获取地址
    for (CNLabeledValue * labeledValue in contact.postalAddresses) {
        CNPostalAddress * adress = labeledValue.value;
        self.addressLabel.text = [NSString stringWithFormat:@"%@%@",adress.city,adress.street];
         NSLog(@"地址--->%@-%@",adress.city,adress.street);
    }
    
//     遍历通讯录的方法
//    CNContactStore * store = [CNContactStore new];
//    CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
//    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
//        NSLog(@"name--->%@%@",contact.familyName,contact.givenName);
//        for (CNLabeledValue * labeledValue in contact.postalAddresses) {
//            CNPostalAddress * adress = labeledValue.value;
//            NSLog(@"地址--->%@",adress.street);
//        }
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
