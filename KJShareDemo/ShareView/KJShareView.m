//
//  KJShareView.m
//  MoLiao
//
//  Created by 杨科军 on 2018/8/9.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#import "KJShareView.h"

#define SHARE_SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SHARE_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SHARE_COLOR_HEXA(hex,a) [UIColor colorWithRed:((hex&0xFF0000)>>16)/255.0f green:((hex&0xFF00)>>8)/255.0f blue:(hex&0xFF)/255.0f alpha:a]

@interface KJShareView()
@property(nonatomic,weak) UIViewController *saveVC;  // 保存父视图控制器
@property(nonatomic,strong) UIView *whiteBackView;
@property(nonatomic,assign) CGFloat whiteHeight; // 白色板的高度
@property(nonatomic,assign) KJShareViewContentType contentType;

@end

@implementation KJShareView

+ (KJShareView*)sharedSingleton{
    static KJShareView *sharedSingleton;
    @synchronized(self){
        if (!sharedSingleton){
            sharedSingleton = [[KJShareView alloc] init];
        }
        return sharedSingleton;
    }
}

#pragma mark - 友盟第三方
+ (UMSocialManager*)kj_UMSocialManger{
    /* 打开调试日志 */
#ifdef DEBUG
    [[UMSocialManager defaultManager] openLog:NO];
    //    [UMConfigure setLogEnabled:YES];
#else
    [[UMSocialManager defaultManager] openLog:NO];
    //    [UMConfigure setLogEnabled:NO];
#endif
    UMSocialManager *_manger = [UMSocialManager defaultManager];
    //设置友盟appkey
    [_manger setUmSocialAppkey:UMengAppKey];
    //设置微信的appKey和appSecret
    [_manger setPlaform:UMSocialPlatformType_WechatSession appKey:WXPayAPPID appSecret:WXAPPSERCET redirectURL:SHAREURL];
    // U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
    [_manger setPlaform:UMSocialPlatformType_QQ appKey:QQAPPKEY appSecret:QQAPPSERCET redirectURL:SHAREURL];
    //    //设置新浪的appKey和appSecret
    //    [_manger setPlaform:UMSocialPlatformType_Sina appKey:WBAPPKEY appSecret:WBAPPSERCET redirectURL:REDIRECTURL];
    
    return _manger;
}

- (void)config{
    self.platformTemps = @[@(KJShareViewPlatformTypeWeChatSession),
                           @(KJShareViewPlatformTypeWechatTimeLine),
                           @(KJShareViewPlatformTypeQQ),
                           ];
}

+ (instancetype)createShareView:(void(^)(KJShareView *obj))block{
    KJShareView *backView = [[KJShareView alloc] initWithFrame:CGRectMake(0, 0, SHARE_SCREEN_WIDTH, SHARE_SCREEN_HEIGHT)];
    backView.alpha = 0;
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:backView action:@selector(cancleAction)]];
    [[UIApplication sharedApplication].keyWindow addSubview:backView];
    [backView config];
    // 回调出去数据
    if (block) block(backView);
    [backView setUI];
    [backView addSubview:backView.whiteBackView];
    
    [UIView animateWithDuration:0.2 animations:^{
        backView.whiteBackView.frame = CGRectMake(0, SHARE_SCREEN_HEIGHT-backView.whiteHeight, SHARE_SCREEN_WIDTH, backView.whiteHeight);
        backView.alpha = 1;
    }];
    
    //    int64_t delayInSeconds = 0.2; // 延迟的时间
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // 变大抖动动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.2;
    animation.keyTimes = @[@0,@0.5,@0.6,@0.7,@0.8,@0.9,@1];
    animation.values = @[@0,@1.04,@0.97,@1.02,@0.98,@1.01,@1];
    [backView.whiteBackView.layer addAnimation:animation forKey:@"transform.scale"];
    //    });
    
    return backView;
}
/// 视图消失
- (void)cancleAction{
    [UIView animateWithDuration:0.2 animations:^{
        self.whiteBackView.frame = CGRectMake(0, SHARE_SCREEN_HEIGHT, SHARE_SCREEN_WIDTH, self.whiteHeight);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
#pragma mark - setUI
- (void)setUI{
    NSArray *array = [self checkSupportApplication];
    NSArray *images = array[0];
    NSArray *tags = array[1];
    if (images.count<5) {
        self.whiteHeight = (110) + (44);
    }else if (images.count<9){
        self.whiteHeight = (110)*2 + (44);
    }
    
    //    UILabel *lab = InsertLabel(self.whiteBackView, CGRectMake(0, 0, SHARE_SCREEN_WIDTH, 44), NSTextAlignmentCenter, @"请选择分享平台", SystemFontSize(16), SHARE_COLOR_HEXA(0x666666,1));
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SHARE_SCREEN_WIDTH, 44)];
    lab.backgroundColor = SHARE_COLOR_HEXA(0xF4F4F4, 1);
    lab.textColor = SHARE_COLOR_HEXA(0x666666,1);
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:16];
    lab.text = @"请选择分享平台";
    [self.whiteBackView addSubview:lab];
    
    for (int i=0; i<images.count; i++) {
        CGFloat w = (60);
        CGFloat h = (60);
        CGFloat space = (SHARE_SCREEN_WIDTH - 4*w) / 4;
        CGFloat x = space/2 + i % 4 * (w+space);
        CGFloat y = i / 4 == 0 ? (44+18) : ((44+18)*2+h);  // 如果为0就表示只有一排
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, y, w, h);
        button.tag = 520 + [tags[i] intValue];
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(thouchButton:) forControlEvents:UIControlEventTouchUpInside];
        //保证所有touch事件button的highlighted属性为NO,即可去除高亮效果
        [button addTarget:self action:@selector(preventFlicker:) forControlEvents:UIControlEventAllTouchEvents];
        [self.whiteBackView addSubview:button];
    }
}
#pragma mark - lazy
- (UIView*)whiteBackView{
    if (!_whiteBackView) {
        _whiteBackView = [[UIView alloc]initWithFrame:CGRectMake(0, SHARE_SCREEN_HEIGHT, SHARE_SCREEN_WIDTH, self.whiteHeight)];
        _whiteBackView.backgroundColor = SHARE_COLOR_HEXA(0xEAEEF1, 1);
        _whiteBackView.userInteractionEnabled = YES;
    }
    return _whiteBackView;
}
- (KJShareView *(^)(UIViewController *))VC {
    return ^(UIViewController *vc) {
        self.saveVC = vc;
        return self;
    };
}
//第三方安装检测
- (NSArray*)checkSupportApplication{
    NSMutableArray *images = @[].mutableCopy;
    NSMutableArray *tags = @[].mutableCopy;
    for (NSInteger i=0; i<self.platformTemps.count; i++) {
        KJShareViewPlatformType type = [self.platformTemps[i] integerValue];
        switch (type) {
            case KJShareViewPlatformTypeWeChatSession:
                if ([self kPhoneIsInstallWeChat] == YES) {
                    [images addObject:@"KJShareImage.bundle/微信"];
                    [tags addObject:@(0)];
                }
                break;
            case KJShareViewPlatformTypeWechatTimeLine:
                if ([self kPhoneIsInstallWeChat] == YES) {
                    [images addObject:@"KJShareImage.bundle/朋友圈"];
                    [tags addObject:@(1)];
                }
                break;
            case KJShareViewPlatformTypeSina:
                if ([self kPhoneIsInstallSina] == YES) {
                    [images addObject:@"KJShareImage.bundle/微博"];
                    [tags addObject:@(2)];
                }
                break;
            case KJShareViewPlatformTypeQQ:
                if ([self kPhoneIsInstallQQ] == YES) {
                    [images addObject:@"KJShareImage.bundle/QQ"];
                    [tags addObject:@(3)];
                }
                break;
            case KJShareViewPlatformTypeQzone:
                break;
            default:
                break;
        }
    }
    return @[images,tags];
}

#pragma mark - Action
- (void)preventFlicker:(UIButton *)button {
    button.highlighted = NO;
}
- (void)thouchButton:(UIButton*)sender{
    switch (sender.tag) {
        case 520:  // 微信
            [self customSharePlatform:UMSocialPlatformType_WechatSession];
            break;
        case 521: // 朋友圈
            [self customSharePlatform:UMSocialPlatformType_WechatTimeLine];
            break;
        case 522: // 微博
            [self customSharePlatform:UMSocialPlatformType_Sina];
            break;
        case 523: // QQ
            [self customSharePlatform:UMSocialPlatformType_QQ];
            break;
        default:
            break;
    }
}

#pragma mark - 分享
- (void)customSharePlatform:(UMSocialPlatformType)platfroms{
    __weak typeof(self) weakself = self;
    if (self.messageObject == nil) {
        UMSocialMessageObject *messageObject;
        switch (self.contentType) {
            case KJShareViewContentTypeMiniProgram: /// 小程序
                messageObject = platfroms == UMSocialPlatformType_WechatSession ? [self kj_shareMiniProgram] : [self kj_shareWebpage];
                break;
            case KJShareViewContentTypeWebpage: /// 网页H5
                messageObject = [self kj_shareWebpage];
                break;
            case KJShareViewContentTypeVideo: /// 视频
                messageObject = [self kj_shareVideo];
                break;
            default:
                break;
        }
        [[UMSocialManager defaultManager] shareToPlatform:platfroms messageObject:messageObject currentViewController:self.saveVC completion:^(id data, NSError *error) {
            !weakself.kj_completeBlock?:weakself.kj_completeBlock(data,error);
            [weakself cancleAction];
        }];
        return;
    }
    
    // 调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platfroms messageObject:self.messageObject currentViewController:self.saveVC completion:^(id data, NSError *error) {
        !weakself.kj_completeBlock?:weakself.kj_completeBlock(data,error);
        [weakself cancleAction];
    }];
}

/** 分享消息 type：消息类型  block：分享回调*/
- (void)shareWithContentType:(KJShareViewContentType)type CompleteBlock:(KJShareCompleteBlock)block{
    self.contentType = type;
    self.kj_completeBlock = block;
}
/// 分享视频
- (UMSocialMessageObject*)kj_shareVideo{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建视频内容对象
    UMShareVideoObject *shareObject = [UMShareVideoObject shareObjectWithTitle:self.title descr:self.descr thumImage:self.thumbImage];
    shareObject.videoUrl = self.videoUrl;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    return messageObject;
}
/// 分享网页
- (UMSocialMessageObject*)kj_shareWebpage{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.title descr:self.descr thumImage:self.thumbImage];
    //设置网页地址
    shareObject.webpageUrl = self.webpageUrl;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    return messageObject;
}
/// 分享小程序 https://www.jianshu.com/p/c75ba7561011
- (UMSocialMessageObject*)kj_shareMiniProgram{
    //创建分享消息对象
    UMSocialMessageObject  *messageObject = [UMSocialMessageObject messageObject];
    UMShareMiniProgramObject *shareObject = [UMShareMiniProgramObject shareObjectWithTitle:self.title descr:self.descr thumImage:self.thumbImage];
    shareObject.webpageUrl = self.hdWebpageUrl;//@"兼容微信低版本网页地址";
    shareObject.userName = self.userName ?: @"gh_19aeba931b99";;//@"小程序username，如 gh_3ac2059ac66f";
    shareObject.path = self.path;//@"小程序页面路径，如 pages/page10007/page10007";
    /** 小程序新版本的预览图 128k */
    shareObject.hdImageData = self.hdImage;
#ifdef DEBUG
    shareObject.miniProgramType = UShareWXMiniProgramTypeTest;
#else
    shareObject.miniProgramType = UShareWXMiniProgramTypeRelease; // 可选体验版和开发板
#endif
    messageObject.shareObject = shareObject;
    return messageObject;
}

#pragma mark - 分享的基本参数
- (void)kj_customWithTitle:(NSString*)title Descr:(NSString*)descr ThumbImage:(id)thumbImage{
    self.title = title;
    self.descr = descr;
    self.thumbImage = thumbImage;
}
#pragma mark - 小程序相关参数
- (void)kj_miniProgramWithHdWebpageUrl:(NSString*)hdWebpageUrl UserName:(NSString * _Nullable)userName Path:(NSString * _Nullable)path HdImage:(id)hdImage WithShareTicket:(BOOL)withShareTicket{
    self.hdWebpageUrl = hdWebpageUrl;
    self.userName = userName;
    self.hdImage = hdImage;
    if (path) self.path = path;
}

#pragma mark - getter/setter
- (void)setPathType:(KJShareViewSharePathType)pathType{
    NSString *string = KJShareViewSharePathTypeStringMap[pathType];
    /** 替换字符 判断字符串是否包含 *****id***** 替换成对应的 correlationID */
    if([string rangeOfString:@"*****id*****"].location != NSNotFound) {
        self.path = [string stringByReplacingOccurrencesOfString:@"*****id*****" withString:self.correlationID];
    }
}
- (void)setTitle:(NSString *)title{
    _title = title ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}
- (void)setThumbImage:(id)thumbImage{
    // 缩略图 UIImage或者NSData类型或者NSString类型（图片url）
    if ([thumbImage isKindOfClass:[NSString class]]) {
        _thumbImage = [UIImage imageNamed:thumbImage];
    }else if ([thumbImage isKindOfClass:[NSData class]]) {
        _thumbImage = [UIImage imageWithData:thumbImage];
    }else if ([thumbImage isKindOfClass:[UIImage class]]) {
        _thumbImage = thumbImage;
    }else{
        _thumbImage = kAppIcon;
    }
}
- (void)setHdImage:(id)hdImage{
    if ([hdImage isKindOfClass:[NSString class]]) {
        _hdImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:kImageWithUrlString(hdImage)]];
        UIImage *image = [UIImage imageWithData:_hdImage];
        _hdImage = [KJShareView kj_zipScaleImage:image Kb:127];
    }else if ([hdImage isKindOfClass:[NSData class]]) {
        UIImage *image = [UIImage imageWithData:hdImage];
        _hdImage = [KJShareView kj_zipScaleImage:image Kb:127];
    }else if ([hdImage isKindOfClass:[UIImage class]]) {
        _hdImage = [KJShareView kj_zipScaleImage:hdImage Kb:127];
    }else{
        //[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"]];
        _hdImage = UIImageJPEGRepresentation(kAppIcon,1.0f);
    }
    NSLog(@"length = %ld",((NSData*)hdImage).length);
}
- (void)setHdWebpageUrl:(NSString *)hdWebpageUrl{
    self.webpageUrl = _hdWebpageUrl = hdWebpageUrl;
}
/// 压缩图片到指定大小
+ (NSData *)kj_zipScaleImage:(UIImage *)image Kb:(NSInteger)kb{
    kb *= 1024;
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > kb && compression > maxCompression) {
        compression -= 0.1;
        // UIImage转换为NSData 第二个参数为压缩倍数
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    return imageData;
}

#pragma mark - 第三方检测
// 检测系统是否安装了QQ,微信,微博
- (BOOL)kPhoneIsInstallWeChat{
    BOOL a = [[UMSocialManager defaultManager] isInstall:(UMSocialPlatformType_WechatSession)];
    BOOL b = [[UMSocialManager defaultManager] isSupport:(UMSocialPlatformType_WechatSession)];
    return a && b;
}
- (BOOL)kPhoneIsInstallQQ{
    BOOL a = [[UMSocialManager defaultManager] isInstall:(UMSocialPlatformType_QQ)];
    BOOL b = [[UMSocialManager defaultManager] isSupport:(UMSocialPlatformType_QQ)];
    return a && b;
}
- (BOOL)kPhoneIsInstallSina{
    BOOL a = [[UMSocialManager defaultManager] isInstall:(UMSocialPlatformType_Sina)];
    BOOL b = [[UMSocialManager defaultManager] isSupport:(UMSocialPlatformType_Sina)];
    return a && b;
}

#pragma mark - 第三方登录
+ (void)kj_ThirdPartyLogin:(UMSocialPlatformType)platformName vc:(UIViewController *)vc completion:(void(^)(id result,NSError *error))completion{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformName currentViewController:nil completion:^(id result, NSError *error) {
        !completion?:completion(result,error);
        //        if (error) {
        //            failed(error);
        //        } else {
        //            success(result);
        //            UMSocialUserInfoResponse *resp = result;
        //            // 授权信息
        //            NSLog(@"Wechat uid: %@", resp.uid);
        //            NSLog(@"Wechat openid: %@", resp.openid);
        //            NSLog(@"Wechat accessToken: %@", resp.accessToken);
        //            NSLog(@"Wechat refreshToken: %@", resp.refreshToken);
        //            NSLog(@"Wechat expiration: %@", resp.expiration);
        //            // 用户信息
        //            NSLog(@"Wechat name: %@", resp.name);
        //            NSLog(@"Wechat iconurl: %@", resp.iconurl);
        //            NSLog(@"Wechat gender: %@", resp.gender);
        //            // 第三方平台SDK源数据
        //            NSLog(@"Wechat originalResponse: %@", resp.originalResponse);
        //            NSString *uid = resp.openid ? resp.openid : resp.uid;
        //            if (!uid) {
        //                failed(error);
        //            }else {
        ////                NSDictionary* dict = @{@"auth_access_token":resp.accessToken, @"open_id":uid};
        //                //成功回调
        //                success(result);
        //            }
        //        }
    }];
}


@end

