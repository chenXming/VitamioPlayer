//
//  CXM_VitamioPlayer.m
//  Vitamio_Player
//
//  Created by 陈小明 on 2017/3/24.
//  Copyright © 2017年 陈小明. All rights reserved.
//

#import "CXM_VitamioPlayer.h"
#import "Vitamio.h"
#import <MediaPlayer/MPVolumeView.h>// 音量控制
#import "AppDelegate.h"

@interface CXM_VitamioPlayer()<VMediaPlayerDelegate>
{

    
    CGRect _frame;
    //播放activity
    UIActivityIndicatorView* videoActivityIndicatorView;
    //缓存时间label
    UILabel* bufferTimeLabel;
    //视频 VMediaPlayer
    VMediaPlayer* mMplayer;
    //视频播放按钮
    UIImage* btnPlayImage;
    UIImage* btnPauseImage;
    UIButton* playOrPauseButton;
    UIButton* pinchButton;
    UIImage* btnExpandImage;
    UIImage* btnReduceImage;
    //视频播放进度条
    CGFloat videoToolbarHeight;
    UIView* videoToolbarView;
    UIView* videoheadbarView;
    UIView* videoProgressView;
    UISlider* videoSlider;
    //时间值
    UILabel* currentTimeLabel;
    UILabel* allTimeLabel;
    UILabel* titleLabel;// 标题
    
    //播放或暂停
    BOOL isPlay;
    //是否返回
    BOOL isBack;
    // 全凭按钮
    BOOL isFullScreen;

    MPVolumeView *volumeView ;// 不显示系统音量提示

    
    UIImageView *blightView;// 明暗提示图
    UIImageView *voiceView; // 音量提示图
    UIProgressView *blightPtogress; // 明暗提示
    UIProgressView *volumeProgress; // 音量提示
    //倍速调节按钮
    UIButton *rateBtn;
    UIView *rateView;
    
    AppDelegate *appdelegate;

}
@end

@implementation CXM_VitamioPlayer
// 视频播放地址
#define CXM_DefaultDownloadUrl   (@"http://app.1000phone.com/%E5%8D%83%E9%94%8BSwift%E8%A7%86%E9%A2%91%E6%95%99%E7%A8%8B-1.Swift%E8%AF%AD%E8%A8%80%E4%BB%8B%E7%BB%8D.mp4")
#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _frame = frame;
        
        [self initData];
        
        [self makeMianUI];
    }
    return self;
}
-(void)initData{
  
    appdelegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
    isFullScreen = NO;
    isPlay = YES;

}
-(void)makeMianUI{

    //添加视频
    mMplayer = [VMediaPlayer sharedInstance];
    [mMplayer setupPlayerWithCarrierView:self withDelegate:self];
    // 倍率播放
//    rateView =[[UIView alloc] initWithFrame:CGRectMake(SCREEN_HEIGHT-120,SCREEN_WIDTH-30,110/2,25)];
//    [rateView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
//    rateView.layer.masksToBounds=YES;
//    rateView.layer.cornerRadius=4.0f;
    [self addSubview:rateView];
  
    [self startMediaPlayer];
    
    [self makeVideoTool];

}
-(void)makeVideoTool{
  
    //视频上下工具条
    videoToolbarHeight = 35;
    videoToolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - videoToolbarHeight, SCREEN_WIDTH, videoToolbarHeight)];
    [videoToolbarView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    videoToolbarView.userInteractionEnabled =YES;
    [self addSubview:videoToolbarView];
    
    videoheadbarView=[[UIView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, videoToolbarHeight)];
    [videoheadbarView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    videoheadbarView.userInteractionEnabled =YES;
    [self addSubview:videoheadbarView];


    //添加视频播放按钮
    btnPlayImage = [UIImage imageNamed:@"btn_play"];
    btnPauseImage = [UIImage imageNamed:@"btn_pause"];
    playOrPauseButton = [[UIButton alloc] initWithFrame:CGRectMake(16, (videoToolbarHeight - btnPlayImage.size.height) / 2, btnPlayImage.size.width, btnPlayImage.size.height)];
    [playOrPauseButton setImage:btnPauseImage forState:UIControlStateNormal];
    [playOrPauseButton addTarget:self action:@selector(clickPlayOrPauseButton) forControlEvents:UIControlEventTouchUpInside];
    playOrPauseButton.userInteractionEnabled =YES;
    [videoToolbarView addSubview:playOrPauseButton];
    
    //全屏按钮
    btnExpandImage = [UIImage imageNamed:@"btn_pinch_expand"];
    btnReduceImage = [UIImage imageNamed:@"btn_pinch_shrink"];
    pinchButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - btnExpandImage.size.width, (videoToolbarHeight - btnExpandImage.size.height) / 2, btnExpandImage.size.width, btnExpandImage.size.height)];
    [pinchButton setImage:btnExpandImage forState:UIControlStateNormal];
    [pinchButton addTarget:self action:@selector(clickPinchButton:) forControlEvents:UIControlEventTouchUpInside];
    [videoToolbarView addSubview:pinchButton];
    
}
-(void)startMediaPlayer{


    [mMplayer setDataSource:[NSURL URLWithString:CXM_DefaultDownloadUrl]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [mMplayer prepareAsync];

}
- (void)stopMediaPlayer{
    
    [mMplayer reset];
    isBack = YES;
//    [mSyncSeekTimer invalidate];
//    mSyncSeekTimer = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [self stopActivity];
    [mMplayer unSetupPlayer];
//    [currentTimeLabel setText:@"00:00:00/"];
//    videoSlider.value=0.0;
}
#pragma mark- Click Event
- (void)clickPinchButton:(UIButton*)sender{
    NSLog(@"click pinch ");
    if (isFullScreen) {
        [self makeSmallScreen];
    }else{
        [self makeFullScreen];
    }
}
- (void)clickPlayOrPauseButton{
    
    if (isPlay) {
        //正在播放  暂停
        [playOrPauseButton setImage:btnPlayImage forState:UIControlStateNormal];
        if ([videoActivityIndicatorView isAnimating]) {
           // [self stopActivity];
        }
        
        [mMplayer pause];
        isPlay = NO;
        
    }else{
        //已暂停  开始播放
        [playOrPauseButton setImage:btnPauseImage forState:UIControlStateNormal];
        [mMplayer start];
        isPlay = YES;
    }
}
#pragma mark - 小屏与全屏
- (void)makeFullScreen{
    NSLog(@"make full screen");
    
    isFullScreen = YES;

   // [[UIApplication sharedApplication] setStatusBarHidden:YES];
  
    appdelegate.nav.navigationBarHidden = YES;
    
    [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    
    //获取全屏时的坐标
    [UIView animateWithDuration:0.35 animations:^{
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self resetToolBarAndSubViewFrame];
        titleLabel.frame =CGRectMake(30,8,SCREEN_HEIGHT-60,30);
        titleLabel.textAlignment =NSTextAlignmentCenter;
    }];
    [self.superview bringSubviewToFront:self];
    [mMplayer setVideoFillMode:VMVideoFillModeStretch];
    
}
- (void)makeSmallScreen{
    isFullScreen = NO;
    
  //  [[UIApplication sharedApplication] setStatusBarHidden:NO];
    appdelegate.nav.navigationBarHidden = NO;

    [self setTransform:CGAffineTransformMakeRotation(0)];
    
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = _frame;
        [self resetToolBarAndSubViewFrame];
        titleLabel.frame =CGRectMake(30,8,SCREEN_WIDTH-60,30);
        titleLabel.textAlignment =NSTextAlignmentCenter;
    }];
    
    [self.superview bringSubviewToFront:self];
    [mMplayer setVideoFillMode:VMVideoFillModeStretch];
    
}
// 重新设置各个控件的frame
- (void)resetToolBarAndSubViewFrame{

    if (isFullScreen) {

        videoActivityIndicatorView.center = CGPointMake(SCREEN_HEIGHT / 2, SCREEN_WIDTH / 2);
        
        videoSlider.frame = CGRectMake(48,1, SCREEN_HEIGHT - 48-280/2, 25);
        
      //  bufferTimeLabel.frame = CGRectMake(0, videoView.frame.size.width / 2 + 20, SCREEN_HEIGHT, 14);
    }else{

        videoActivityIndicatorView.center = self.center;
        
        videoSlider.frame = CGRectMake(48, 1, SCREEN_WIDTH - 48 * 2, 25);
        
      //  bufferTimeLabel.frame = CGRectMake(0, videoView.frame.size.height / 2 + 20, SCREEN_WIDTH, 14);
    }
    
    UIImage* btnPinchImage = (isFullScreen == YES ? btnReduceImage : btnExpandImage);
    [pinchButton setImage:btnPinchImage forState:UIControlStateNormal];
    pinchButton.frame = CGRectMake(self.bounds.size.width - 15 - btnPinchImage.size.width, (videoToolbarHeight - btnPinchImage.size.height) / 2, btnPinchImage.size.width, btnPinchImage.size.height);
    
    videoToolbarView.frame = CGRectMake(0, self.bounds.size.height - videoToolbarHeight, self.bounds.size.width, videoToolbarHeight);
    videoheadbarView.frame = CGRectMake(0,0, self.bounds.size.width, videoToolbarHeight);
}

#pragma mark - VitamioDelegate
- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg{
    //开始更新状态
//    [self stopActivity];
//    
//    mDuration = [player getDuration];
//    
//    mSyncSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(syncUIStatus) userInfo:nil repeats:YES];
    
    [mMplayer setVideoFillMode:VMVideoFillModeStretch];
    
    [mMplayer start];
    
//    [mMplayer seekTo:(long)(lastPlayTime * 1000)];
//    
//    NSLog(@"last play time === %d",lastPlayTime);
//    
//    videoEndImageView.hidden = YES;
//    
//    playOrPauseButton.userInteractionEnabled =YES;
//    isPlay =YES;
//    [playOrPauseButton setImage:btnPauseImage forState:UIControlStateNormal];// 改变播放按钮图片
}
- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg{
    
//    _isComplate=YES;
//    // 返回播放时间请求
//    [self makeCurrentTimerRequest];
    
    [self stopMediaPlayer];
//    videoEndImageView.hidden = NO;
}

- (void)mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
    player.decodingSchemeHint = VMDecodingSchemeSoftware;
    player.autoSwitchDecodingScheme = NO;
}

- (void)dealloc
{
   
    [mMplayer unSetupPlayer];
    
}

@end
