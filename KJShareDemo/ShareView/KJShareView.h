//
//  KJShareView.h
//  MoLiao
//
//  Created by 杨科军 on 2018/8/9.
//  Copyright © 2018年 杨科军. All rights reserved.
//  分享界面

/**< 第三方登录与分享 */
/**< 添加类库：
 1.在other linker flags增加-ObjC,-all_load 选项，并添加ImageIO.framework（实现新浪微博必须完成的步骤）
 2.其它类库，动态库后缀可能不同
 Security.framework
 libiconv.dylib
 SystemConfiguration.framework
 CoreGraphics.Framework
 libsqlite3.dylib
 CoreTelephony.framework
 libstdc++.dylib
 libz.dylib
 */

/**<
 iOS9 要在info.plist添加白名单 http://dev.umeng.com/social/ios/ios9#2
 2. 应用跳转
 URL Schemes
 info.plist -> URL Types
 微信：wx + 微信appSecret
 腾讯：tencent + 腾讯appKey,  QQ + 腾讯appKey的十六进制(不够8位，前面补0)
 新浪：wb + 新浪appKey,  sina. + 新浪appSecret
 */

/************************************* 重要事项 *************************************/
/**需要在Appdelegate添加如下代码:
 #pragma mark - 友盟相关
 // 支持所有iOS系统
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
 BOOL result = [[KJShareView kj_UMSocialManger] handleOpenURL:url];
 if (!result) {
 // 其他如支付等SDK的回调
 }
 return result;
 }
 - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
 BOOL result = [[KJShareView kj_UMSocialManger] handleOpenURL:url];
 if (!result) {
 // 其他如支付等SDK的回调
 }
 return result;
 }
 */

#import <UIKit/UIKit.h>
#import <UMSocialCore/UMSocialCore.h>

#pragma mark ********** 第三方 ************/
/// 友盟
#define UMengAppKey   @""
/// 微信
#define WXPayAPPID    @""
#define WXAPPSERCET   @""
/// 微博
#define WBAPPKEY      @""
#define WBAPPSERCET   @""
#define REDIRECTURL   @"http://sns.whalecloud.com/sina2/opencallback"
/// QQ
#define QQAPPKEY      @""
#define QQAPPSERCET   @""
/// QQ分享之后的回调地址
#define SHAREURL      @"http://mobile.umeng.com/social"

/// 分享消息类型
typedef NS_ENUM(NSInteger, KJShareViewContentType) {
    KJShareViewContentTypeText = 0, /// 文本消息
    KJShareViewContentTypeImage,    /// 图片消息
    KJShareViewContentTypeVideo,    /// 视频消息
    KJShareViewContentTypeMusic,    /// 音乐消息
    KJShareViewContentTypeWebpage,  /// 网页消息
    KJShareViewContentTypeMiniProgram,/// 微信小程序
};

/// 分享平台
typedef NS_ENUM(NSInteger, KJShareViewPlatformType) {
    KJShareViewPlatformTypeWeChatSession = 0, /// 微信聊天
    KJShareViewPlatformTypeWechatTimeLine,/// 朋友圈
    KJShareViewPlatformTypeSina, /// 新浪微博
    KJShareViewPlatformTypeQQ,    /// QQ好友
    KJShareViewPlatformTypeQzone, /// QQ空间
};
/// 分享回调
typedef void(^KJShareCompleteBlock)(id data, NSError *error);
@interface KJShareView : UIView

#pragma mark - 友盟第三方
+ (UMSocialManager*)kj_UMSocialManger;
// 初始化
+ (instancetype)createShareView:(void(^)(KJShareView *obj))block;
// 保存父视图控制器
@property(nonatomic,weak,readonly) KJShareView *(^VC)(UIViewController*);

/** 分享平台 默认QQ好友，微信聊天，微信朋友圈 */
@property (nonatomic, strong) NSArray *platformTemps;
/** 分享消息体 */
@property (nonatomic, strong) UMSocialMessageObject *messageObject;
/// 分享之后的回调
@property (nonatomic, strong) KJShareCompleteBlock kj_completeBlock;

/** 分享消息 type：消息类型  block：分享回调 */
- (void)shareWithContentType:(KJShareViewContentType)type CompleteBlock:(KJShareCompleteBlock)block;

#pragma mark - 分享的基本参数
/** 标题 标题的长度依各个平台的要求而定 */
@property (nonatomic, copy) NSString *title;
/** 描述内容的长度依各个平台的要求而定 */
@property (nonatomic, copy) NSString *descr;
/** 缩略图 UIImage或者NSData类型或者NSString类型（图片url）*/
@property (nonatomic, strong) id thumbImage;

#pragma mark - 分享图片
/** 图片内容 （可以是UIImage类对象，也可以是NSdata类对象，也可以是图片链接imageUrl NSString类对象）
 * @note 图片大小根据各个平台限制而定
 */
@property (nonatomic, retain) id shareImage;

#pragma mark - 分享音乐
/** 音乐网页的url地址 长度不能超过10K */
@property (nonatomic, retain) NSString *musicUrl;
/** 音乐lowband网页的url地址 长度不能超过10K */
@property (nonatomic, retain) NSString *musicLowBandUrl;
/** 音乐数据url地址 长度不能超过10K */
@property (nonatomic, retain) NSString *musicDataUrl;
/**音乐lowband数据url地址 长度不能超过10K */
@property (nonatomic, retain) NSString *musicLowBandDataUrl;

#pragma mark - 分享视频
/** 视频网页的url 不能为空且长度不能超过255 */
@property (nonatomic, strong) NSString *videoUrl;
/** 视频lowband网页的url 长度不能超过255 */
@property (nonatomic, strong) NSString *videoLowBandUrl;
/** 视频数据流url 长度不能超过255 */
@property (nonatomic, strong) NSString *videoStreamUrl;
/** 视频lowband数据流url 长度不能超过255 */
@property (nonatomic, strong) NSString *videoLowBandStreamUrl;

#pragma mark - 分享Web
/** 网页的url地址 不能为空且长度不能超过10K */
@property (nonatomic, retain) NSString *webpageUrl;

#pragma mark - 小程序相关参数
/** 低版本微信网页链接 */
@property (nonatomic, strong) NSString *hdWebpageUrl;
/** 小程序username */
@property (nonatomic, strong) NSString *userName;
/** 小程序页面的路径 */
@property (nonatomic, strong) NSString *path;
/** 小程序新版本的预览图 128k */
@property (nonatomic, strong) NSData *hdImageData;
/** 是否使用带 shareTicket 的转发 */
@property (nonatomic, assign) BOOL withShareTicket;


#pragma mark - ThirdTools
/// 三方检测，查看手机是否安装以下应用
- (BOOL)kPhoneIsInstallWeChat; /// 微信
- (BOOL)kPhoneIsInstallQQ;  /// QQ
- (BOOL)kPhoneIsInstallSina;/// 微博

// 登录
+ (void)kj_ThirdPartyLogin:(UMSocialPlatformType)platformName vc:(UIViewController *)vc completion:(void(^)(id result,NSError *error))completion;

@end

