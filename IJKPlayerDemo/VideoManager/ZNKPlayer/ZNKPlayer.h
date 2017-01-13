//
//  ZNKPlayer.h
//  IJKPlayerDemo
//
//  Created by HuangSam on 2017/1/11.
//  Copyright © 2017年 qx_mjn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeResolutionBlock)(UIButton *button);
typedef void(^SliderTapBlock)(CGFloat value);
// 返回按钮的block
typedef void(^ZNKPlayerBackCallBack)(void);
// 下载按钮的回调
typedef void(^ZNKDownloadCallBack)(NSString *urlStr);

//视频加载失败的回调
typedef void(^ZNKFailedToCallVideo)();

// playerLayer的填充模式（默认：等比例填充，直到一个维度到达区域边界）
typedef NS_ENUM(NSInteger, ZNKPlayerLayerGravity) {
    ZNKPlayerLayerGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
    ZNKPlayerLayerGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
    ZNKPlayerLayerGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
};

typedef NS_ENUM(NSInteger, ZNKPlayerScalingMode) {
    ZNKPlayerScalingModeNone,       // No scaling
    ZNKPlayerScalingModeAspectFit,  // Uniform scale until one dimension fits
    ZNKPlayerScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    ZNKPlayerScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds
};

typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

// 播放器的几种状态
typedef NS_ENUM(NSInteger, ZNKPlayerPlaybackState) {
    ZNKPlayerStateStopped,     // 播放停止
    ZNKPlayerStatePlaying,  // 播放中
    ZNKPlayerStateInterrupted,    // 播放中断
    ZNKPlayerStateSeekingForward,    // 快进
    ZNKPlayerStateSeekingBackward      // 后退
};

typedef NS_ENUM(NSInteger, ZNKPlayerFinishReason) {
    ZNKPlayerFinishReasonPlaybackEnded,
    ZNKPlayerFinishReasonPlaybackError,
    ZNKPlayerFinishReasonUserExited
};

typedef NS_OPTIONS(NSUInteger, ZNKPlayerLoadState) {
    ZNKPlayerLoadStateUnknown        = 0,
    ZNKPlayerLoadStatePlayable       = 1 << 0,
    ZNKPlayerLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    ZNKPlayerLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
};

typedef NS_ENUM(NSInteger, ZNKPlayerTimeOption) {
    ZNKPlayerTimeOptionNearestKeyFrame,
    ZNKPlayerTimeOptionExact
};

@protocol ZNKValuePoUpViewDelegate <NSObject>
- (CGFloat)currentValueOffset; //expects value in the range 0.0 - 1.0
- (void)colorDidUpdate:(UIColor *)opaqueColor;
@end

@class ZNKPlayerControlView;
@class ZNKSlider;
@protocol ZNKSliderDelegate <NSObject>

- (void)sliderWillDisplayPopUpView:(ZNKSlider *)slider;

@optional
- (void)sliderWillHidePopUpView:(ZNKSlider *)slider;
- (void)sliderDidHidePopUpView:(ZNKSlider *)slider;

@end

@interface ZNKPlayer : UIView
/** 视频URL */
@property (nonatomic, strong) NSURL                *videoURL;
/** 视频标题 */
@property (nonatomic, strong) NSString             *title;
/** 视频URL的数组 */
@property (nonatomic, strong) NSArray              *videoURLArray;
/** 返回按钮Block */
@property (nonatomic, copy  ) ZNKPlayerBackCallBack goBackBlock;
//视频加载失败的回调
@property (nonatomic, copy) ZNKFailedToCallVideo failedCallBlock;
//判断返回
@property (nonatomic, assign)BOOL isGoBackFull;//no全屏的时候直接退出 yes保持不变
@property (nonatomic, copy  ) ZNKDownloadCallBack   downloadBlock;
/** 设置playerLayer的填充模式 */
@property (nonatomic, assign) ZNKPlayerLayerGravity playerLayerGravity;
/** 是否有下载功能(默认是关闭) */
@property (nonatomic, assign) BOOL                 hasDownload;
/** 切换分辨率传的字典(key:分辨率名称，value：分辨率url) */
@property (nonatomic, strong) NSDictionary         *resolutionDic;
/** 从xx秒开始播放视频跳转 */
@property (nonatomic, assign) NSInteger            seekTime;
/** 播放前占位图片的名称，不设置就显示默认占位图（需要在设置视频URL之前设置） */
@property (nonatomic, copy  ) NSString             *placeholderImageName;
/** 控制层View */
@property (nonatomic, readonly) ZNKPlayerControlView    *controlView;
//add 当前时长
@property (nonatomic,assign)NSInteger currentPlayTime;
/** 是否被用户暂停 */
@property (nonatomic, assign, readonly) BOOL       isPauseByUser;
//用于判断是否开启手势快进快退,默认是YES
@property (nonatomic, assign)BOOL isPanFastForward;
/** 配置 */
@property (nonatomic, strong) NSDictionary          *options;
/** 是否隐藏返回按钮 */
@property (nonatomic, assign) BOOL                  isHideBackBtn; // new add
/** 是否显示controlView*/
@property (nonatomic, assign) BOOL                  isHideControlView;
/** 当前播放的时间 */
@property (nonatomic, assign, readonly)  CGFloat    currentTime;
/** 总时长 */
@property (nonatomic, assign, readonly)  CGFloat    totalTime;
/** 总时长帧数 */
@property (nonatomic, assign, readonly)  CGFloat    totalDuRation;
/** 总时长频率 */
@property (nonatomic, assign, readonly)  CGFloat    totalTimescale;
/** 音量 */
@property (nonatomic, assign)  CGFloat              volume;
/** 是否为全屏 */
@property (nonatomic, assign) BOOL                  isFullScreen;

@property(nonatomic, assign) ZNKPlayerScalingMode scalingMode;
@property(nonatomic, readonly)  ZNKPlayerPlaybackState playbackState;
@property(nonatomic, readonly)  ZNKPlayerLoadState loadState;

/**
 *  自动播放，默认不自动播放
 */
- (void)autoPlayTheVideo;

/**
 *  取消延时隐藏controlView的方法,在ViewController的delloc方法中调用
 *  用于解决：刚打开视频播放器，就关闭该页面，maskView的延时隐藏还未执行。
 */
- (void)cancelAutoFadeOutControlBar;

/**
 *  单例，用于列表cell上多个视频
 *
 *  @return ZFPlayer
 */
+ (instancetype)sharedPlayerView;

/**
 *  player添加到cell上
 *
 *  @param imageView 添加player的cellImageView
 */
- (void)addPlayerToCellImageView:(UIImageView *)imageView;

/**
 *  重置player
 */
- (void)resetPlayer;

/**
 *  在当前页面，设置新的Player的URL调用此方法
 */
- (void)resetToPlayNewURL;

/**
 *  播放
 */
- (void)play;

/**
 * 暂停
 */
- (void)pause;

/** 设置URL的setter方法 */
- (void)setVideoURL:(NSURL *)videoURL;

/**
 *  用于cell上播放player
 *
 *  @param videoURL  视频的URL
 *  @param tableView tableView
 *  @param indexPath indexPath
 *  @param tag ImageViewTag
 */
- (void)setVideoURL:(NSURL *)videoURL
      withTableView:(UITableView *)tableView
        AtIndexPath:(NSIndexPath *)indexPath
   withImageViewTag:(NSInteger)tag;



- (id)initWithContentURL:(NSURL *)aUrl withOptions:(NSDictionary *)options withSuperView:(UIView *)videoView;

- (void)prepareToPlay;
- (void)autoToplay;
- (void)stop;
- (BOOL)isPlaying;
- (void)setPauseInBackground:(BOOL)pause;
-(void)teadownPlayer;
- (void)gotoFull;
/**销毁视图**/
- (void)gotoDeallocSelf;
/**移除视图**/
- (void)gotoRemoveSelf;
/**添加视图**/
- (void)gotoShowInView:(UIView *)view withFrame:(CGRect)rect;



@end

@interface ZNKPlayerControlView : UIView
/** 标题 */
@property (nonatomic, strong, readonly) UILabel                 *titleLabel;
/** 开始播放按钮 */
@property (nonatomic, strong, readonly) UIButton                *startBtn;
/** 当前播放时长label */
@property (nonatomic, strong, readonly) UILabel                 *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong, readonly) UILabel                 *totalTimeLabel;
/** 缓冲进度条 */
@property (nonatomic, strong, readonly) UIProgressView          *progressView;
/** 滑杆 */
@property (nonatomic, strong, readonly) ZNKSlider               *videoSlider;
/** 全屏按钮 */
@property (nonatomic, strong, readonly) UIButton                *fullScreenBtn;
/** 锁定屏幕方向按钮 */
@property (nonatomic, strong, readonly) UIButton                *lockBtn;
/** 快进快退label */
@property (nonatomic, strong, readonly) UILabel                 *horizontalLabel;
/** 系统菊花 */
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activity;
/** 返回按钮*/
@property (nonatomic, strong, readonly) UIButton                *backBtn;
/** 重播按钮 */
@property (nonatomic, strong, readonly) UIButton                *repeatBtn;
/** bottomView*/
@property (nonatomic, strong, readonly) UIImageView             *bottomImageView;
/** topView */
@property (nonatomic, strong, readonly) UIImageView             *topImageView;
/** 缓存按钮 */
@property (nonatomic, strong, readonly) UIButton                *downLoadBtn;
/** 切换分辨率按钮 */
@property (nonatomic, strong, readonly) UIButton                *resolutionBtn;
/** 播放按钮 */
@property (nonatomic, strong, readonly) UIButton                *playeBtn;
/** 分辨率的名称 */
@property (nonatomic, strong) NSArray                           *resolutionArray;
/** 切换分辨率的block */
@property (nonatomic, copy  ) ChangeResolutionBlock             resolutionBlock;
/** slidertap事件Block */
@property (nonatomic, copy  ) SliderTapBlock                    tapBlock;

/** 重置ControlView */
- (void)resetControlView;
/** 切换分辨率时候调用此方法*/
- (void)resetControlViewForResolution;
/** 显示top、bottom、lockBtn*/
- (void)showControlView;
/** 隐藏top、bottom、lockBtn*/
- (void)hideControlView;
@end

@interface ZNKBrightnessView : UIView
/** 调用单例记录播放状态是否锁定屏幕方向*/
@property (nonatomic, assign) BOOL     isLockScreen;
/** cell上添加player时候，不允许横屏,只运行竖屏状态状态*/
@property (nonatomic, assign) BOOL     isAllowLandscape;

+ (instancetype)sharedBrightnessView;
@end


@interface ZNKValuePopUpView : UIView
@property (weak, nonatomic) id <ZNKValuePoUpViewDelegate> delegate;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat arrowLength;
@property (nonatomic) CGFloat widthPaddingFactor;
@property (nonatomic) CGFloat heightPaddingFactor;

- (UIColor *)color;
- (void)setColor:(UIColor *)color;
- (UIColor *)opaqueColor;

- (void)setText:(NSString *)text;
- (void)setImage:(UIImage *)image;

- (void)setAnimatedColors:(NSArray *)animatedColors withKeyTimes:(NSArray *)keyTimes;

- (void)setAnimationOffset:(CGFloat)animOffset returnColor:(void (^)(UIColor *opaqueReturnColor))block;

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset;

- (void)animateBlock:(void (^)(CFTimeInterval duration))block;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)())block;
@end

@interface ZNKSlider : UISlider

// present the popUpView manually, without touch event.
- (void)showPopUpViewAnimated:(BOOL)animated;
// the popUpView will not hide again until you call 'hidePopUpViewAnimated:'
- (void)hidePopUpViewAnimated:(BOOL)animated;

// setting the value of 'popUpViewColor' overrides 'popUpViewAnimatedColors' and vice versa
// the return value of 'popUpViewColor' is the currently displayed value
// this will vary if 'popUpViewAnimatedColors' is set (see below)
@property (strong, nonatomic) UIColor *popUpViewColor;

// pass an array of 2 or more UIColors to animate the color change as the slider moves
@property (strong, nonatomic) NSArray *popUpViewAnimatedColors;

// the above @property distributes the colors evenly across the slider
// to specify the exact position of colors on the slider scale, pass an NSArray of NSNumbers
- (void)setPopUpViewAnimatedColors:(NSArray *)popUpViewAnimatedColors withPositions:(NSArray *)positions;

@property (nonatomic, readonly) ZNKValuePopUpView *popUpView;
// cornerRadius of the popUpView, default is 4.0
@property (nonatomic) CGFloat popUpViewCornerRadius;

// arrow height of the popUpView, default is 13.0
@property (nonatomic) CGFloat popUpViewArrowLength;
// width padding factor of the popUpView, default is 1.15
@property (nonatomic) CGFloat popUpViewWidthPaddingFactor;
// height padding factor of the popUpView, default is 1.1
@property (nonatomic) CGFloat popUpViewHeightPaddingFactor;

// changes the left handside of the UISlider track to match current popUpView color
// the track color alpha is always set to 1.0, even if popUpView color is less than 1.0
@property (nonatomic) BOOL autoAdjustTrackColor; // (default is YES)

// delegate is only needed when used with a TableView or CollectionView - see below
@property (weak, nonatomic) id<ZNKSliderDelegate> delegate;
/** 设置时间 */
- (void)setText:(NSString *)text;
/** 设置预览图 */
- (void)setImage:(UIImage *)image;


@end
