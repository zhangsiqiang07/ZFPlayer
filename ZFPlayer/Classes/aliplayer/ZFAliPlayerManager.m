//
//  ZFIJKPlayerManager.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFAliPlayerManager.h"
#if __has_include(<ZFPlayer/ZFPlayer.h>)
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFPlayerConst.h>
#else
#import "ZFPlayer.h"
#import "ZFPlayerConst.h"
#endif
#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)

@interface ZFAliPlayerManager ()<AVPDelegate>

@property (nonatomic, strong) AliPlayer *player;
@property (nonatomic, assign) CGFloat lastVolume;
@property (nonatomic, assign) BOOL isReadyToPlay;

@end

@implementation ZFAliPlayerManager
@synthesize view                           = _view;
@synthesize currentTime                    = _currentTime;
@synthesize totalTime                      = _totalTime;
@synthesize playerPlayTimeChanged          = _playerPlayTimeChanged;
@synthesize playerBufferTimeChanged        = _playerBufferTimeChanged;
@synthesize playerDidToEnd                 = _playerDidToEnd;
@synthesize bufferTime                     = _bufferTime;
@synthesize playState                      = _playState;
@synthesize loadState                      = _loadState;
@synthesize assetURL                       = _assetURL;
@synthesize playerPrepareToPlay            = _playerPrepareToPlay;
@synthesize playerReadyToPlay              = _playerReadyToPlay;
@synthesize playerPlayStateChanged         = _playerPlayStateChanged;
@synthesize playerLoadStateChanged         = _playerLoadStateChanged;
@synthesize seekTime                       = _seekTime;
@synthesize muted                          = _muted;
@synthesize volume                         = _volume;
@synthesize presentationSize               = _presentationSize;
@synthesize isPlaying                      = _isPlaying;
@synthesize rate                           = _rate;
@synthesize isPreparedToPlay               = _isPreparedToPlay;
@synthesize shouldAutoPlay                 = _shouldAutoPlay;
@synthesize scalingMode                    = _scalingMode;
@synthesize playerPlayFailed               = _playerPlayFailed;
@synthesize presentationSizeChanged        = _presentationSizeChanged;

- (void)dealloc {
    [self stop];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scalingMode = ZFPlayerScalingModeAspectFit;
        _shouldAutoPlay = YES;
    }
    return self;
}

- (void)prepareToPlay {
    if (!_assetURL) return;
    _isPreparedToPlay = YES;
    [self initializePlayer];
    if (self.shouldAutoPlay) {
        [self play];
    }
    self.loadState = ZFPlayerLoadStatePrepare;
    if (self.playerPrepareToPlay) self.playerPrepareToPlay(self, self.assetURL);
}

- (void)reloadPlayer {
    [self prepareToPlay];
}

- (void)play {
    [self.player prepare];
}

- (void)pause {
    [self.player pause];
    _isPlaying = NO;
    self.playState = ZFPlayerPlayStatePaused;
}

- (void)stop {
    [self removeMovieNotificationObservers];
    [self.player stop];
    self.presentationSize = CGSizeZero;
    _isPlaying = NO;
    _isPreparedToPlay = NO;
    self->_currentTime = 0;
    self->_totalTime = 0;
    self->_bufferTime = 0;
    self.isReadyToPlay = NO;
    self.playState = ZFPlayerPlayStatePlayStopped;
}

- (void)replay {
    @zf_weakify(self)
    [self seekToTime:0 completionHandler:^(BOOL finished) {
        @zf_strongify(self)
        if (finished) {
            [self play];
        }
    }];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    
}

- (UIImage *)thumbnailImageAtCurrentTime {
    return nil;
}

#pragma mark - private method

- (void)initializePlayer {

    self.player = [[AliPlayer alloc] init];
    self.player.delegate = self;
    self.player.autoPlay = self.shouldAutoPlay;
 
    self.view.playerView = self.player.playerView;
    self.scalingMode = self->_scalingMode;
    [self addPlayerNotificationObservers];
}

- (void)addPlayerNotificationObservers {
   
}

- (void)removeMovieNotificationObservers {
   
}

- (void)timerUpdate {
 
}

#pragma - notification

/// 播放完成
- (void)moviePlayBackFinish:(NSNotification *)notification {
  
}

// 准备开始播放了
- (void)mediaIsPreparedToPlayDidChange:(NSNotification *)notification {
    ZFPlayerLog(@"加载状态变成了已经缓存完成，如果设置了自动播放, 会自动播放");

    if (self.isPlaying) {
        [self play];
        self.muted = self.muted;
        if (self.seekTime > 0) {
            [self seekToTime:self.seekTime completionHandler:nil];
            self.seekTime = 0; // 滞空, 防止下次播放出错
            [self play];
        }
    }
    if (self.playerReadyToPlay) self.playerReadyToPlay(self, self.assetURL);
}


#pragma mark - 加载状态改变


/// 视频的尺寸变化了
- (void)sizeAvailableChange:(NSNotification *)notify {
  
    self.view.presentationSize = self.presentationSize;
    if (self.presentationSizeChanged) {
        self.presentationSizeChanged(self, self->_presentationSize);
    }
}

#pragma mark - getter

- (ZFPlayerView *)view {
    if (!_view) {
        _view = [[ZFPlayerView alloc] init];
    }
    return _view;
}

- (float)rate {
    return _rate == 0 ?1:_rate;
}



#pragma mark - setter

- (void)setPlayState:(ZFPlayerPlaybackState)playState {
    _playState = playState;
    if (self.playerPlayStateChanged) self.playerPlayStateChanged(self, playState);
}

- (void)setLoadState:(ZFPlayerLoadState)loadState {
    _loadState = loadState;
    if (self.playerLoadStateChanged) self.playerLoadStateChanged(self, loadState);
}

- (void)setAssetURL:(NSURL *)assetURL {
    if (self.player) [self stop];
    _assetURL = assetURL;
    [self prepareToPlay];
}

- (void)setRate:(float)rate {
    _rate = rate;
    [self.player setRate:rate];
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    self.player.muted = muted;
}

- (void)setScalingMode:(ZFPlayerScalingMode)scalingMode {
    _scalingMode = scalingMode;
    self.view.scalingMode = scalingMode;
    
}

- (void)setVolume:(float)volume {
    _volume = MIN(MAX(0, volume), 1);
    self.player.volume = _volume;
}


/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    // 提示错误，及stop播放
    self.playState = ZFPlayerPlayStatePlayFailed;
    if (self.playerPlayFailed) self.playerPlayFailed(self, errorModel);
}
/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType{
    switch(eventType){
        case AVPEventPrepareDone:{
            // 准备完成
            // 在player设置autoPlay为NO时，建议在准备完成回调中手动调用start。
            [self.player start];
           
            if (self.playerReadyToPlay) self.playerReadyToPlay(self, self.assetURL);
        }
            break;
        case AVPEventAutoPlayStart:
            // 自动播放开始事件
            
            break;
        case AVPEventFirstRenderedStart:
            // 首帧显示
            break;
        case AVPEventCompletion:
            // 播放完成
            break;
        case AVPEventLoadingStart:
            // 缓冲开始
            break;
        case AVPEventLoadingEnd:
            // 缓冲完成
            break;
        case AVPEventSeekEnd:
            // 跳转完成
            break;
        case AVPEventLoopingStart:
            // 循环播放开始
            break;
        default:
            break;
    }
}
/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 更新进度条
}
/**
 @brief 视频缓存位置回调
 @param player 播放器player指针
 @param position 视频当前缓存位置
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 更新缓冲进度
}
/**
 @brief 获取track信息回调
 @param player 播放器player指针
 @param info track流信息数组参考AVPTrackInfo
 */
- (void)onTrackReady:(AliPlayer*)player info:(NSArray<AVPTrackInfo*>*)info {
    // 获取多码率信息
}
/**
 @brief 字幕显示回调
 @param player 播放器player指针
 @param index 字幕显示的索引号
 @param subtitle 字幕显示的字符串
 */
- (void)onSubtitleShow:(AliPlayer*)player index:(int)index subtitle:(NSString *)subtitle {
    // 获取字幕进行显示
}
/**
 @brief 字幕隐藏回调
 @param player 播放器player指针
 @param index 字幕显示的索引号
 */
- (void)onSubtitleHide:(AliPlayer*)player index:(int)index {
    // 隐藏字幕
}
/**
 @brief 获取截图回调
 @param player 播放器player指针
 @param image 图像
 */
- (void)onCaptureScreen:(AliPlayer *)player image:(UIImage *)image {
    // 预览，保存截图
}
/**
 @brief track切换完成回调
 @param player 播放器player指针
 @param info 切换后的信息参考AVPTrackInfo
 */
- (void)onTrackChanged:(AliPlayer*)player info:(AVPTrackInfo*)info {
    // 切换码率结果通知
}

@end

#endif
