//
//  ViewController.m
//  KJShareDemo
//
//  Created by 杨科军 on 2019/9/6.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "ViewController.h"
#import "ShareView/KJShareView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)Action1:(UIButton *)sender {
    /// 第一种使用方法
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"标题" descr:@"小标题" thumImage:[UIImage imageNamed:@"icon"]];
    //设置网页地址
    shareObject.webpageUrl = @"www.baidu.com";
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    KJShareView *shareView = [KJShareView createShareView:nil];
    shareView.messageObject = messageObject;
    shareView.kj_completeBlock = ^(id data, NSError *error) {
        NSString *msg = error == nil ? @"分享成功" : @"分享失败";
    };
}

- (IBAction)Action2:(id)sender {
    /// 第二种使用方法
    KJShareView *shareView = [KJShareView createShareView:nil];
    /// 设置分享平台
    shareView.platformTemps = @[@(KJShareViewPlatformTypeWeChatSession),@(KJShareViewPlatformTypeWechatTimeLine)];
    shareView.title = @"标题";
    shareView.descr = @"小标题";
    shareView.hdImage = shareView.thumbImage = @"图片";
    shareView.hdWebpageUrl = @"www.baidu.com";
    shareView.correlationID = @"123";
    shareView.pathType = KJShareViewSharePathTypeZQRZDetail;
    [shareView shareWithContentType:(KJShareViewContentTypeMiniProgram) CompleteBlock:^(id data, NSError *error) {
        NSString *msg = error == nil ? @"分享成功" : @"分享失败";
//        [MBProgressHUD showMessage:msg];
    }];
}

@end
