//
//  ZNKPlayer.m
//  IJKPlayerDemo
//
//  Created by HuangSam on 2017/1/11.
//  Copyright © 2017年 qx_mjn. All rights reserved.
//

#import "ZNKPlayer.h"
#import <QuartzCore/QuartzCore.h>
#import "ZNKMasonry.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <AVFoundation/AVFoundation.h>

// 监听TableView的contentOffset
#define kZNKPlayerViewContentOffset          @"contentOffset"

#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
// 监听TableView的contentOffset
#define kZNKPlayerViewContentOffset          @"contentOffset"
// player的单例
#define ZNKPlayerShared                      [ZNKBrightnessView sharedBrightnessView]
// 屏幕的宽
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
// 屏幕的高
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
// 颜色值RGB
#define RGBA(r,g,b,a)                       [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
// 图片路径
#define ZNKPlayerSrcName(file)               [@"ZNKPlayer.bundle" stringByAppendingPathComponent:file]

#define ZNKPlayerFrameworkSrcName(file)      [@"Frameworks/ZNKPlayer.framework/ZNKPlayer.bundle" stringByAppendingPathComponent:file]

#define ZNKPlayerImage(file)                 [UIImage imageNamed:ZNKPlayerSrcName(file)] ? :[UIImage imageNamed:ZNKPlayerFrameworkSrcName(file)]

//弱引用 强引用
#define SKWeakSelf(type) __weak typeof(type) weak##type = type;
#define SKStrongSelf(type) __strong typeof(type) type = weak##type;

static const CGFloat ZNKPlayerAnimationTimeInterval             = 7.0f;
// 枚举值，包含水平移动方向和垂直移动方向


static const CGFloat ZNKPlayerControlBarAutoFadeOutTimeInterval = 0.35f;
@interface ZNKPlayer ()
/** 播放器 */
@property(atomic, retain) id<IJKMediaPlayback> player;
/** 控制层View */
@property (nonatomic, strong) ZNKPlayerControlView    *controlView;

@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;
/** 视频采集 */
@property (nonatomic, strong) AVURLAsset             *urlAsset;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
/** 进入后台*/
@property (nonatomic, assign) BOOL                   didEnterBackground;
/** 播放完了*/
@property (nonatomic, assign) BOOL                   playDidEnd;
/** 是否自动播放 */
@property (nonatomic, assign) BOOL                   isAutoPlay;
/** 是否被用户暂停 */
@property (nonatomic, assign) BOOL       isPauseByUser;
/** 是否显示controlView*/
@property (nonatomic, assign) BOOL                   isMaskShowing;
/** 是否播放本地文件 */
@property (nonatomic, assign) BOOL                   isLocalVideo;
/** 是否正在拖动进度条 */
@property (nonatomic, assign) BOOL                   isChangeSliderVideo;
//进度变化定时器
@property (nonatomic, strong)NSTimer * timer;
/** slider上次的值 */
@property (nonatomic, assign) CGFloat                sliderLastValue;
/** palyer加到tableView */
@property (nonatomic, strong) UIView            *videoView;
///** 视频采集 */
//@property (nonatomic, assign) AVAsset *videoAsset;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection           panDirection;
/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat                sumTime;
#pragma mark - UITableViewCell PlayerView

/** palyer加到tableView */
@property (nonatomic, strong) UITableView            *tableView;
/** player所在cell的indexPath */
@property (nonatomic, strong) NSIndexPath            *indexPath;
/** cell上imageView的tag */
@property (nonatomic, assign) NSInteger              cellImageViewTag;
/** ViewController中页面是否消失 */
@property (nonatomic, assign) BOOL                   viewDisappear;

/** 是否缩小视频在底部 */
@property (nonatomic, assign) BOOL                   isBottomVideo;
/** 是否在cell上播放video */
@property (nonatomic, assign) BOOL                   isCellVideo;
/** 是否再次设置URL播放视频 */
@property (nonatomic, assign) BOOL                   repeatToPlay;
/** cell中是否是第一次创建 */
@property (nonatomic, assign) BOOL                   isCellFirst;
/** 滑杆 */
@property (nonatomic, strong) UISlider               *volumeViewSlider;
/** 播发器的几种状态 */
@property (nonatomic, assign) ZNKPlayerPlaybackState state;
/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL                   isLocked;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                   isVolume;
/** 是否切换分辨率*/
@property (nonatomic, assign) BOOL                   isChangeResolution;


@end

@interface ZNKPlayerControlView ()
/** 标题 */
@property (nonatomic, strong) UILabel                 *titleLabel;
/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *startBtn;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel                 *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel                 *totalTimeLabel;
/** 缓冲进度条 */
@property (nonatomic, strong) UIProgressView          *progressView;
/** 滑杆 */
@property (nonatomic, strong) ZNKSlider               *videoSlider;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *fullScreenBtn;
/** 锁定屏幕方向按钮 */
@property (nonatomic, strong) UIButton                *lockBtn;
/** 快进快退label */
@property (nonatomic, strong) UILabel                 *horizontalLabel;
/** 系统菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *activity;
/** 返回按钮*/
@property (nonatomic, strong) UIButton                *backBtn;
/** 重播按钮 */
@property (nonatomic, strong) UIButton                *repeatBtn;
/** bottomView*/
@property (nonatomic, strong) UIImageView             *bottomImageView;
/** topView */
@property (nonatomic, strong) UIImageView             *topImageView;
/** 缓存按钮 */
@property (nonatomic, strong) UIButton                *downLoadBtn;
/** 切换分辨率按钮 */
@property (nonatomic, strong) UIButton                *resolutionBtn;
/** 分辨率的View */
@property (nonatomic, strong) UIView                  *resolutionView;
/** 播放按钮 */
@property (nonatomic, strong) UIButton                *playeBtn;

@end

@interface ZNKBrightnessView ()
@property (nonatomic, strong) UIImageView		*backImage;
@property (nonatomic, strong) UILabel			*title;
@property (nonatomic, strong) UIView			*longView;
@property (nonatomic, strong) NSMutableArray	*tipArray;
@property (nonatomic, assign) BOOL				orientationDidChange;
@property (nonatomic, strong) NSTimer			*timer;
@end

@interface ZNKValuePopUpView ()

@end

@interface ZNKSlider () <ZNKValuePoUpViewDelegate>
@property (strong, nonatomic) ZNKValuePopUpView *popUpView;
@property (nonatomic) BOOL popUpViewAlwaysOn; // default is NO
@end



@implementation ZNKPlayer

- (void)dealloc{
    [self teadownPlayer];
//    self.playerItem = nil;
    self.tableView = nil;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedPlayerView {
    
    static ZNKPlayer *player = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        player = [[ZNKPlayer alloc]init];
    });
    
    return player;
}

- (instancetype)init {
    
    if (self = [super init]) {
        //
        //        [self initialAYPlayer];
        
    }
    return self;
}

- (void)initPlayWithURL:(NSURL *)videoURL{
    if ([videoURL.scheme isEqualToString:@"file"]) {
        self.isLocalVideo = YES;
    }else{
        self.isLocalVideo = NO;
    }
    
    
}

- (id)initWithContentURL:(NSURL *)aUrl withOptions:(NSDictionary *)options withSuperView:(UIView *)videoView {
    
    if (self = [super init]) {
        _videoURL = aUrl;
        _options = options;
        self.videoView = videoView;
        
        [self initialAYPlayer];
        [self createTimer];
        [self addNotifications];
        // 添加手势
        [self createGesture];
    }
    return self;
}

#pragma mark - 观察者、通知

///**
// *  添加观察者、通知
// */
//- (void)addNotifications{
//    
//    // app退到后台
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
//    // app进入前台
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
//    // slider开始滑动事件
//    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
//    // slider滑动中事件
//    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//    // slider结束滑动事件
//    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
//    [self.controlView.startBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
//    // 返回按钮点击事件
//    [self.controlView.backBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    // 全屏按钮点击事件
//    [self.controlView.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
//    
//    // 加载完成后，再添加平移手势
//    // 添加平移手势，用来控制音量、亮度、快进快退
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
//    pan.delegate                = self;
//    [self addGestureRecognizer:pan];
//    //    // 重播
//    //    [self.controlView.repeatBtn addTarget:self action:@selector(repeatPlay:) forControlEvents:UIControlEventTouchUpInside];
//}

- (void)initialAYPlayer{
    
    //    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    if ([self.videoURL.scheme isEqualToString:@"file"])
    {
        self.isLocalVideo = YES;
    }else{
        self.isLocalVideo = NO;
    }
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:_videoURL withOptions:options];
    [_player setScalingMode:IJKMPMovieScalingModeAspectFit];
    UIView *playerView = [_player view];
    //    playerView.frame = UIScreen16_9;
    //    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:playerView];
    [playerView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(0);
    }];
    
    [self addSubview:self.controlView];
    [self.controlView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(0);
        //        make.top.leading.trailing.bottom.equalTo(self);
    }];
    
    //    self.isPauseByUser = YES;
    self.isMaskShowing = NO;
    [self installMovieNotificationObservers];
    [self animateShow];
}
- (void)createTimer
{
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(change) userInfo:nil repeats:YES];
    }
    
    //    [self.timer setFireDate:[NSDate distantFuture]];//暂停timer
    //    [self.timer fire];
}
//进度条变化
- (void)change
{
    NSInteger currentTime                      = [self getResultTimeWithTime:self.player.currentPlaybackTime];
    // 当前时长进度progress
    NSInteger proMin                           = currentTime / 60;//当前秒
    NSInteger proSec                           = currentTime % 60;//当前分钟
    CGFloat totalTime                          = [self getResultTimeWithTime:self.player.duration];
    // duration 总时长
    NSInteger durMin                           = (NSInteger)totalTime / 60;//总秒
    NSInteger durSec                           = (NSInteger)totalTime % 60;//总分钟
    
    //slider最大值
    self.controlView.videoSlider.maximumValue = self.player.duration;
    // 更新slider
    self.controlView.videoSlider.value     =  self.player.currentPlaybackTime;
    // 更新当前播放时间
    self.controlView.currentTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    // 更新总时间
    self.controlView.totalTimeLabel.text   = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    //    NSLog(@" -----currentTime =>  %f,   duration => %f, playableDuration => %f",self.player.playbackRate,self.player.duration,self.player.playableDuration);
}

- (NSInteger)getResultTimeWithTime:(CGFloat)time
{
    NSInteger ys = (NSInteger)(time*10)%10;
    return  (ys > 5)?(NSInteger)(time + 1):(NSInteger)(time);
}

/**
 *  重置player
 */
- (void)resetPlayer
{
    // 改为为播放完
    self.playDidEnd         = NO;
    //    self.player         = nil;
    self.didEnterBackground = NO;
    // 视频跳转秒数置0
    self.seekTime           = 0;
    self.isAutoPlay         = NO;
    // 暂停
    [self stop];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    //    [self removeMovieNotificationObservers];
    
    //    [self cancelAutoFadeOutControlBar];
    
    // 移除原来的layer
    [self.player.view removeFromSuperview];
    self.imageGenerator = nil;
    // 把player置为nil
    //    self.player = nil;
    [self teadownPlayer];
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 重置控制层View
//    [self.controlView resetControlView];
    
    if (self.isChangeResolution) { // 切换分辨率
        [self.controlView resetControlViewForResolution];
        self.isChangeResolution = NO;
    }else { // 重置控制层View
        [self.controlView resetControlView];
    }
    // 非重播时，移除当前playerView
    if (!self.repeatToPlay) { [self removeFromSuperview]; }
    // 底部播放video改为NO
    self.isBottomVideo = NO;
    // cell上播放视频 && 不是重播时
    if (self.isCellVideo && !self.repeatToPlay) {
        // vicontroller中页面消失
        self.viewDisappear = YES;
        self.isCellVideo   = NO;
        self.tableView     = nil;
        self.indexPath     = nil;
    }
}


/**
 *  应用退到后台
 */
- (void)appDidEnterBackground
{
    //    self.didEnterBackground = YES;
    [self.player pause];
    [self.timer setFireDate:[NSDate distantFuture]];//暂停timer
    
    //    self.state = ZFPlayerStatePause;
    [self cancelAutoFadeOutControlBar];
    self.controlView.startBtn.selected = NO;
}

/**
 *  应用进入前台
 */
- (void)appDidEnterPlayGround
{
    //    self.didEnterBackground = NO;
    self.isMaskShowing = NO;
    // 延迟隐藏controlView
    [self animateShow];
    if (!self.isPauseByUser) {
        //        self.state                         = ZFPlayerStatePlaying;
        self.controlView.startBtn.selected = YES;
        self.isPauseByUser                 = NO;
        [self play];
    }
}
#pragma mark - 设置视频URL

/**
 *  用于cell上播放player
 *
 *  @param videoURL  视频的URL
 *  @param tableView tableView
 *  @param indexPath indexPath
 */
- (void)setVideoURL:(NSURL *)videoURL
      withTableView:(UITableView *)tableView
        AtIndexPath:(NSIndexPath *)indexPath
   withImageViewTag:(NSInteger)tag
{
    self.isCellFirst = YES;
    // 如果页面没有消失，并且playerItem有值，需要重置player(其实就是点击播放其他视频时候)
    if (!self.viewDisappear && self.player) {self.isCellFirst = NO;
        [self resetPlayer]; }
    // 在cell上播放视频
    self.isCellVideo      = YES;
    // viewDisappear改为NO
    self.viewDisappear    = NO;
    // 设置imageView的tag
    self.cellImageViewTag = tag;
    // 设置tableview
    self.tableView        = tableView;
    // 设置indexPath
    self.indexPath        = indexPath;
    // 设置视频URL
    //    [self setVideoURL:videoURL];
    [self setPlayerWithUrl:videoURL];
    
    [self createTimer];
    
    if (self.isCellFirst == YES) {
        
        [self addNotifications];
        // 添加手势
        [self createGesture];
    }
}

#pragma mark - 设置视频URL

- (void)setPlayerWithUrl:(NSURL *)url
{
    _videoURL = url;
    //    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    if ([self.videoURL.scheme isEqualToString:@"file"])
    {
        self.isLocalVideo = YES;
    }else{
        self.isLocalVideo = NO;
    }
    self.backgroundColor = [UIColor redColor];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    [_player setScalingMode:IJKMPMovieScalingModeAspectFit];
    UIView *playerView = [_player view];
    playerView.backgroundColor = [UIColor blueColor];
    //    playerView.frame = UIScreen16_9;
    //    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.isCellFirst == YES)
    {
        [self addSubview:playerView];
    }else{
        [self insertSubview:playerView belowSubview:self.controlView];
    }
    [playerView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(0);
    }];
    if (self.isCellFirst == YES) {
        [self addSubview:self.controlView];
    }
    
    [self.controlView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(0);
        //        make.top.leading.trailing.bottom.equalTo(self);
    }];
    
    //    self.isPauseByUser = YES;
    self.isMaskShowing = NO;
    [self installMovieNotificationObservers];
    [self animateShow];
}
#pragma mark - slider事件

/**
 *  slider开始滑动事件
 *
 *  @param slider UISlider
 */
- (void)progressSliderTouchBegan:(ZNKSlider *)slider
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/**
 *  slider开始滑动事件
 *
 *  @param slider UISlider
 */
//- (void)progressSliderTouchBegan:(ASValueTrackingSlider *)slider
//{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//}

/**
 *  slider滑动中事件
 *
 *  @param slider UISlider
 */
//- (void)progressSliderValueChanged:(ASValueTrackingSlider *)slider
//{
//    //拖动改变视频播放进度
//    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
//        NSString *style = @"";
//        CGFloat value   = slider.value - self.sliderLastValue;
//        if (value > 0) { style = @">>"; }
//        if (value < 0) { style = @"<<"; }
//        if (value == 0) { return; }
//        
//        self.sliderLastValue    = slider.value;
//        // 暂停
//        [self pause];
//        
//        CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
//        
//        //计算出拖动的当前秒数
//        NSInteger dragedSeconds = floorf(total * slider.value);
//        
//        //转换成CMTime才能给player来控制播放进度
//        
//        CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
//        // 拖拽的时长
//        NSInteger proMin        = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
//        NSInteger proSec        = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
//        
//        //duration 总时长
//        NSInteger durMin        = (NSInteger)total / 60;//总秒
//        NSInteger durSec        = (NSInteger)total % 60;//总分钟
//        
//        NSString *currentTime   = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
//        NSString *totalTime     = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
//        
//        if (total > 0) { // 当总时长 > 0时候才能拖动slider
//            self.controlView.videoSlider.popUpView.hidden = !self.isFullScreen;
//            self.controlView.currentTimeLabel.text  = currentTime;
//            if (self.isFullScreen) {
//                [self.controlView.videoSlider setText:currentTime];
//                dispatch_queue_t queue = dispatch_queue_create("com.playerPic.queue", DISPATCH_QUEUE_CONCURRENT);
//                dispatch_async(queue, ^{
//                    NSError *error;
//                    CMTime actualTime;
//                    CGImageRef cgImage = [self.imageGenerator copyCGImageAtTime:dragedCMTime actualTime:&actualTime error:&error];
//                    CMTimeShow(actualTime);
//                    UIImage *image = [UIImage imageWithCGImage:cgImage];
//                    CGImageRelease(cgImage);
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.controlView.videoSlider setImage:image ? : ZNKPlayerImage(@"ZFPlayer_loading_bgView")];
//                    });
//                });
//                
//            } else {
//                self.controlView.horizontalLabel.hidden = NO;
//                self.controlView.horizontalLabel.text   = [NSString stringWithFormat:@"%@ %@ / %@",style, currentTime, totalTime];
//            }
//        }else {
//            // 此时设置slider值为0
//            slider.value = 0;
//        }
//        
//    }else { // player状态加载失败
//        // 此时设置slider值为0
//        slider.value = 0;
//    }
//}

/**
 *  slider滑动中事件
 *
 *  @param slider UISlider
 */
- (void)progressSliderValueChanged:(ZNKSlider *)slider
{
    
    NSString *style = @"";
    CGFloat value   = slider.value - self.player.currentPlaybackTime;
    if (value > 0) { style = @">>"; }
    if (value < 0) { style = @"<<"; }
    if (value == 0) { return; }
    // duration
    NSTimeInterval duration = self.player.duration;
    NSInteger intDuration = duration + 0.0;
    if (intDuration > 0) {
        self.controlView.videoSlider.maximumValue = duration;
        
    } else {
        self.controlView.totalTimeLabel.text = @"--:--";
        self.controlView.videoSlider.maximumValue = 1.0f;
        return;
    }
    // 暂停
    [self pause];
    NSTimeInterval position;
    position = self.controlView.videoSlider.value;
    NSInteger intPosition = position + 0.0;
    
    NSString *currentTime = [NSString stringWithFormat:@"%02d:%02d", (int)(intPosition / 60), (int)(intPosition % 60)];
    self.controlView.currentTimeLabel.text = currentTime;
    CMTime dragedCMTime     = CMTimeMake(self.controlView.videoSlider.value, 1);
    self.controlView.videoSlider.popUpView.hidden = !self.isFullScreen;
    
    if (self.isFullScreen)
    {
        [self.controlView.videoSlider setText:currentTime];
        dispatch_queue_t queue = dispatch_queue_create("com.playerPic.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            NSError *error;
            CMTime actualTime;
            CGImageRef cgImage = [self.imageGenerator copyCGImageAtTime:dragedCMTime actualTime:&actualTime error:&error];
            CMTimeShow(actualTime);
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            CGImageRelease(cgImage);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView.videoSlider setImage:image ? : ZNKPlayerImage(@"ZFPlayer_loading_bgView")];
            });
        });
    }else{
        self.controlView.horizontalLabel.hidden = NO;
        self.controlView.horizontalLabel.text   = [NSString stringWithFormat:@"%@ %@ / %@",style, currentTime, [self durationStringWithTime:duration]];
        
    }
    
    
    //    //拖动改变视频播放进度
    //    if (self.player.loadState == !IJKMPMovieLoadStateUnknown) {
    //        self.isChangeSliderVideo = YES;
    //        NSString *style = @"";
    //        CGFloat value   = slider.value - self.sliderLastValue;
    //        if (value > 0) { style = @">>"; }
    //        if (value < 0) { style = @"<<"; }
    //        if (value == 0) { return; }
    //
    //        self.sliderLastValue    = slider.value;
    //        // 暂停
    //        [self pause];
    //
    //        CGFloat total           = self.player.duration;
    //
    //        //计算出拖动的当前秒数
    //        NSInteger dragedSeconds = floorf(total * slider.value);
    //
    //        //转换成CMTime才能给player来控制播放进度
    //
    //        CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    //        // 拖拽的时长
    //        NSInteger proMin        = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
    //        NSInteger proSec        = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
    //
    //        //duration 总时长
    //        NSInteger durMin        = (NSInteger)total / 60;//总秒
    //        NSInteger durSec        = (NSInteger)total % 60;//总分钟
    //
    //        NSString *currentTime   = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    //        NSString *totalTime     = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    //        NSLog(@"total === %f",total);
    //        if (total > 0) { // 当总时长 > 0时候才能拖动slider
    ////            self.controlView.videoSlider.popUpView.hidden = !self.isFullScreen;
    //            self.controlView.currentTimeLabel.text  = currentTime;
    //            if (self.isFullScreen) {
    //                [self.controlView.videoSlider setText:currentTime];
    //                dispatch_queue_t queue = dispatch_queue_create("com.playerPic.queue", DISPATCH_QUEUE_CONCURRENT);
    //                dispatch_async(queue, ^{
    //                    NSError *error;
    //                    CMTime actualTime;
    //                    CGImageRef cgImage = [self.imageGenerator copyCGImageAtTime:dragedCMTime actualTime:&actualTime error:&error];
    //                    CMTimeShow(actualTime);
    //                    UIImage *image = [UIImage imageWithCGImage:cgImage];
    //                    CGImageRelease(cgImage);
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        //                        [self.controlView.videoSlider setImage:image ? : ZNKPlayerImage(@"ZFPlayer_loading_bgView")];
    //                        [self.controlView.videoSlider setImage:image ? : AYPlayerImageFile(@"defaultmovie_")];
    //                    });
    //                });
    //
    //            } else {
    ////                self.controlView.horizontalLabel.hidden = NO;
    ////                self.controlView.horizontalLabel.text   = [NSString stringWithFormat:@"%@ %@ / %@",style, currentTime, totalTime];
    //            }
    //        }else {
    //            // 此时设置slider值为0
    //            slider.value = 0;
    //        }
    //
    //    }else { // player状态加载失败
    //        // 此时设置slider值为0
    //        slider.value = 0;
    //    }
}

/**
 *  slider结束滑动事件
 *
 *  @param slider UISlider
 */
- (void)progressSliderTouchEnded:(ZNKSlider *)slider
{
    //    if (self.player.loadState == !IJKMPMovieLoadStateUnknown) {
    
    NSTimeInterval duration = self.player.duration;
    NSInteger intDuration = duration + 0.0;
    if (intDuration > 0) {
        self.isChangeSliderVideo = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.controlView.horizontalLabel.hidden = YES;
        });
        
        
        // 结束滑动时候把开始播放按钮改为播放状态
        self.controlView.startBtn.selected = YES;
        self.isPauseByUser                 = NO;
        
        // 滑动结束延时隐藏controlView
        [self autoFadeOutControlBar];
        // 视频总时间长度
        //        CGFloat total           =  self.player.duration;
        
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = self.isLocalVideo?slider.value : MIN(slider.value, self.player.playableDuration);
        self.player.currentPlaybackTime = dragedSeconds;
        [self play];
        
    }
    //    }
}

/**
 *  slider结束滑动事件
 *
 *  @param slider UISlider
 */
//- (void)progressSliderTouchEnded:(ASValueTrackingSlider *)slider
//{
//    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.controlView.horizontalLabel.hidden = YES;
//        });
//        // 结束滑动时候把开始播放按钮改为播放状态
//        self.controlView.startBtn.selected = YES;
//        self.isPauseByUser                 = NO;
//        
//        // 滑动结束延时隐藏controlView
//        [self autoFadeOutControlBar];
//        // 视频总时间长度
//        CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
//        
//        //计算出拖动的当前秒数
//        NSInteger dragedSeconds = floorf(total * slider.value);
//        
//        [self seekToTime:dragedSeconds completionHandler:nil];
//    }
//}

- (void)startAction:(UIButton *)button
{
    button.selected    = !button.selected;
    self.isPauseByUser = !self.isPauseByUser;
    if (!button.selected) {
        [self play];
    } else {
        [self pause];
    }
}

/**
 *  播放、暂停按钮事件
 *
 *  @param button UIButton
 */
//- (void)startAction:(UIButton *)button
//{
//    button.selected    = !button.selected;
//    self.isPauseByUser = !self.isPauseByUser;
//    if (button.selected) {
//        [self play];
//        if (self.state == ZFPlayerStatePause) { self.state = ZFPlayerStatePlaying; }
//    } else {
//        [self pause];
//        if (self.state == ZFPlayerStatePlaying) { self.state = ZFPlayerStatePause;}
//    }
//}

- (void)prepareToPlay {
    if (self.player) {
        [self.player prepareToPlay];
        //        [self.timer setFireDate:[NSDate distantPast]];//启动timer
    }
}

- (void)autoToplay {
    if (self.player) {
        self.player.shouldAutoplay = YES;
        [self.timer setFireDate:[NSDate distantPast]];//启动timer
    }
}

- (void)play {
    if (![self.player isPlaying]) {
        self.isPauseByUser = NO;
        self.controlView.startBtn.selected = NO;
        [self.player play];
        [self.timer setFireDate:[NSDate distantPast]];//启动timer
    }
}

/**
 *  播放
 */
//- (void)play
//{
//    self.controlView.startBtn.selected = YES;
//    self.isPauseByUser = NO;
//    [_player play];
//}

-(void)pause {
    if ([self.player isPlaying]) {
        
        self.isPauseByUser = YES;
        self.controlView.startBtn.selected = YES;
        [self.player pause];
        [self.timer setFireDate:[NSDate distantFuture]];//暂停timer
    }
}

///**
// * 暂停
// */
//- (void)pause
//{
//    self.controlView.startBtn.selected = NO;
//    self.isPauseByUser = YES;
//    [_player pause];
//}

-(void)stop {
    
    if (self.player) {
        [self.player stop];
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(BOOL)isPlaying {
    return [self.player isPlaying];
}

- (void)setPauseInBackground:(BOOL)pause {
    [self.player setPauseInBackground:pause];
}

/**
 *  创建手势
 */
- (void)createGesture
{
    // 单击
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    self.tap.delegate = self;
    [self addGestureRecognizer:self.tap];
    
    // 双击(播放/暂停)
    self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    [self.doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:self.doubleTap];
    
    // 解决点击当前view时候响应其他控件事件
    self.tap.delaysTouchesBegan = YES;
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
}


#pragma mark - Action

//- (void)tapAction:(UITapGestureRecognizer *)gesture
//{
//    if (gesture.state == UIGestureRecognizerStateRecognized) {
//        //        [self startAction:self.controlView.startBtn];
//        
//        self.isMaskShowing ? ([self hideControlView]) : ([self animateShow]);
//    }
//}

/**
 *   轻拍方法
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBottomVideo && !self.isFullScreen) {
            [self fullScreenAction:self.controlView.fullScreenBtn];
            return;
        }
        self.isMaskShowing ? ([self hideControlView]) : ([self animateShow]);
    }
}

/**
 *  双击播放/暂停
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)doubleTapAction:(UITapGestureRecognizer *)gesture
{
    // 显示控制层
    [self animateShow];
    [self startAction:self.controlView.startBtn];
}

/**
 *  双击播放/暂停
 *
 *  @param gesture UITapGestureRecognizer
 */
//- (void)doubleTapAction:(UITapGestureRecognizer *)gesture
//{
//    // 显示控制层
//    [self animateShow];
//    [self startAction:self.controlView.startBtn];
//}

#pragma mark - UIPanGestureRecognizer手势方法

/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 取消隐藏
                self.controlView.horizontalLabel.hidden = NO;
                self.panDirection = PanDirectionHorizontalMoved;
                //                // 给sumTime初值
                //                CMTime time       = self.player.currentTime;
                self.sumTime      = self.player.currentPlaybackTime;
                
                // 暂停视频播放
                [self pause];
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                //                if (locationPoint.x > self.bounds.size.width / 2) {
                //                    self.isVolume = YES;
                //                }else { // 状态改为显示亮度调节
                //                    self.isVolume = NO;
                //                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    // 移动中一直显示快进label
                    //                    self.controlView.horizontalLabel.hidden = NO;
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    //                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    
                    // 继续播放
                    [self play];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        // 隐藏视图
                        self.controlView.horizontalLabel.hidden = YES;
                    });
                    // 快进、快退时候把开始播放按钮改为播放状态
                    self.controlView.startBtn.selected = YES;
                    self.isPauseByUser                 = NO;
                    self.player.currentPlaybackTime = self.sumTime;
                    //                    [self seekToTime:self.sumTime completionHandler:nil];
                    //                    // 把sumTime滞空，不然会越加越多
                    //                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    //                    self.isVolume = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.controlView.horizontalLabel.hidden = YES;
                    });
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value
{
    // 快进快退的方法
    NSString *style = @"";
    if (value < 0) { style = @"<<"; }
    if (value > 0) { style = @">>"; }
    if (value == 0) { return; }
    
    
    
    // 需要限定sumTime的范围
    //    CMTime totalTime           = self.player.duration;
    CGFloat totalMovieDuration = self.player.duration;
    // 每次滑动需要叠加时间
    self.sumTime += 3 * value / self.frame.size.width / totalMovieDuration;
    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    
    // 当前快进的时间
    NSString *nowTime         = [self durationStringWithTime:(int)self.sumTime];
    // 总时间
    NSString *durationTime    = [self durationStringWithTime:(int)totalMovieDuration];
    
    // 更新快进label的时长
    self.controlView.horizontalLabel .text  = [NSString stringWithFormat:@"%@ %@ / %@",style, nowTime, durationTime];
    // 更新slider的进度
    self.controlView.videoSlider.value     = self.sumTime;
    // 更新现在播放的时间
    self.controlView.currentTimeLabel.text = nowTime;
}
/**
 *  根据时长求出字符串
 *
 *  @param time 时长
 *
 *  @return 时长字符串
 */
- (NSString *)durationStringWithTime:(int)time
{
    // 获取分钟
    NSString *min = [NSString stringWithFormat:@"%02d",time / 60];
    // 获取秒数
    NSString *sec = [NSString stringWithFormat:@"%02d",time % 60];
    return [NSString stringWithFormat:@"%@:%@", min, sec];
}

/**
 *  根据时长求出字符串
 *
 *  @param time 时长
 *
 *  @return 时长字符串
 */
//- (NSString *)durationStringWithTime:(int)time
//{
//    // 获取分钟
//    NSString *min = [NSString stringWithFormat:@"%02d",time / 60];
//    // 获取秒数
//    NSString *sec = [NSString stringWithFormat:@"%02d",time % 60];
//    return [NSString stringWithFormat:@"%@:%@", min, sec];
//}

#pragma mark - UIGestureRecognizerDelegate

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        CGPoint point = [touch locationInView:self.controlView];
//        // （屏幕下方slider区域） || （在cell上播放视频 && 不是全屏状态） || (播放完了) =====>  不响应pan手势
//        if ((point.y > self.bounds.size.height-40) || (self.isCellVideo && !self.isFullScreen) || self.playDidEnd) { return NO; }
//        return YES;
//    }
//    // 在cell上播放视频 && 不是全屏状态 && 点在控制层上
//    if (self.isBottomVideo && !self.isFullScreen && touch.view == self.controlView) {
//        [self fullScreenAction:self.controlView.fullScreenBtn];
//        return NO;
//    }
//    if (self.isBottomVideo && !self.isFullScreen && touch.view == self.controlView.backBtn) {
//        // 关闭player
//        [self resetPlayer];
//        [self removeFromSuperview];
//        return NO;
//    }
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint point = [touch locationInView:self.controlView];
        // （屏幕下方slider区域） || （在cell上播放视频 && 不是全屏状态） || (播放完了) =====>  不响应pan手势
        if ((point.y > self.bounds.size.height-40) || (self.isCellVideo && !self.isFullScreen) || self.playDidEnd) { return NO; }
        return YES;
    }
    // 在cell上播放视频 && 不是全屏状态 && 点在控制层上
    if (self.isBottomVideo && !self.isFullScreen && touch.view == self.controlView) {
        [self fullScreenAction:self.controlView.fullScreenBtn];
        return NO;
    }
    if (self.isBottomVideo && !self.isFullScreen && touch.view == self.controlView.backBtn) {
        // 关闭player
        //        [self resetPlayer];
        [self removeFromSuperview];
        return NO;
    }
    return YES;
}
#pragma mark - ShowOrHideControlView


/**
 *  取消延时隐藏controlView的方法
 */
- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/**
 *  隐藏控制层
 */
- (void)hideControlView
{
    if (!self.isMaskShowing) { return; }
    [UIView animateWithDuration:ZNKPlayerControlBarAutoFadeOutTimeInterval animations:^{
        [self.controlView hideControlView];
        if (self.isFullScreen) { //全屏状态
            self.controlView.backBtn.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }else if (self.isBottomVideo && !self.isFullScreen) { // 视频在底部bottom小屏,并且不是全屏状态
            self.controlView.backBtn.alpha = 1;
        }else {
            self.controlView.backBtn.alpha = 0;
        }
    }completion:^(BOOL finished) {
        self.isMaskShowing = NO;
    }];
}

/**
 *  显示控制层
 */
- (void)animateShow
{
    if (self.isMaskShowing) { return; }
    [UIView animateWithDuration:ZNKPlayerControlBarAutoFadeOutTimeInterval animations:^{
        self.controlView.backBtn.alpha = 1;
        if (self.isBottomVideo && !self.isFullScreen) { [self.controlView hideControlView]; } // 视频在底部bottom小屏,并且不是全屏状态
        else if (self.playDidEnd) { [self.controlView hideControlView]; } // 播放完了
        else { [self.controlView showControlView]; }
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        self.isMaskShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

/**
 *  返回按钮事件
 */
- (void)backButtonAction
{
    if (self.isLocked) {
        [self unLockTheScreen];
        return;
    }else {
        if (!self.isFullScreen) {
            // 在cell上播放视频
            if (self.isCellVideo) {
                // 关闭player
                [self resetPlayer];
                [self removeFromSuperview];
                return;
            }
            // player加到控制器上，只有一个player时候
            [self pause];
            self.player = nil;
            //            self.playerLayer = nil;
            if (self.goBackBlock) {
                self.goBackBlock();
            }
        }else {
            //if (self.isGoBackFull) {
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
            
            //            }else {
            //                // player加到控制器上，只有一个player时候
            //                [self pause];
            //                self.player = nil;
            //                self.playerLayer = nil;
            //                if (self.goBackBlock) {
            //                    self.goBackBlock();
            //                }
            //
            //
            //            }
        }
    }
    if (self.isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self toSmallScreen];
        if (self.goBackBlock) {
            self.goBackBlock();
        }
    }else {
        
    }
    
}

///**
// *  返回按钮事件
// */
//- (void)backButtonAction
//{
//    if (self.isLocked) {
//        [self unLockTheScreen];
//        return;
//    }else {
//        if (!self.isFullScreen) {
//            // 在cell上播放视频
//            if (self.isCellVideo) {
//                // 关闭player
//                [self resetPlayer];
//                [self removeFromSuperview];
//                return;
//            }
//            // player加到控制器上，只有一个player时候
//            [self pause];
//            self.player = nil;
//            //            self.playerLayer = nil;
//            if (self.goBackBlock) {
//                self.goBackBlock();
//            }
//        }else {
//            //if (self.isGoBackFull) {
//            [self interfaceOrientation:UIInterfaceOrientationPortrait];
//            
//            //            }else {
//            //                // player加到控制器上，只有一个player时候
//            //                [self pause];
//            //                self.player = nil;
//            //                self.playerLayer = nil;
//            //                if (self.goBackBlock) {
//            //                    self.goBackBlock();
//            //                }
//            //
//            //
//            //            }
//        }
//    }
//}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.tableView) {
        if ([keyPath isEqualToString:kZNKPlayerViewContentOffset]) {
            if (([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait)) { return; }
            // 当tableview滚动时处理playerView的位置
            [self handleScrollOffsetWithDict:change];
        }
    }
}



#pragma mark - tableViewContentOffset

/**
 *  KVO TableViewContentOffset
 *
 *  @param dict void
 */
- (void)handleScrollOffsetWithDict:(NSDictionary*)dict
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    NSArray *visableCells = self.tableView.visibleCells;
    
    if ([visableCells containsObject:cell]) {
        //在显示中
        //        [self updatePlayerViewToCell];
    }else {
        //在底部
        //        [self updatePlayerViewToBottom];
        [self pause];
    }
}

/**
 *  缩小到底部，显示小视频
 */
- (void)updatePlayerViewToBottom
{
    if (self.isBottomVideo) { return ; }
    self.isBottomVideo = YES;
    if (self.playDidEnd) { //如果播放完了，滑动到小屏bottom位置时，直接resetPlayer
        self.repeatToPlay = NO;
        self.playDidEnd   = NO;
        [self resetPlayer];
        return;
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    // 解决4s，屏幕宽高比不是16：9的问题
    if (iPhone4s) {
        [self ZNKMAs_remakeConstraints:^(ZNKMASConstraintMaker *make) {
            CGFloat width = ScreenWidth*0.5-20;
            make.width.ZNKMAs_equalTo(width);
            make.trailing.ZNKMAs_equalTo(-10);
            make.bottom.ZNKMAs_equalTo(-self.tableView.contentInset.bottom-10);
            make.height.ZNKMAs_equalTo(width*320/480).with.priority(750);
        }];
    }else {
        [self ZNKMAs_remakeConstraints:^(ZNKMASConstraintMaker *make) {
            CGFloat width = ScreenWidth*0.5-20;
            make.width.ZNKMAs_equalTo(width);
            make.trailing.ZNKMAs_equalTo(-10);
            make.bottom.ZNKMAs_equalTo(-self.tableView.contentInset.bottom-10);
            make.height.equalTo(self.ZNKMAs_width).multipliedBy(9.0f/16.0f).with.priority(750);
        }];
    }
    // 不显示控制层
    [self.controlView hideControlView];
}

/**
 *  player添加到cellImageView上
 *
 *  @param imageView 添加player的cellImageView
 */
- (void)addPlayerToCellImageView:(UIImageView *)imageView
{
    [imageView addSubview:self];
    [self ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(imageView);
    }];
}
/**
 *  回到cell显示
 */
- (void)updatePlayerViewToCell
{
    if (!self.isBottomVideo) { return; }
    self.isBottomVideo     = NO;
    // 显示控制层
    self.controlView.alpha = 1;
    [self setOrientationPortrait];
    
    [self.controlView showControlView];
}

/**
 *  设置横屏的约束
 */
- (void)setOrientationLandscape
{
    if (self.isCellVideo) {
        
        // 横屏时候移除tableView的观察者
        [self.tableView removeObserver:self forKeyPath:kZNKPlayerViewContentOffset];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        // 亮度view加到window最上层
        ZNKBrightnessView *brightnessView = [ZNKBrightnessView sharedBrightnessView];
        [[UIApplication sharedApplication].keyWindow insertSubview:self belowSubview:brightnessView];
        [self ZNKMAs_remakeConstraints:^(ZNKMASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
}


/**
 *  设置竖屏的约束
 */
- (void)setOrientationPortrait
{
    if (self.isCellVideo) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self removeFromSuperview];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
        NSArray *visableCells = self.tableView.visibleCells;
        self.isBottomVideo = NO;
        if (![visableCells containsObject:cell]) {
            //[self updatePlayerViewToBottom];
        }else {
            // 根据tag取到对应的cellImageView
            UIImageView *cellImageView = [cell viewWithTag:self.cellImageViewTag];
            [self addPlayerToCellImageView:cellImageView];
        }
    }
}

#pragma mark 屏幕转屏相关


/**
 *  全屏按钮事件
 *
 *  @param sender 全屏Button
 */
- (void)fullScreenAction:(UIButton *)sender
{
    if (self.isLocked) {
        [self unLockTheScreen];
        return;
    }
    if (self.isCellVideo && sender.selected == YES) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        return;
    }
    
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
            
        case UIInterfaceOrientationPortraitUpsideDown:{
            ZNKPlayerShared.isAllowLandscape = NO;
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationPortrait:{
            ZNKPlayerShared.isAllowLandscape = YES;
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            if (self.isBottomVideo || !self.isFullScreen) {
                ZNKPlayerShared.isAllowLandscape = YES;
                [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            } else {
                ZNKPlayerShared.isAllowLandscape = NO;
                [self interfaceOrientation:UIInterfaceOrientationPortrait];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            if (self.isBottomVideo || !self.isFullScreen) {
                ZNKPlayerShared.isAllowLandscape = YES;
                [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            } else {
                ZNKPlayerShared.isAllowLandscape = NO;
                [self interfaceOrientation:UIInterfaceOrientationPortrait];
            }
        }
            break;
            
        default: {
            if (self.isBottomVideo || !self.isFullScreen) {
                ZNKPlayerShared.isAllowLandscape = YES;
                [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            } else {
                ZNKPlayerShared.isAllowLandscape = NO;
                [self interfaceOrientation:UIInterfaceOrientationPortrait];
            }
        }
            break;
    }
    
}


-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    
    [self removeFromSuperview];
    //    self.transform = CGAffineTransformIdentity;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.25f animations:^{
        if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
        }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
            self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
        [self ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
            make.centerX.ZNKMAs_equalTo(0);
            make.centerY.ZNKMAs_equalTo(0);
            make.height.ZNKMAs_equalTo(ScreenWidth);
            make.width.ZNKMAs_equalTo(ScreenHeight);
        }];
        
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.isFullScreen = YES;
        self.controlView.fullScreenBtn.selected = YES;
    }];
}
-(void)toSmallScreen{
    
    if (self.isCellVideo) {
        
        //        self.transform = CGAffineTransformIdentity;
        // 竖屏时候table滑动到可视范围
        [self.tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        // 重新监听tableview偏移量
        [self.tableView addObserver:self forKeyPath:kZNKPlayerViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        [self removeFromSuperview];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
        NSArray *visableCells = self.tableView.visibleCells;
        self.isBottomVideo = NO;
        [UIView animateWithDuration:0.25f animations:^{
            self.transform = CGAffineTransformIdentity;
            if (![visableCells containsObject:cell]) {
                [self updatePlayerViewToBottom];
            }else {
                // 根据tag取到对应的cellImageView
                UIImageView *cellImageView = [cell viewWithTag:self.cellImageViewTag];
                [self addPlayerToCellImageView:cellImageView];
            }
            
        } completion:^(BOOL finished) {
            self.controlView.backBtn.alpha = 0.0;
            self.isFullScreen = NO;
            self.controlView.fullScreenBtn.selected = NO;
        }];
        
    }else{
        //放widow上
        [self removeFromSuperview];
        [self.videoView addSubview:self];
        //    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
        [UIView animateWithDuration:0.25f animations:^{
            self.transform = CGAffineTransformIdentity;
            [self ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(0);
                //        make.centerX.mas_equalTo(0);
                //        make.centerY.mas_equalTo(0);
                make.height.ZNKMAs_equalTo(self.videoView.frame.size.height);
                make.width.ZNKMAs_equalTo(self.videoView.frame.size.width);
            }];
            
        } completion:^(BOOL finished) {
            self.controlView.backBtn.alpha = 0.0;
            self.isFullScreen = NO;
            self.controlView.fullScreenBtn.selected = NO;
        }];
        
    }
}
/**
 *  根据tableview的值来添加、移除观察者
 *
 *  @param tableView tableView
 */
- (void)setTableView:(UITableView *)tableView
{
    if (_tableView == tableView) { return; }
    
    if (_tableView) { [_tableView removeObserver:self forKeyPath:kZNKPlayerViewContentOffset]; }
    _tableView = tableView;
    if (tableView) { [tableView addObserver:self forKeyPath:kZNKPlayerViewContentOffset options:NSKeyValueObservingOptionNew context:nil]; }
}
/**
 *  设置playerLayer的填充模式
 *
 *  @param playerLayerGravity playerLayerGravity
 */
- (void)setPlayerLayerGravity:(ZNKPlayerScalingMode)playerLayerGravity
{
    _playerLayerGravity = playerLayerGravity;
    // AVLayerVideoGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
    // AVLayerVideoGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
    // AVLayerVideoGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
    switch (playerLayerGravity) {
        case ZNKPlayerScalingModeFill:
            self.player.scalingMode = IJKMPMovieScalingModeFill;
            break;
        case ZNKPlayerScalingModeAspectFit:
            self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
            break;
        case ZNKPlayerScalingModeAspectFill:
            self.player.scalingMode = IJKMPMovieScalingModeAspectFill;
            break;
        default:
            break;
    }
}

- (void)setSeekTime:(NSInteger)seekTime
{
    //    self.player.currentPlaybackTime = seekTime;
}
/**
 *  是否隐藏返回按钮  new add by KUN
 */
- (void)setIsHideBackBtn:(BOOL)isHideBackBtn {
    _isHideBackBtn = isHideBackBtn;
    self.controlView.backBtn.hidden = isHideBackBtn;
}
- (void)setIsHideControlView:(BOOL)isHideControlView
{
    _isHideControlView = isHideControlView;
    self.controlView.hidden = YES;
}
#pragma mark ---initview---
- (ZNKPlayerControlView *)controlView {
    
    if (!_controlView) {
        _controlView = [[ZNKPlayerControlView alloc]init];
        SKWeakSelf(self);
        [_controlView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
            make.top.leading.trailing.bottom.equalTo(weakself);
        }];
    }
    return _controlView;
}
- (AVAssetImageGenerator *)imageGenerator
{
    if (!_imageGenerator) {
        _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.urlAsset];
    }
    return _imageGenerator;
}


#pragma mark --getter ---
- (AVURLAsset *)urlAsset
{
    if (!_urlAsset) {
        _urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    }
    return _urlAsset;
}
- (CGFloat)totalTime
{
    return self.player.duration;
}
-(CGFloat)totalDuRation
{
    //视频采集
    AVAsset *videoAsset1 = self.urlAsset;
    return videoAsset1.duration.value;
}
- (CGFloat)totalTimescale
{
    //视频采集
    AVAsset *videoAsset1 = self.urlAsset;
    return videoAsset1.duration.timescale;
}
#pragma Install Notifiacation- -播放器依赖的相关监听

- (void)loadStateDidChange:(NSNotification*)notification {
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"LoadStateDidChange: IJKMovieLoadStatePlayThroughOK: %d\n",(int)loadState);
        if (self.player) {
            [self.controlView.activity stopAnimating];
        }
        
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
        if (self.player) {
            [self.controlView.activity startAnimating];
        }
        
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackFinish:(NSNotification*)notification {
    
    int reason =[[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            if (self.player) {
                self.controlView.horizontalLabel.hidden = NO;
                self.controlView.horizontalLabel.text = @"视频加载失败";
                
            }
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPrepareToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            if (self.isChangeSliderVideo == NO&&self.player) {
                self.controlView.startBtn.selected = YES;
                [self startAction:self.controlView.startBtn];
            }
            
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}
- (void)moviePlayFirstVideoFrameRendered:(NSNotification*)notification
{
    NSLog(@"加载第一个画面！");
    //    if (_previewImage) {
    //        _previewImage.hidden = YES;
    //    }
    if (self.player) {
        [self.controlView.activity stopAnimating];
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:2];
        
        
        
        if(![self.player isPlaying]){
            NSLog(@"检测的一次播放状态错误");
            [self play];
        }
        
    }
}
#pragma Install Notifiacation

- (void)installMovieNotificationObservers {
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayFirstVideoFrameRendered:)
                                                 name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification
                                               object:_player];
    
}

- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
}
- (void)gotoDeallocSelf
{
    [self stop];
    [self gotoRemoveSelf];
    //    [self dealloc];
}
- (void)gotoRemoveSelf
{
    [self pause];
    [self removeFromSuperview];
}
- (void)gotoShowInView:(UIView *)view withFrame:(CGRect)rect
{
    [view addSubview:self];
    [self ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
        make.top.ZNKMAs_equalTo(0);
        make.left.ZNKMAs_equalTo(0);
//        make.centerX.mas_equalTo(0);
//        make.centerY.mas_equalTo(0);
        make.height.ZNKMAs_equalTo(view.frame.size.height);
        make.width.ZNKMAs_equalTo(view.frame.size.width);
    }];
}


-(void)teadownPlayer {
    [self cancelAutoFadeOutControlBar];
    [self.player shutdown];
    self.player = nil;
    [self removeMovieNotificationObservers];
    
}

#pragma mark - 分割线-----

/**
 *  初始化player
 */
- (void)initializeThePlayer
{
    // 每次播放视频都解锁屏幕锁定
    [self unLockTheScreen];
}



/**
 *  在当前页面，设置新的Player的URL调用此方法
 */
- (void)resetToPlayNewURL
{
    self.repeatToPlay = YES;
    [self resetPlayer];
}

#pragma mark - 观察者、通知

/**
 *  添加观察者、通知
 */
- (void)addNotifications
{
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    // slider开始滑动事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    // 播放按钮点击事件
    [self.controlView.startBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    // cell上播放视频的话，该返回按钮为×
    if (self.isCellVideo) {
        [self.controlView.backBtn setImage:ZNKPlayerImage(@"ZFPlayer_close") forState:UIControlStateNormal];
    }else {
        [self.controlView.backBtn setImage:ZNKPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
    }
    // 返回按钮点击事件
    [self.controlView.backBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    // 全屏按钮点击事件
    [self.controlView.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    // 锁定屏幕方向点击事件
    [self.controlView.lockBtn addTarget:self action:@selector(lockScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    // 重播
    [self.controlView.repeatBtn addTarget:self action:@selector(repeatPlay:) forControlEvents:UIControlEventTouchUpInside];
    // 中间按钮播放
    [self.controlView.playeBtn addTarget:self action:@selector(configZFPlayer) forControlEvents:UIControlEventTouchUpInside];
    // 下载
    [self.controlView.downLoadBtn addTarget:self action:@selector(downloadVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    // 切换分辨率
    self.controlView.resolutionBlock = ^(UIButton *button) {
        // 记录切换分辨率的时刻
        NSTimeInterval currentTime = weakSelf.player.currentPlaybackTime;
        
        NSString *videoStr = weakSelf.videoURLArray[button.tag-200];
        NSURL *videoURL = [NSURL URLWithString:videoStr];
        if ([videoURL isEqual:weakSelf.videoURL]) { return; }
        weakSelf.isChangeResolution = YES;
        // reset player
        [weakSelf resetToPlayNewURL];
        weakSelf.videoURL = videoURL;
        // 从xx秒播放
        weakSelf.seekTime = currentTime;
        // 切换完分辨率自动播放
        [weakSelf autoPlayTheVideo];
        
    };
    // 点击slider快进
    self.controlView.tapBlock = ^(CGFloat value) {
        [weakSelf pause];
        // 视频总时间长度
        NSTimeInterval total           = weakSelf.player.duration;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * value);
        weakSelf.controlView.startBtn.selected = YES;
//        [weakSelf seekToTime:dragedSeconds completionHandler:^(BOOL finished) {}];
        
    };
    // 监测设备方向
    [self listeningRotating];
}

/**
 *  监听设备旋转通知
 */
- (void)listeningRotating
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}

#pragma mark - layoutSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
//    self.playerLayer.frame = self.bounds;
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    // 只要屏幕旋转就显示控制层
    self.isMaskShowing = NO;
    // 延迟隐藏controlView
    [self animateShow];
    
    // 4s，屏幕宽高比不是16：9的问题,player加到控制器上时候
    if (iPhone4s && !self.isCellVideo) {
        [self ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
            make.height.ZNKMAs_offset(ScreenWidth*2/3);
        }];
    }
    // fix iOS7 crash bug
    [self layoutIfNeeded];
}



/**
 *  videoURL的setter方法
 *
 *  @param videoURL videoURL
 */
- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    if (!self.placeholderImageName) {
        UIImage *image = ZNKPlayerImage(@"ZFPlayer_loading_bgView");
        self.layer.contents = (id) image.CGImage;
    }
    
    // 每次加载视频URL都设置重播为NO
    self.repeatToPlay = NO;
    self.playDidEnd   = NO;
    
    // 添加通知
    [self addNotifications];
    // 根据屏幕的方向设置相关UI
    [self onDeviceOrientationChange];
    
    self.isPauseByUser = YES;
    self.controlView.playeBtn.hidden = NO;
    [self.controlView hideControlView];
}


/**
 *  设置Player相关参数
 */
- (void)configZFPlayer
{
//    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
//    // 初始化playerItem
//    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
//    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
//    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//    
//    // 初始化playerLayer
//    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    
//    // 此处为默认视频填充模式
//    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    // 添加playerLayer到self.layer
//    [self.layer insertSublayer:self.playerLayer atIndex:0];
//    self.player
    // 初始化显示controlView为YES
    self.isMaskShowing = YES;
    // 延迟隐藏controlView
    [self autoFadeOutControlBar];
    
    // 添加手势
    [self createGesture];
    
    // 添加播放进度计时器
    [self createTimer];
    
    // 获取系统音量
    [self configureVolume];
    
    // 本地文件不设置ZFPlayerStateBuffering状态
    if ([self.videoURL.scheme isEqualToString:@"file"]) {
//        self.state = ZFPlayerStatePlaying;
        self.isLocalVideo = YES;
        self.controlView.downLoadBtn.enabled = NO;
    } else {
//        self.state = ZFPlayerStateBuffering;
        self.isLocalVideo = NO;
    }
    // 开始播放
    [self play];
    self.controlView.startBtn.selected = YES;
    self.isPauseByUser                 = NO;
    self.controlView.playeBtn.hidden   = YES;
    
    // 强制让系统调用layoutSubviews 两个方法必须同时写
    [self setNeedsLayout]; //是标记 异步刷新 会调但是慢
    [self layoutIfNeeded]; //加上此代码立刻刷新
}

/**
 *  自动播放，默认不自动播放
 */
- (void)autoPlayTheVideo
{
    self.isAutoPlay = YES;
    // 设置Player相关参数
    [self configZFPlayer];
}


/**
 *  获取系统音量
 */
- (void)configureVolume
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
    
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}

/**
 *  耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
            [self play];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

#pragma mark - ShowOrHideControlView

- (void)autoFadeOutControlBar
{
    if (!self.isMaskShowing) { return; }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:ZNKPlayerAnimationTimeInterval];
    
}




#pragma mark 屏幕转屏相关

/**
 *  强制屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        [self setOrientationLandscape];
        
    }else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        [self setOrientationPortrait];
        
    }
    /*
     // 非arc下
     if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
     [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
     withObject:@(orientation)];
     }
     
     // 直接调用这个方法通不过apple上架审核
     [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
     */
}



/**
 *  屏幕方向发生变化会调用这里
 */
- (void)onDeviceOrientationChange
{
    if (self.isLocked) {
        self.isFullScreen = YES;
        return;
    }
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            self.controlView.fullScreenBtn.selected = YES;
            if (self.isCellVideo) {
                [self.controlView.backBtn setImage:ZNKPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
            }
            // 设置返回按钮的约束
            [self.controlView.backBtn ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
                make.top.ZNKMAs_equalTo(20);
                make.leading.ZNKMAs_equalTo(7);
                make.width.height.ZNKMAs_equalTo(40);
            }];
            self.isFullScreen = YES;
            
        }
            break;
        case UIInterfaceOrientationPortrait:{
            self.isFullScreen = !self.isFullScreen;
            self.controlView.fullScreenBtn.selected = NO;
            if (self.isCellVideo) {
                // 改为只允许竖屏播放
                ZNKPlayerShared.isAllowLandscape = NO;
                [self.controlView.backBtn setImage:ZNKPlayerImage(@"ZFPlayer_close") forState:UIControlStateNormal];
                [self.controlView.backBtn ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
                    make.top.ZNKMAs_equalTo(10);
                    make.leading.ZNKMAs_equalTo(7);
                    make.width.height.ZNKMAs_equalTo(20);
                }];
                
                // 点击播放URL时候不会调用次方法
                if (!self.isFullScreen) {
                    // 竖屏时候table滑动到可视范围
                    [self.tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                    // 重新监听tableview偏移量
                    [self.tableView addObserver:self forKeyPath:kZNKPlayerViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
                }
                // 当设备转到竖屏时候，设置为竖屏约束
                [self setOrientationPortrait];
                
            }else {
                [self.controlView.backBtn ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
                    make.top.ZNKMAs_equalTo(5);
                    make.leading.ZNKMAs_equalTo(7);
                    make.width.height.ZNKMAs_equalTo(40);
                }];
            }
            self.isFullScreen = NO;
            
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            self.controlView.fullScreenBtn.selected = YES;
            if (self.isCellVideo) {
                [self.controlView.backBtn setImage:ZNKPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
            }
            [self.controlView.backBtn ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
                make.top.ZNKMAs_equalTo(20);
                make.leading.ZNKMAs_equalTo(7);
                make.width.height.ZNKMAs_equalTo(40);
            }];
            self.isFullScreen = YES;
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            self.controlView.fullScreenBtn.selected = YES;
            if (self.isCellVideo) {
                [self.controlView.backBtn setImage:ZNKPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
            }
            [self.controlView.backBtn ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
                make.top.ZNKMAs_equalTo(20);
                make.leading.ZNKMAs_equalTo(7);
                make.width.height.ZNKMAs_equalTo(40);
            }];
            self.isFullScreen = YES;
        }
            break;
            
        default:
            break;
    }
    // 设置显示or不显示锁定屏幕方向按钮
    self.controlView.lockBtn.hidden = !self.isFullScreen;
    
    // 在cell上播放视频 && 不允许横屏（此时为竖屏状态,解决自动转屏到横屏，状态栏消失bug）
    if (self.isCellVideo && !ZNKPlayerShared.isAllowLandscape) {
        [self.controlView.backBtn setImage:ZNKPlayerImage(@"ZFPlayer_close") forState:UIControlStateNormal];
        [self.controlView.backBtn ZNKMAs_updateConstraints:^(ZNKMASConstraintMaker *make) {
            make.top.ZNKMAs_equalTo(10);
            make.leading.ZNKMAs_equalTo(7);
            make.width.height.ZNKMAs_equalTo(20);
        }];
        self.controlView.fullScreenBtn.selected = NO;
        self.controlView.lockBtn.hidden = YES;
        self.isFullScreen = NO;
        return;
    }
}

/**
 *  锁定屏幕方向按钮
 *
 *  @param sender UIButton
 */
- (void)lockScreenAction:(UIButton *)sender
{
    sender.selected             = !sender.selected;
    self.isLocked               = sender.selected;
    // 调用AppDelegate单例记录播放状态是否锁屏，在TabBarController设置哪些页面支持旋转
    ZNKPlayerShared.isLockScreen = sender.selected;
}

/**
 *  解锁屏幕方向锁定
 */
- (void)unLockTheScreen
{
    // 调用AppDelegate单例记录播放状态是否锁屏
    ZNKPlayerShared.isLockScreen       = NO;
    self.controlView.lockBtn.selected = NO;
    self.isLocked = NO;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    self.isPanFastForward = YES;
    self.isGoBackFull = YES;
}


#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond
{
//    self.state = ZFPlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
//        if (!self.playerItem.isPlaybackLikelyToKeepUp) { [self bufferingSomeSecond]; }
        
    });
}

#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
//- (NSTimeInterval)availableDuration {
////    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
////    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
//    float startSeconds        = CMTimeGetSeconds(timeRange.start);
//    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
//    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
//    return result;
//}

#pragma mark - Action









/**
 *  重播点击事件
 *
 *  @param sender sender
 */
- (void)repeatPlay:(UIButton *)sender
{
    // 没有播放完
    self.playDidEnd    = NO;
    // 重播改为NO
    self.repeatToPlay  = NO;
    // 准备显示控制层
    self.isMaskShowing = NO;
    [self animateShow];
    // 重置控制层View
    [self.controlView resetControlView];
//    [self seekToTime:0 completionHandler:nil];
}

- (void)downloadVideo:(UIButton *)sender
{
    NSString *urlStr = self.videoURL.absoluteString;
    if (self.downloadBlock) {
        self.downloadBlock(urlStr);
    }
}

#pragma mark - NSNotification Action

/**
 *  播放完了
 *
 *  @param notification 通知
 */
- (void)moviePlayDidEnd:(NSNotification *)notification
{
//    self.state            = ZFPlayerStateStopped;
    if (self.isBottomVideo && !self.isFullScreen) { // 播放完了，如果是在小屏模式 && 在bottom位置，直接关闭播放器
        self.repeatToPlay = NO;
        self.playDidEnd   = NO;
        [self resetPlayer];
    } else {
        self.controlView.backgroundColor  = RGBA(0, 0, 0, .6);
        self.playDidEnd                   = YES;
        self.controlView.repeatBtn.hidden = NO;
        // 初始化显示controlView为YES
        self.isMaskShowing                = NO;
        // 延迟隐藏controlView
        [self animateShow];
    }
}

///**
// *  应用退到后台
// */
//- (void)appDidEnterBackground
//{
//    self.didEnterBackground = YES;
//    [_player pause];
//    self.state = ZFPlayerStatePause;
//    [self cancelAutoFadeOutControlBar];
//    self.controlView.startBtn.selected = NO;
//}
//
///**
// *  应用进入前台
// */
//- (void)appDidEnterPlayGround
//{
//    self.didEnterBackground = NO;
//    self.isMaskShowing = NO;
//    // 延迟隐藏controlView
//    [self animateShow];
//    if (!self.isPauseByUser) {
//        self.state                         = ZFPlayerStatePlaying;
//        self.controlView.startBtn.selected = YES;
//        self.isPauseByUser                 = NO;
//        [self play];
//    }
//}




///**
// *  从xx秒开始播放视频跳转
// *
// *  @param dragedSeconds 视频跳转的秒数
// */
//- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler
//{
//    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
//        // seekTime:completionHandler:不能精确定位
//        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
//        // 转换成CMTime才能给player来控制播放进度
//        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
//        [self.player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//            // 视频跳转回调
//            if (completionHandler) { completionHandler(finished); }
//            
//            [self play];
//            self.seekTime = 0;
//            if (!self.playerItem.isPlaybackLikelyToKeepUp && !self.isLocalVideo) { self.state = ZFPlayerStateBuffering; }
//            
//        }];
//    }
//}

#pragma mark - UIPanGestureRecognizer手势方法

/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
//- (void)panDirection:(UIPanGestureRecognizer *)pan
//{
//    //根据在view上Pan的位置，确定是调音量还是亮度
//    CGPoint locationPoint = [pan locationInView:self];
//    
//    // 我们要响应水平移动和垂直移动
//    // 根据上次和本次移动的位置，算出一个速率的point
//    CGPoint veloctyPoint = [pan velocityInView:self];
//    
//    // 判断是垂直移动还是水平移动
//    switch (pan.state) {
//        case UIGestureRecognizerStateBegan:{ // 开始移动
//            // 使用绝对值来判断移动的方向
//            CGFloat x = fabs(veloctyPoint.x);
//            CGFloat y = fabs(veloctyPoint.y);
//            if (x > y) { // 水平移动
//                if (_isPanFastForward) {
//                    // 取消隐藏
//                    self.controlView.horizontalLabel.hidden = NO;
//                    self.panDirection = PanDirectionHorizontalMoved;
//                    // 给sumTime初值
//                    CMTime time       = self.player.currentTime;
//                    self.sumTime      = time.value/time.timescale;
//                    
//                    // 暂停视频播放
//                    [self pause];
//                }
//                
//            }
//            else if (x < y){ // 垂直移动
//                self.panDirection = PanDirectionVerticalMoved;
//                // 开始滑动的时候,状态改为正在控制音量
//                if (locationPoint.x > self.bounds.size.width / 2) {
//                    self.isVolume = YES;
//                }else { // 状态改为显示亮度调节
//                    self.isVolume = NO;
//                }
//            }
//            break;
//        }
//        case UIGestureRecognizerStateChanged:{ // 正在移动
//            switch (self.panDirection) {
//                case PanDirectionHorizontalMoved:{
//                    // 移动中一直显示快进label
//                    if (_isPanFastForward) {
//                        self.controlView.horizontalLabel.hidden = NO;
//                        [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
//                    }
//                    
//                    break;
//                }
//                case PanDirectionVerticalMoved:{
//                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
//                    break;
//                }
//                default:
//                    break;
//            }
//            break;
//        }
//        case UIGestureRecognizerStateEnded:{ // 移动停止
//            // 移动结束也需要判断垂直或者平移
//            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
//            switch (self.panDirection) {
//                case PanDirectionHorizontalMoved:{
//                    // 继续播放
//                    
//                    if (_isPanFastForward) {
//                        [self play];
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            // 隐藏视图
//                            self.controlView.horizontalLabel.hidden = YES;
//                        });
//                        // 快进、快退时候把开始播放按钮改为播放状态
//                        self.controlView.startBtn.selected = YES;
//                        self.isPauseByUser                 = NO;
//                        
////                        [self seekToTime:self.sumTime completionHandler:nil];
//                        // 把sumTime滞空，不然会越加越多
//                        self.sumTime = 0;
//                    }
//                    
//                    
//                    break;
//                }
//                case PanDirectionVerticalMoved:{
//                    // 垂直移动结束后，把状态改为不再控制音量
//                    self.isVolume = NO;
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        self.controlView.horizontalLabel.hidden = YES;
//                    });
//                    break;
//                }
//                default:
//                    break;
//            }
//            break;
//        }
//        default:
//            break;
//    }
//}

/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value
{
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
//- (void)horizontalMoved:(CGFloat)value
//{
//    // 快进快退的方法
//    NSString *style = @"";
//    if (value < 0) { style = @"<<"; }
//    if (value > 0) { style = @">>"; }
//    if (value == 0) { return; }
//    
//    // 每次滑动需要叠加时间
//    self.sumTime += value / 200;
//    
//    // 需要限定sumTime的范围
//    CMTime totalTime           = self.playerItem.duration;
//    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
//    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
//    if (self.sumTime < 0) { self.sumTime = 0; }
//    
//    // 当前快进的时间
//    NSString *nowTime         = [self durationStringWithTime:(int)self.sumTime];
//    // 总时间
//    NSString *durationTime    = [self durationStringWithTime:(int)totalMovieDuration];
//    
//    // 更新快进label的时长
//    self.controlView.horizontalLabel.text  = [NSString stringWithFormat:@"%@ %@ / %@",style, nowTime, durationTime];
//    // 更新slider的进度
//    self.controlView.videoSlider.value     = self.sumTime/totalMovieDuration;
//    // 更新现在播放的时间
//    self.controlView.currentTimeLabel.text = nowTime;
//}





#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000 ) {
        if (buttonIndex == 0) { [self backButtonAction];} // 点击取消，直接调用返回函数
        if (buttonIndex == 1) { [self configZFPlayer];}   // 点击确定，设置player相关参数
    }
}

#pragma mark - Others

/**
 *  通过颜色来生成一个纯色图片
 */
- (UIImage *)buttonImageFromColor:(UIColor *)color
{
    CGRect rect = self.bounds;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); return img;
}

#pragma mark - Setter

/**
 *  设置播放的状态
 *
 *  @param state ZFPlayerState
 */
//- (void)setState:(ZNKPlayerPlaybackState)state
//{
//    _state = state;
//    if (state == ZNKPlayerStatePlaying) {
//        // 改为黑色的背景，不然站位图会显示
//        UIImage *image = [self buttonImageFromColor:[UIColor blackColor]];
//        self.layer.contents = (id) image.CGImage;
//    } else if (state == ZFPlayerStateFailed) {
//        self.controlView.downLoadBtn.enabled = NO;
//    }
//    // 控制菊花显示、隐藏
//    state == ZFPlayerStateBuffering ? ([self.controlView.activity startAnimating]) : ([self.controlView.activity stopAnimating]);
//}


/**
 *  根据tableview的值来添加、移除观察者
 *
 *  @param tableView tableView
 */
//- (void)setTableView:(UITableView *)tableView
//{
//    if (_tableView == tableView) { return; }
//    
//    if (_tableView) { [_tableView removeObserver:self forKeyPath:kZNKPlayerViewContentOffset]; }
//    _tableView = tableView;
//    if (tableView) { [tableView addObserver:self forKeyPath:kZNKPlayerViewContentOffset options:NSKeyValueObservingOptionNew context:nil]; }
//}

/**
 *  设置playerLayer的填充模式
 *
 *  @param playerLayerGravity playerLayerGravity
 */
//- (void)setPlayerLayerGravity:(ZFPlayerLayerGravity)playerLayerGravity
//{
//    _playerLayerGravity = playerLayerGravity;
//    // AVLayerVideoGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
//    // AVLayerVideoGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
//    // AVLayerVideoGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
//    switch (playerLayerGravity) {
//        case ZFPlayerLayerGravityResize:
//            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//            break;
//        case ZFPlayerLayerGravityResizeAspect:
//            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//            break;
//        case ZFPlayerLayerGravityResizeAspectFill:
//            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//            break;
//        default:
//            break;
//    }
//}

/**
 *  是否有下载功能
 */
- (void)setHasDownload:(BOOL)hasDownload
{
    _hasDownload = hasDownload;
    self.controlView.downLoadBtn.hidden = !hasDownload;
}

- (void)setResolutionDic:(NSDictionary *)resolutionDic
{
    _resolutionDic = resolutionDic;
    self.controlView.resolutionBtn.hidden = NO;
    self.videoURLArray = [resolutionDic allValues];
    self.controlView.resolutionArray = [resolutionDic allKeys];
}

/**
 *  设置播放视频前的占位图
 *
 *  @param placeholderImageName 占位图的图片名称
 */
- (void)setPlaceholderImageName:(NSString *)placeholderImageName
{
    _placeholderImageName = placeholderImageName;
    if (placeholderImageName) {
        UIImage *image = [UIImage imageNamed:self.placeholderImageName];
        self.layer.contents = (id) image.CGImage;
    }else {
        UIImage *image = ZNKPlayerImage(@"ZFPlayer_loading_bgView");
        self.layer.contents = (id) image.CGImage;
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.controlView.titleLabel.text = title;
}

#pragma mark - Getter

/**
 * 懒加载 控制层View
 *
 *  @return ZFPlayerControlView
 */
//- (ZNKPlayerControlView *)controlView
//{
//    if (!_controlView) {
//        _controlView = [[ZFPlayerControlView alloc] init];
//        [self addSubview:_controlView];
//        SKWeakSelf(self);
//        [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.leading.trailing.bottom.equalTo(weakself);
//        }];
//    }
//    return _controlView;
//}

//- (AVAssetImageGenerator *)imageGenerator
//{
//    if (!_imageGenerator) {
//        _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.urlAsset];
//    }
//    return _imageGenerator;
//}

@end

@implementation ZNKPlayerControlView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [self addSubview:self.topImageView];
        [self addSubview:self.bottomImageView];
        [self.bottomImageView addSubview:self.startBtn];
        [self.bottomImageView addSubview:self.currentTimeLabel];
        [self.bottomImageView addSubview:self.progressView];
        [self.bottomImageView addSubview:self.videoSlider];
        [self.bottomImageView addSubview:self.fullScreenBtn];
        [self.bottomImageView addSubview:self.totalTimeLabel];
        
        [self.topImageView addSubview:self.downLoadBtn];
        [self addSubview:self.lockBtn];
        [self addSubview:self.backBtn];
        [self addSubview:self.activity];
        [self addSubview:self.repeatBtn];
        [self addSubview:self.horizontalLabel];
        [self addSubview:self.playeBtn];
        
        [self.topImageView addSubview:self.resolutionBtn];
        [self.topImageView addSubview:self.titleLabel];
        
        // 添加子控件的约束
        [self makeSubViewsConstraints];
        // 分辨率btn点击
        [self.resolutionBtn addTarget:self action:@selector(resolutionAction:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
        [self.videoSlider addGestureRecognizer:sliderTap];
        
        [self.activity stopAnimating];
        self.downLoadBtn.hidden     = YES;
        self.resolutionBtn.hidden   = YES;
        // 初始化时重置controlView
        [self resetControlView];
    }
    return self;
}

- (void)makeSubViewsConstraints
{
    [self.backBtn ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.equalTo(self.ZNKMAs_leading).offset(7);
        make.top.equalTo(self.ZNKMAs_top).offset(5);
        make.width.height.ZNKMAs_equalTo(40);
    }];
    
    [self.topImageView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.ZNKMAs_equalTo(80);
    }];
    
    [self.downLoadBtn ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.width.ZNKMAs_equalTo(40);
        make.height.ZNKMAs_equalTo(49);
        make.trailing.equalTo(self.topImageView.ZNKMAs_trailing).offset(-10);
        make.centerY.equalTo(self.backBtn.ZNKMAs_centerY);
    }];
    
    [self.resolutionBtn ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.width.ZNKMAs_equalTo(40);
        make.height.ZNKMAs_equalTo(30);
        //-10 到－50 bt需求
        make.trailing.equalTo(self.downLoadBtn.ZNKMAs_leading).offset(-130);
        make.centerY.equalTo(self.backBtn.ZNKMAs_centerY);
    }];
    
    [self.titleLabel ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.equalTo(self.backBtn.ZNKMAs_trailing).offset(10);
        make.centerY.equalTo(self.backBtn.ZNKMAs_centerY);
        make.trailing.equalTo(self.resolutionBtn.ZNKMAs_leading).offset(-10);
    }];
    
    [self.bottomImageView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.ZNKMAs_equalTo(50);
    }];
    
    [self.startBtn ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.equalTo(self.bottomImageView.ZNKMAs_leading).offset(5);
        make.bottom.equalTo(self.bottomImageView.ZNKMAs_bottom).offset(-5);
        make.width.height.ZNKMAs_equalTo(30);
    }];
    
    [self.currentTimeLabel ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.equalTo(self.startBtn.ZNKMAs_trailing).offset(-3);
        make.centerY.equalTo(self.startBtn.ZNKMAs_centerY);
        make.width.ZNKMAs_equalTo(43);
    }];
    
    [self.fullScreenBtn ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.width.height.ZNKMAs_equalTo(30);
        make.trailing.equalTo(self.bottomImageView.ZNKMAs_trailing).offset(-5);
        make.centerY.equalTo(self.startBtn.ZNKMAs_centerY);
    }];
    
    [self.totalTimeLabel ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.trailing.equalTo(self.fullScreenBtn.ZNKMAs_leading).offset(3);
        make.centerY.equalTo(self.startBtn.ZNKMAs_centerY);
        make.width.ZNKMAs_equalTo(43);
    }];
    
    [self.progressView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.ZNKMAs_trailing).offset(4);
        make.trailing.equalTo(self.totalTimeLabel.ZNKMAs_leading).offset(-4);
        make.centerY.equalTo(self.startBtn.ZNKMAs_centerY);
    }];
    
    [self.videoSlider ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.ZNKMAs_trailing).offset(4);
        make.trailing.equalTo(self.totalTimeLabel.ZNKMAs_leading).offset(-4);
        make.centerY.equalTo(self.currentTimeLabel.ZNKMAs_centerY).offset(-1);
        make.height.ZNKMAs_equalTo(30);
    }];
    
    [self.lockBtn ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.leading.equalTo(self.ZNKMAs_leading).offset(15);
        make.centerY.equalTo(self.ZNKMAs_centerY);
        make.width.height.ZNKMAs_equalTo(40);
    }];
    
    [self.horizontalLabel ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.width.ZNKMAs_equalTo(150);
        make.height.ZNKMAs_equalTo(33);
        make.center.equalTo(self);
    }];
    
    [self.activity ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.repeatBtn ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.playeBtn ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)hideControlView
{
    self.topImageView.alpha    = 0;
    self.bottomImageView.alpha = 0;
    self.lockBtn.alpha         = 0;
    // 隐藏resolutionView
    self.resolutionBtn.selected = YES;
    [self resolutionAction:self.resolutionBtn];
}
#pragma mark - Action

/**
 *  点击topImageView上的按钮
 */
- (void)resolutionAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    // 显示隐藏分辨率View
    self.resolutionView.hidden = !sender.isSelected;
}

/**
 *  点击切换分别率按钮
 */
- (void)changeResolution:(UIButton *)sender
{
    // 隐藏分辨率View
    self.resolutionView.hidden  = YES;
    // 分辨率Btn改为normal状态
    self.resolutionBtn.selected = NO;
    // topImageView上的按钮的文字
    [self.resolutionBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    if (self.resolutionBlock) { self.resolutionBlock(sender); }
}

/**
 *  UISlider TapAction
 */
- (void)tapSliderAction:(UITapGestureRecognizer *)tap
{
    if ([tap.view isKindOfClass:[UISlider class]] && self.tapBlock) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        self.tapBlock(tapValue);
    }
}

#pragma mark - Public Method

/** 重置ControlView */
- (void)resetControlView
{
    self.videoSlider.value      = 0;
    self.progressView.progress  = 0;
    self.currentTimeLabel.text  = @"00:00";
    self.totalTimeLabel.text    = @"00:00";
    self.horizontalLabel.hidden = YES;
    self.repeatBtn.hidden       = YES;
    self.playeBtn.hidden        = YES;
    self.resolutionView.hidden  = YES;
    self.backgroundColor        = [UIColor clearColor];
    self.downLoadBtn.enabled    = YES;
}

- (void)resetControlViewForResolution
{
    self.horizontalLabel.hidden = YES;
    self.repeatBtn.hidden       = YES;
    self.resolutionView.hidden  = YES;
    self.playeBtn.hidden        = YES;
    self.downLoadBtn.enabled    = YES;
    self.backgroundColor        = [UIColor clearColor];
}

- (void)showControlView
{
    self.topImageView.alpha    = 1;
    self.bottomImageView.alpha = 1;
    self.lockBtn.alpha         = 1;
}



#pragma mark - setter

- (void)setResolutionArray:(NSArray *)resolutionArray
{
    _resolutionArray = resolutionArray;
    [_resolutionBtn setTitle:resolutionArray.firstObject forState:UIControlStateNormal];
    // 添加分辨率按钮和分辨率下拉列表
    self.resolutionView = [[UIView alloc] init];
    self.resolutionView.hidden = YES;
    self.resolutionView.backgroundColor = RGBA(0, 0, 0, 0.7);
    [self addSubview:self.resolutionView];
    
    [self.resolutionView ZNKMAs_makeConstraints:^(ZNKMASConstraintMaker *make) {
        make.width.ZNKMAs_equalTo(40);
        make.height.ZNKMAs_equalTo(30*resolutionArray.count);
        make.leading.equalTo(self.resolutionBtn.ZNKMAs_leading).offset(0);
        make.top.equalTo(self.resolutionBtn.ZNKMAs_bottom).offset(0);
    }];
    // 分辨率View上边的Btn
    for (int i = 0 ; i < resolutionArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 200+i;
        [self.resolutionView addSubview:btn];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.frame = CGRectMake(0, 30*i, 40, 30);
        [btn setTitle:resolutionArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
#pragma mark - getter

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:ZNKPlayerImage(@"ZNKPlayer_back_full") forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIImageView *)topImageView
{
    if (!_topImageView) {
        _topImageView                        = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.image                  = ZNKPlayerImage(@"ZNKPlayer_top_shadow");
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView
{
    if (!_bottomImageView) {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.image                  = ZNKPlayerImage(@"ZNKPlayer_bottom_shadow");
    }
    return _bottomImageView;
}

- (UIButton *)lockBtn
{
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:ZNKPlayerImage(@"ZNKPlayer_unlock-nor") forState:UIControlStateNormal];
        [_lockBtn setImage:ZNKPlayerImage(@"ZNKPlayer_lock-nor") forState:UIControlStateSelected];
    }
    return _lockBtn;
}

- (UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:ZNKPlayerImage(@"ZNKPlayer_play") forState:UIControlStateNormal];
        [_startBtn setImage:ZNKPlayerImage(@"ZNKPlayer_pause") forState:UIControlStateSelected];
    }
    return _startBtn;
}

- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel               = [[UILabel alloc] init];
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor    = [UIColor clearColor];
    }
    return _progressView;
}

- (ZNKSlider *)videoSlider
{
    if (!_videoSlider) {
        _videoSlider                       = [[ZNKSlider alloc] init];
        _videoSlider.popUpViewCornerRadius = 0.0;
        _videoSlider.popUpViewColor = RGBA(19, 19, 9, 1);
        _videoSlider.popUpViewArrowLength = 8;
        // 设置slider
        [_videoSlider setThumbImage:ZNKPlayerImage(@"ZNKPlayer_slider") forState:UIControlStateNormal];
        _videoSlider.maximumValue          = 1;
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    return _videoSlider;
}

- (UILabel *)totalTimeLabel
{
    if (!_totalTimeLabel) {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:ZNKPlayerImage(@"ZNKPlayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn setImage:ZNKPlayerImage(@"ZNKPlayer_shrinkscreen") forState:UIControlStateSelected];
    }
    return _fullScreenBtn;
}

- (UILabel *)horizontalLabel
{
    if (!_horizontalLabel) {
        _horizontalLabel                 = [[UILabel alloc] init];
        _horizontalLabel.textColor       = [UIColor whiteColor];
        _horizontalLabel.textAlignment   = NSTextAlignmentCenter;
        _horizontalLabel.font            = [UIFont systemFontOfSize:15.0];
        _horizontalLabel.backgroundColor = [UIColor colorWithPatternImage:ZNKPlayerImage(@"ZNKPlayer_management_mask")];
    }
    return _horizontalLabel;
}

- (UIActivityIndicatorView *)activity
{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activity;
}

- (UIButton *)repeatBtn
{
    if (!_repeatBtn) {
        _repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatBtn setImage:ZNKPlayerImage(@"ZNKPlayer_repeat_video") forState:UIControlStateNormal];
    }
    return _repeatBtn;
}

- (UIButton *)downLoadBtn
{
    if (!_downLoadBtn) {
        _downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadBtn setImage:ZNKPlayerImage(@"ZNKPlayer_download") forState:UIControlStateNormal];
        [_downLoadBtn setImage:ZNKPlayerImage(@"ZNKPlayer_not_download") forState:UIControlStateDisabled];
    }
    return _downLoadBtn;
}

- (UIButton *)resolutionBtn
{
    if (!_resolutionBtn) {
        _resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _resolutionBtn.backgroundColor = RGBA(0, 0, 0, 0.7);
    }
    return _resolutionBtn;
}

- (UIButton *)playeBtn
{
    if (!_playeBtn) {
        _playeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playeBtn setImage:ZNKPlayerImage(@"ZNKPlayer_play_btn") forState:UIControlStateNormal];
    }
    return _playeBtn;
}

@end

@implementation ZNKBrightnessView

+ (instancetype)sharedBrightnessView {
    static ZNKBrightnessView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZNKBrightnessView alloc] init];
        [[UIApplication sharedApplication].keyWindow addSubview:instance];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(ScreenWidth * 0.5, ScreenHeight * 0.5, 155, 155);
        
        self.layer.cornerRadius  = 10;
        self.layer.masksToBounds = YES;
        
        // 使用UIToolbar实现毛玻璃效果，简单粗暴，支持iOS7+
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        toolbar.alpha = 0.97;
        [self addSubview:toolbar];
        
        self.backImage = ({
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 76)];
            imgView.image        = ZNKPlayerImage(@"ZNKPlayer_brightness");
            [self addSubview:imgView];
            imgView;
        });
        
        self.title = ({
            UILabel *title      = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
            title.font          = [UIFont boldSystemFontOfSize:16];
            title.textColor     = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
            title.textAlignment = NSTextAlignmentCenter;
            title.text          = @"亮度";
            [self addSubview:title];
            title;
        });
        
        self.longView = ({
            UIView *longView         = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
            longView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
            [self addSubview:longView];
            longView;
        });
        
        [self createTips];
        [self addNotification];
        [self addObserver];
        
        self.alpha = 0.0;
    }
    return self;
}

// 创建 Tips
- (void)createTips {
    
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    
    CGFloat tipW = (self.longView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat tipX          = i * (tipW + 1) + 1;
        UIImageView *image    = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame           = CGRectMake(tipX, tipY, tipW, tipH);
        [self.longView addSubview:image];
        [self.tipArray addObject:image];
    }
    [self updateLongView:[UIScreen mainScreen].brightness];
}

#pragma makr - 通知 KVO
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLayer:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)addObserver {
    
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGFloat sound = [change[@"new"] floatValue];
    [self appearSoundView];
    [self updateLongView:sound];
}

- (void)updateLayer:(NSNotification *)notify {
    self.orientationDidChange = YES;
    [self setNeedsLayout];
}

#pragma mark - Methond
- (void)appearSoundView {
    if (self.alpha == 0.0) {
        self.alpha = 1.0;
        [self updateTimer];
    }
}

- (void)disAppearSoundView {
    
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - Timer Methond
- (void)addtimer {
    
    if (self.timer) {
        return;
    }
    
    self.timer = [NSTimer timerWithTimeInterval:3
                                         target:self
                                       selector:@selector(disAppearSoundView)
                                       userInfo:nil
                                        repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)removeTimer {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)updateTimer {
    [self removeTimer];
    [self addtimer];
}

#pragma mark - Update View
- (void)updateLongView:(CGFloat)sound {
    CGFloat stage = 1 / 15.0;
    NSInteger level = sound / stage;
    
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView *img = self.tipArray[i];
        
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

- (void)didMoveToSuperview {}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.orientationDidChange) {
        [UIView animateWithDuration:0.25 animations:^{
            if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait
                || [UIDevice currentDevice].orientation == UIDeviceOrientationFaceUp) {
                self.center = CGPointMake(ScreenWidth * 0.5, (ScreenHeight - 10) * 0.5);
            } else {
                self.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
            }
        } completion:^(BOOL finished) {
            self.orientationDidChange = NO;
        }];
    } else {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
            self.center = CGPointMake(ScreenWidth * 0.5, (ScreenHeight - 10) * 0.5);
        } else {
            self.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
        }
    }
    
    self.backImage.center = CGPointMake(155 * 0.5, 155 * 0.5);
}

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

@interface CALayer (ZNKAnimationAdditions)

@end

@implementation CALayer (ZNKAnimationAdditions)

- (void)animateKey:(NSString *)animationName fromValue:(id)fromValue toValue:(id)toValue
         customize:(void (^)(CABasicAnimation *animation))block
{
    [self setValue:toValue forKey:animationName];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:animationName];
    anim.fromValue = fromValue ?: [self.presentationLayer valueForKey:animationName];
    anim.toValue = toValue;
    if (block) block(anim);
    [self addAnimation:anim forKey:animationName];
}
@end

NSString *const ZNKSliderFillColorAnim = @"fillColor";

@implementation ZNKValuePopUpView

{
    BOOL _shouldAnimate;
    CFTimeInterval _animDuration;
    
    CAShapeLayer *_pathLayer;
    
    UIImageView *_imageView;
    UILabel *_timeLabel;
    CGFloat _arrowCenterOffset;
    
    CAShapeLayer *_colorAnimLayer;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

// if ivar _shouldAnimate) is YES then return an animation
// otherwise return NSNull (no animation)
- (id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
    if (_shouldAnimate) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
        anim.beginTime = CACurrentMediaTime();
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.fromValue = [layer.presentationLayer valueForKey:key];
        anim.duration = _animDuration;
        return anim;
    } else return (id <CAAction>)[NSNull null];
}

#pragma mark - public

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldAnimate = NO;
        self.layer.anchorPoint = CGPointMake(0.5, 1);
        
        self.userInteractionEnabled = NO;
        _pathLayer = (CAShapeLayer *)self.layer; // ivar can now be accessed without casting to CAShapeLayer every time
        
        _cornerRadius = 4.0;
        _arrowLength = 13.0;
        _widthPaddingFactor = 1.15;
        _heightPaddingFactor = 1.1;
        
        _colorAnimLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_colorAnimLayer];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.text = @"10:00";
        _timeLabel.font = [UIFont systemFontOfSize:10.0];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_timeLabel];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageView];
        
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)radius
{
    if (_cornerRadius == radius) return;
    _cornerRadius = radius;
    _pathLayer.path = [self pathForRect:self.bounds withArrowOffset:_arrowCenterOffset].CGPath;
    
}

- (UIColor *)color
{
    return [UIColor colorWithCGColor:[_pathLayer.presentationLayer fillColor]];
}

- (void)setColor:(UIColor *)color
{
    _pathLayer.fillColor = color.CGColor;
    [_colorAnimLayer removeAnimationForKey:ZNKSliderFillColorAnim]; // single color, no animation required
}

- (UIColor *)opaqueColor
{
    return opaqueUIColorFromCGColor([_colorAnimLayer.presentationLayer fillColor] ?: _pathLayer.fillColor);
}

- (void)setText:(NSString *)string
{
    _timeLabel.text = string;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

// set up an animation, but prevent it from running automatically
// the animation progress will be adjusted manually
- (void)setAnimatedColors:(NSArray *)animatedColors withKeyTimes:(NSArray *)keyTimes
{
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *col in animatedColors) {
        [cgColors addObject:(id)col.CGColor];
    }
    
    CAKeyframeAnimation *colorAnim = [CAKeyframeAnimation animationWithKeyPath:ZNKSliderFillColorAnim];
    colorAnim.keyTimes = keyTimes;
    colorAnim.values = cgColors;
    colorAnim.fillMode = kCAFillModeBoth;
    colorAnim.duration = 1.0;
    colorAnim.delegate = self;
    
    // As the interpolated color values from the presentationLayer are needed immediately
    // the animation must be allowed to start to initialize _colorAnimLayer's presentationLayer
    // hence the speed is set to min value - then set to zero in 'animationDidStart:' delegate method
    _colorAnimLayer.speed = FLT_MIN;
    _colorAnimLayer.timeOffset = 0.0;
    
    [_colorAnimLayer addAnimation:colorAnim forKey:ZNKSliderFillColorAnim];
}

- (void)setAnimationOffset:(CGFloat)animOffset returnColor:(void (^)(UIColor *opaqueReturnColor))block
{
    if ([_colorAnimLayer animationForKey:ZNKSliderFillColorAnim]) {
        _colorAnimLayer.timeOffset = animOffset;
        _pathLayer.fillColor = [_colorAnimLayer.presentationLayer fillColor];
        block([self opaqueColor]);
    }
}

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset
{
    // only redraw path if either the arrowOffset or popUpView size has changed
    if (arrowOffset != _arrowCenterOffset || !CGSizeEqualToSize(frame.size, self.frame.size)) {
        _pathLayer.path = [self pathForRect:frame withArrowOffset:arrowOffset].CGPath;
    }
    _arrowCenterOffset = arrowOffset;
    
    CGFloat anchorX = 0.5+(arrowOffset/CGRectGetWidth(frame));
    self.layer.anchorPoint = CGPointMake(anchorX, 1);
    self.layer.position = CGPointMake(CGRectGetMinX(frame) + CGRectGetWidth(frame)*anchorX, 0);
    self.layer.bounds = (CGRect){CGPointZero, frame.size};
    
}

// _shouldAnimate = YES; causes 'actionForLayer:' to return an animation for layer property changes
// call the supplied block, then set _shouldAnimate back to NO
- (void)animateBlock:(void (^)(CFTimeInterval duration))block
{
    _shouldAnimate = YES;
    _animDuration = 0.5;
    
    CAAnimation *anim = [self.layer animationForKey:@"position"];
    if ((anim)) { // if previous animation hasn't finished reduce the time of new animation
        CFTimeInterval elapsedTime = MIN(CACurrentMediaTime() - anim.beginTime, anim.duration);
        _animDuration = _animDuration * elapsedTime / anim.duration;
    }
    
    block(_animDuration);
    _shouldAnimate = NO;
}

- (void)showAnimated:(BOOL)animated
{
    if (!animated) {
        self.layer.opacity = 1.0;
        return;
    }
    
    [CATransaction begin]; {
        // start the transform animation from scale 0.5, or its current value if it's already running
        NSValue *fromValue = [self.layer animationForKey:@"transform"] ? [self.layer.presentationLayer valueForKey:@"transform"] : [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)];
        
        [self.layer animateKey:@"transform" fromValue:fromValue toValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]
                     customize:^(CABasicAnimation *animation) {
                         animation.duration = 0.4;
                         animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.8 :2.5 :0.35 :0.5];
                     }];
        
        [self.layer animateKey:@"opacity" fromValue:nil toValue:@1.0 customize:^(CABasicAnimation *animation) {
            animation.duration = 0.1;
        }];
    } [CATransaction commit];
}

- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)())block
{
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            block();
            self.layer.transform = CATransform3DIdentity;
        }];
        if (animated) {
            [self.layer animateKey:@"transform" fromValue:nil
                           toValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)]
                         customize:^(CABasicAnimation *animation) {
                             animation.duration = 0.55;
                             animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.1 :-2 :0.3 :3];
                         }];
            
            [self.layer animateKey:@"opacity" fromValue:nil toValue:@0.0 customize:^(CABasicAnimation *animation) {
                animation.duration = 0.75;
            }];
        } else { // not animated - just set opacity to 0.0
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.layer.opacity = 0.0;
            });
        }
    } [CATransaction commit];
}

#pragma mark - CAAnimation delegate

// set the speed to zero to freeze the animation and set the offset to the correct value
// the animation can now be updated manually by explicity setting its 'timeOffset'
- (void)animationDidStart:(CAAnimation *)animation
{
    _colorAnimLayer.speed = 0.0;
    _colorAnimLayer.timeOffset = [self.delegate currentValueOffset];
    
    _pathLayer.fillColor = [_colorAnimLayer.presentationLayer fillColor];
    [self.delegate colorDidUpdate:[self opaqueColor]];
}

#pragma mark - private

- (UIBezierPath *)pathForRect:(CGRect)rect withArrowOffset:(CGFloat)arrowOffset;
{
    if (CGRectEqualToRect(rect, CGRectZero)) return nil;
    
    rect = (CGRect){CGPointZero, rect.size}; // ensure origin is CGPointZero
    
    // Create rounded rect
    CGRect roundedRect = rect;
    roundedRect.size.height -= _arrowLength;
    UIBezierPath *popUpPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:_cornerRadius];
    
    // Create arrow path
    CGFloat maxX = CGRectGetMaxX(roundedRect); // prevent arrow from extending beyond this point
    CGFloat arrowTipX = CGRectGetMidX(rect) + arrowOffset;
    CGPoint tip = CGPointMake(arrowTipX, CGRectGetMaxY(rect));
    
    CGFloat arrowLength = CGRectGetHeight(roundedRect)/2.0;
    CGFloat x = arrowLength * tan(45.0 * M_PI/180); // x = half the length of the base of the arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:tip];
    [arrowPath addLineToPoint:CGPointMake(MAX(arrowTipX - x, 0), CGRectGetMaxY(roundedRect) - arrowLength)];
    [arrowPath addLineToPoint:CGPointMake(MIN(arrowTipX + x, maxX), CGRectGetMaxY(roundedRect) - arrowLength)];
    [arrowPath closePath];
    
    [popUpPath appendPath:arrowPath];
    
    return popUpPath;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect textRect = CGRectMake(self.bounds.origin.x,
                                 0,
                                 self.bounds.size.width, 13);
    _timeLabel.frame = textRect;
    CGRect imageReact = CGRectMake(self.bounds.origin.x+5, textRect.size.height+textRect.origin.y, self.bounds.size.width-10, 56);
    _imageView.frame = imageReact;
}

static UIColor* opaqueUIColorFromCGColor(CGColorRef col)
{
    if (col == NULL) return nil;
    
    const CGFloat *components = CGColorGetComponents(col);
    UIColor *color;
    if (CGColorGetNumberOfComponents(col) == 2) {
        color = [UIColor colorWithWhite:components[0] alpha:1.0];
    } else {
        color = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1.0];
    }
    return color;
}


@end



@implementation ZNKSlider

{
    NSNumberFormatter *_numberFormatter;
    UIColor *_popUpViewColor;
    NSArray *_keyTimes;
    CGFloat _valueRange;
}

#pragma mark - initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - public

- (void)setAutoAdjustTrackColor:(BOOL)autoAdjust
{
    if (_autoAdjustTrackColor == autoAdjust) return;
    
    _autoAdjustTrackColor = autoAdjust;
    
    // setMinimumTrackTintColor has been overridden to also set autoAdjustTrackColor to NO
    // therefore super's implementation must be called to set minimumTrackTintColor
    if (autoAdjust == NO) {
        super.minimumTrackTintColor = nil; // sets track to default blue color
    } else {
        super.minimumTrackTintColor = [self.popUpView opaqueColor];
    }
}

- (void)setText:(NSString *)text
{
    [self.popUpView setText:text];
}
- (void)setImage:(UIImage *)image
{
    [self.popUpView setImage:image];
}

// return the currently displayed color if possible, otherwise return _popUpViewColor
// if animated colors are set, the color will change each time the slider value changes
- (UIColor *)popUpViewColor
{
    return self.popUpView.color ?: _popUpViewColor;
}

- (void)setPopUpViewColor:(UIColor *)color
{
    _popUpViewColor = color;
    _popUpViewAnimatedColors = nil; // animated colors should be discarded
    [self.popUpView setColor:color];
    
    if (_autoAdjustTrackColor) {
        super.minimumTrackTintColor = [self.popUpView opaqueColor];
    }
}

- (void)setPopUpViewAnimatedColors:(NSArray *)colors
{
    [self setPopUpViewAnimatedColors:colors withPositions:nil];
}

// if 2 or more colors are present, set animated colors
// if only 1 color is present then call 'setPopUpViewColor:'
// if arg is nil then restore previous _popUpViewColor
- (void)setPopUpViewAnimatedColors:(NSArray *)colors withPositions:(NSArray *)positions
{
    if (positions) {
        NSAssert([colors count] == [positions count], @"popUpViewAnimatedColors and locations should contain the same number of items");
    }
    
    _popUpViewAnimatedColors = colors;
    _keyTimes = [self keyTimesFromSliderPositions:positions];
    
    if ([colors count] >= 2) {
        [self.popUpView setAnimatedColors:colors withKeyTimes:_keyTimes];
    } else {
        [self setPopUpViewColor:[colors lastObject] ?: _popUpViewColor];
    }
}

- (void)setPopUpViewCornerRadius:(CGFloat)radius
{
    self.popUpView.cornerRadius = radius;
}

- (CGFloat)popUpViewCornerRadius
{
    return self.popUpView.cornerRadius;
}

- (void)setPopUpViewArrowLength:(CGFloat)length
{
    self.popUpView.arrowLength = length;
}

- (CGFloat)popUpViewArrowLength
{
    return self.popUpView.arrowLength;
}

- (void)setPopUpViewWidthPaddingFactor:(CGFloat)factor
{
    self.popUpView.widthPaddingFactor = factor;
}

- (CGFloat)popUpViewWidthPaddingFactor
{
    return self.popUpView.widthPaddingFactor;
}

- (void)setPopUpViewHeightPaddingFactor:(CGFloat)factor
{
    self.popUpView.heightPaddingFactor = factor;
}

- (CGFloat)popUpViewHeightPaddingFactor
{
    return self.popUpView.heightPaddingFactor;
}

// when either the min/max value or number formatter changes, recalculate the popUpView width
- (void)setMaximumValue:(float)maximumValue
{
    [super setMaximumValue:maximumValue];
    _valueRange = self.maximumValue - self.minimumValue;
}

- (void)setMinimumValue:(float)minimumValue
{
    [super setMinimumValue:minimumValue];
    _valueRange = self.maximumValue - self.minimumValue;
}

- (void)showPopUpViewAnimated:(BOOL)animated
{
    self.popUpViewAlwaysOn = YES;
    [self _showPopUpViewAnimated:animated];
}

- (void)hidePopUpViewAnimated:(BOOL)animated
{
    self.popUpViewAlwaysOn = NO;
    [self _hidePopUpViewAnimated:animated];
}

#pragma mark - ASValuePopUpViewDelegate

- (void)colorDidUpdate:(UIColor *)opaqueColor
{
    super.minimumTrackTintColor = opaqueColor;
}

// returns the current offset of UISlider value in the range 0.0 – 1.0
- (CGFloat)currentValueOffset
{
    return (self.value - self.minimumValue) / _valueRange;
}

#pragma mark - private

- (void)setup
{
    _autoAdjustTrackColor = YES;
    _valueRange = self.maximumValue - self.minimumValue;
    _popUpViewAlwaysOn = NO;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    _numberFormatter = formatter;
    
    self.popUpView = [[ZNKValuePopUpView alloc] initWithFrame:CGRectZero];
    self.popUpViewColor = [UIColor colorWithHue:0.6 saturation:0.6 brightness:0.5 alpha:0.8];
    
    self.popUpView.alpha = 0.0;
    self.popUpView.delegate = self;
    [self addSubview:self.popUpView];
    
}

// ensure animation restarts if app is closed then becomes active again
- (void)didBecomeActiveNotification:(NSNotification *)note
{
    if (self.popUpViewAnimatedColors) {
        [self.popUpView setAnimatedColors:_popUpViewAnimatedColors withKeyTimes:_keyTimes];
    }
}

- (void)updatePopUpView
{
    CGSize popUpViewSize = CGSizeMake(100, 56 + self.popUpViewArrowLength + 18);
    
    // calculate the popUpView frame
    CGRect thumbRect = [self thumbRect];
    CGFloat thumbW = thumbRect.size.width;
    CGFloat thumbH = thumbRect.size.height;
    
    CGRect popUpRect = CGRectInset(thumbRect, (thumbW - popUpViewSize.width)/2, (thumbH - popUpViewSize.height)/2);
    popUpRect.origin.y = thumbRect.origin.y - popUpViewSize.height;
    
    // determine if popUpRect extends beyond the frame of the progress view
    // if so adjust frame and set the center offset of the PopUpView's arrow
    CGFloat minOffsetX = CGRectGetMinX(popUpRect);
    CGFloat maxOffsetX = CGRectGetMaxX(popUpRect) - CGRectGetWidth(self.bounds);
    
    CGFloat offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0);
    popUpRect.origin.x -= offset;
    
    [self.popUpView setFrame:popUpRect arrowOffset:offset];
    
}

// takes an array of NSNumbers in the range self.minimumValue - self.maximumValue
// returns an array of NSNumbers in the range 0.0 - 1.0
- (NSArray *)keyTimesFromSliderPositions:(NSArray *)positions
{
    if (!positions) return nil;
    
    NSMutableArray *keyTimes = [NSMutableArray array];
    for (NSNumber *num in [positions sortedArrayUsingSelector:@selector(compare:)]) {
        [keyTimes addObject:@((num.floatValue - self.minimumValue) / _valueRange)];
    }
    return keyTimes;
}

- (CGRect)thumbRect
{
    return [self thumbRectForBounds:self.bounds
                          trackRect:[self trackRectForBounds:self.bounds]
                              value:self.value];
}

- (void)_showPopUpViewAnimated:(BOOL)animated
{
    if (self.delegate) [self.delegate sliderWillDisplayPopUpView:self];
    [self.popUpView showAnimated:animated];
}

- (void)_hidePopUpViewAnimated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(sliderWillHidePopUpView:)]) {
        [self.delegate sliderWillHidePopUpView:self];
    }
    [self.popUpView hideAnimated:animated completionBlock:^{
        if ([self.delegate respondsToSelector:@selector(sliderDidHidePopUpView:)]) {
            [self.delegate sliderDidHidePopUpView:self];
        }
    }];
}

#pragma mark - subclassed

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self updatePopUpView];
}

- (void)didMoveToWindow
{
    if (!self.window) { // removed from window - cancel notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else { // added to window - register notifications
        
        if (self.popUpViewAnimatedColors) { // restart color animation if needed
            [self.popUpView setAnimatedColors:_popUpViewAnimatedColors withKeyTimes:_keyTimes];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
}

- (void)setValue:(float)value
{
    [super setValue:value];
    [self.popUpView setAnimationOffset:[self currentValueOffset] returnColor:^(UIColor *opaqueReturnColor) {
        super.minimumTrackTintColor = opaqueReturnColor;
    }];
}

- (void)setValue:(float)value animated:(BOOL)animated
{
    if (animated) {
        [self.popUpView animateBlock:^(CFTimeInterval duration) {
            [UIView animateWithDuration:duration animations:^{
                [super setValue:value animated:animated];
                [self.popUpView setAnimationOffset:[self currentValueOffset] returnColor:^(UIColor *opaqueReturnColor) {
                    super.minimumTrackTintColor = opaqueReturnColor;
                }];
                [self layoutIfNeeded];
            }];
        }];
    } else {
        [super setValue:value animated:animated];
    }
}

- (void)setMinimumTrackTintColor:(UIColor *)color
{
    self.autoAdjustTrackColor = NO; // if a custom value is set then prevent auto coloring
    [super setMinimumTrackTintColor:color];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
    if (begin && !self.popUpViewAlwaysOn) [self _showPopUpViewAnimated:NO];
    return begin;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL continueTrack = [super continueTrackingWithTouch:touch withEvent:event];
    if (continueTrack) {
        [self.popUpView setAnimationOffset:[self currentValueOffset] returnColor:^(UIColor *opaqueReturnColor) {
            super.minimumTrackTintColor = opaqueReturnColor;
        }];
    }
    return continueTrack;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
    if (self.popUpViewAlwaysOn == NO) [self _hidePopUpViewAnimated:NO];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    if (self.popUpViewAlwaysOn == NO) [self _hidePopUpViewAnimated:NO];
}


@end
