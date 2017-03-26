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
    //设置同步nstimer以及播放进度时间
    NSTimer* mSyncSeekTimer;
    long mDuration;
    long mCurPosition;
    
    //播放或暂停
    BOOL isPlay;
    //是否返回
    BOOL isBack;
    // 全凭按钮
    BOOL isFullScreen;
    //是否显示工具栏
    BOOL isShowToolBar;
    
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
// 是否正在拖拽
@property (nonatomic, assign) BOOL progressDragging;


@end

@implementation CXM_VitamioPlayer
// 视频播放地址
#define CXM_DefaultDownloadUrl   (@"http://app.1000phone.com/%E5%8D%83%E9%94%8BSwift%E8%A7%86%E9%A2%91%E6%95%99%E7%A8%8B-1.Swift%E8%AF%AD%E8%A8%80%E4%BB%8B%E7%BB%8D.mp4")
#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _frame = frame;
        
        [self initData];
        
        [self makeMianUI];
        
        //监听屏幕旋转方向
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenChangeDirection:) name:UIDeviceOrientationDidChangeNotification object:nil];
        

    }
    return self;
}
-(void)initData{
  
    appdelegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
    isFullScreen = NO;
    isPlay = YES;
    _progressDragging = NO;
    isShowToolBar = YES;
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
    
    UITapGestureRecognizer* tapVieoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideoViewEvent)];
    [self addGestureRecognizer:tapVieoGesture];
    
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
    //播放缓存时间label
    bufferTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2 + 20, SCREEN_WIDTH, 14)];
    [bufferTimeLabel setBackgroundColor:[UIColor clearColor]];
    [bufferTimeLabel setTextColor:RGBACOLOR(29, 187, 214, 1)];
    [bufferTimeLabel setFont:[UIFont systemFontOfSize:14]];
    [bufferTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:bufferTimeLabel];
    //视频播放activity
    videoActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
   // videoActivityIndicatorView.backgroundColor = [UIColor lightGrayColor];
    [videoActivityIndicatorView setCenter:self.center];
    [self addSubview:videoActivityIndicatorView];
    
    
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
    
    //进度条
    CGRect sliderFrame = CGRectMake(50, 13, SCREEN_WIDTH - 102, 2);
    videoProgressView = [[UIView alloc] initWithFrame:sliderFrame];
    [videoProgressView setBackgroundColor:RGBACOLOR(53, 53, 63, 1)];
    [videoToolbarView addSubview:videoProgressView];
    
    UIImage* sliderBallImage = [UIImage imageNamed:@"slider_ball"];
    UIImage* sliderLeftImage = [UIImage imageNamed:@"slider_left"];
    UIImage* sliderRightImage = [UIImage imageNamed:@"slider_right"];
    
    
    sliderFrame = CGRectMake(48, 1, SCREEN_WIDTH - 48 * 2, 25);
    videoSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    //  videoSlider.backgroundColor =[UIColor redColor];
    [videoSlider setThumbImage:sliderBallImage forState:UIControlStateNormal];
    [videoSlider setMinimumTrackImage:sliderLeftImage forState:UIControlStateNormal];
    [videoSlider setMaximumTrackImage:sliderRightImage forState:UIControlStateNormal];
    
    [videoSlider addTarget:self action:@selector(progressSliderUpAction:) forControlEvents:UIControlEventTouchCancel];
    [videoSlider addTarget:self action:@selector(progressSliderDownAction:) forControlEvents:UIControlEventTouchDown];
    [videoSlider addTarget:self action:@selector(progressSliderUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [videoSlider addTarget:self action:@selector(dragProgressSliderAction:) forControlEvents:UIControlEventValueChanged];
    [videoToolbarView addSubview:videoSlider];

    //时间值
    CGFloat currentY = 22;
    // 总时间
    allTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50 - 100, currentY, 100, 9)];
    [allTimeLabel setFont:[UIFont systemFontOfSize:9]];
    [allTimeLabel setBackgroundColor:[UIColor clearColor]];
    [allTimeLabel setTextColor: [UIColor whiteColor]];
    [allTimeLabel setText:@"00:00:00"];
    [allTimeLabel sizeToFit];
    
    CGRect allTimeFrame = allTimeLabel.frame;
    allTimeFrame.origin.x = SCREEN_WIDTH - 50 - allTimeLabel.frame.size.width;
    allTimeLabel.frame = allTimeFrame;
    [videoToolbarView addSubview:allTimeLabel];
    
    // 当前时间
    currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(allTimeFrame.origin.x - 45,currentY,100,9)];
    [currentTimeLabel setFont:[UIFont systemFontOfSize:9]];
    [currentTimeLabel setBackgroundColor:[UIColor clearColor]];
    [currentTimeLabel setTextColor:[UIColor whiteColor]];
    [currentTimeLabel setText:@"00:00:00/"];
    [videoToolbarView addSubview:currentTimeLabel];

    
}
- (void)tapVideoViewEvent{
    if (isShowToolBar) {
        //显示工具栏 进行隐藏
        videoToolbarView.hidden = YES;
        videoheadbarView.hidden =YES;
      //  backButton.hidden = YES;
        titleLabel.hidden=YES;
        isShowToolBar = NO;
        rateView.hidden=YES;
    }else{
        //工具栏被隐藏 显示出来
        videoToolbarView.hidden = NO;
        videoheadbarView.hidden =NO;
      //  backButton.hidden = NO;
        titleLabel.hidden=NO;
        isShowToolBar = YES;
        rateView.hidden=NO;
    }
}
#pragma mark - 缓冲label
- (void)startActivityWithMsg:(NSString *)msg{
    bufferTimeLabel.hidden = NO;
    bufferTimeLabel.text = msg;
    [videoActivityIndicatorView startAnimating];
}
- (void)stopActivity{
    bufferTimeLabel.hidden = YES;
    bufferTimeLabel.text = nil;
    [videoActivityIndicatorView stopAnimating];
}

#pragma mark - 开始于结束控制
-(void)startMediaPlayer{


    [mMplayer setDataSource:[NSURL URLWithString:CXM_DefaultDownloadUrl]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [mMplayer prepareAsync];

}
- (void)stopMediaPlayer{
    
    [mMplayer reset];
    isBack = YES;
    [mSyncSeekTimer invalidate];
    mSyncSeekTimer = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [self stopActivity];
    [mMplayer unSetupPlayer];
    [currentTimeLabel setText:@"00:00:00/"];
    videoSlider.value=0.0;
}
#pragma mark - Slider value
- (void)progressSliderUpAction:(id)sender{
    UISlider* sld = (UISlider*)sender;
    
    [mMplayer seekTo:(long)(sld.value * mDuration)];
}
- (void)progressSliderDownAction:(id)sender{
    self.progressDragging = NO;
}
- (void)dragProgressSliderAction:(id)sender{
    UISlider* sld = (UISlider*)sender;
    
    currentTimeLabel.text =[NSString stringWithFormat:@"%@/",[self timeToHumanString:(long)(sld.value * mDuration)]];
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
            [self stopActivity];
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
#pragma mark - 小屏与全屏 控制
- (void)makeFullScreen{
    NSLog(@"make full screen");
    
    isFullScreen = YES;

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
  
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
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
        
        bufferTimeLabel.frame = CGRectMake(0, self.frame.size.width / 2 + 20, SCREEN_HEIGHT, 14);
    }else{

        videoActivityIndicatorView.center = self.center;
        
        videoSlider.frame = CGRectMake(48, 1, SCREEN_WIDTH - 48 * 2, 25);
        
       bufferTimeLabel.frame = CGRectMake(0, self.frame.size.height / 2 + 20, SCREEN_WIDTH, 14);
    }
    
    UIImage* btnPinchImage = (isFullScreen == YES ? btnReduceImage : btnExpandImage);
    [pinchButton setImage:btnPinchImage forState:UIControlStateNormal];
    pinchButton.frame = CGRectMake(self.bounds.size.width - 15 - btnPinchImage.size.width, (videoToolbarHeight - btnPinchImage.size.height) / 2, btnPinchImage.size.width, btnPinchImage.size.height);
    CGRect sliderFrame;
    CGRect allTimeFrame = allTimeLabel.frame;
    if(isFullScreen==YES){
        sliderFrame = CGRectMake(50, 13, (isFullScreen == YES ? SCREEN_HEIGHT : SCREEN_WIDTH) - 50-280/2, 2);
        allTimeFrame.origin.x = SCREEN_HEIGHT - 140 - allTimeLabel.frame.size.width;
    }else{
        sliderFrame = CGRectMake(50, 13, (isFullScreen == YES ? SCREEN_HEIGHT : SCREEN_WIDTH) - 49*2, 2);
        allTimeFrame.origin.x = SCREEN_WIDTH - 50 - allTimeLabel.frame.size.width;
    }
    videoProgressView.frame = sliderFrame;
    videoToolbarView.frame = CGRectMake(0, self.bounds.size.height - videoToolbarHeight, self.bounds.size.width, videoToolbarHeight);
    videoheadbarView.frame = CGRectMake(0,0, self.bounds.size.width, videoToolbarHeight);
    
    currentTimeLabel.frame = CGRectMake(allTimeFrame.origin.x - 45,allTimeFrame.origin.y,100,9);
    allTimeLabel.frame = allTimeFrame;
   }
#pragma mark - 时间轮循
- (void)syncUIStatus{
    if (!self.progressDragging) {
        mCurPosition = [mMplayer getCurrentPosition];

        [videoSlider setValue:(float)mCurPosition/mDuration];
        
        currentTimeLabel.text =[NSString stringWithFormat:@"%@/",[self timeToHumanString:mCurPosition]];
        
        allTimeLabel.text = [self timeToHumanString:mDuration];
    }
}
#pragma mark - VitamioDelegate
- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg{
    //开始更新状态
//    [self stopActivity];
//    
    mDuration = [player getDuration];
    
    mSyncSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(syncUIStatus) userInfo:nil repeats:YES];
    
    [mMplayer setVideoFillMode:VMVideoFillModeStretch];
    
    [mMplayer start];
    
    [allTimeLabel setText:[self timeToHumanString:[player getDuration]]];
    
    playOrPauseButton.userInteractionEnabled =YES;
    isPlay =YES;
    [playOrPauseButton setImage:btnPauseImage forState:UIControlStateNormal];// 改变播放按钮图片
}
- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg{
    
    
    [self stopMediaPlayer];
}

- (void)mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
    player.decodingSchemeHint = VMDecodingSchemeSoftware;
    player.autoSwitchDecodingScheme = NO;
}
- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg{
    NSLog(@"VMediaPlayer Error = %@",arg);
    
    isPlay = NO;
    [player reset];
    [self clickPlayOrPauseButton];
}
- (void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg{
    
    [player pause];
    [self startActivityWithMsg:@"缓冲...0%"];
    self.progressDragging = YES;
    [playOrPauseButton setImage:btnPlayImage forState:UIControlStateNormal];
    playOrPauseButton.userInteractionEnabled=NO;
    isPlay=NO;
    //    NSLog(@"VMediaPlayer buffer start = %@",arg);
}
- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg{
    
    [player start];
    [self stopActivity];
    self.progressDragging = NO;
    [playOrPauseButton setImage:btnPauseImage forState:UIControlStateNormal];
    playOrPauseButton.userInteractionEnabled=YES;
    isPlay=YES;
}
- (void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg{
    // NSLog(@"VMediaPlayer buffer update = %@",arg);
    [self startActivityWithMsg:[NSString stringWithFormat:@"缓冲... %d%%",[((NSNumber *)arg) intValue]]];
}
- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg{
    
}
- (void)mediaPlayer:(VMediaPlayer *)player info:(id)arg{
    NSLog(@"VMediaPlayer info = %@",arg);
}
- (void)mediaPlayer:(VMediaPlayer *)player notSeekable:(id)arg{
    self.progressDragging = NO;
}
- (void)mediaPlayer:(VMediaPlayer *)player setupPlayerPreference:(id)arg{
    NSLog(@"VMediaPlayer setupPlayerPreference===");
    [player setVideoQuality:VMVideoQualityHigh];
    player.useCache = NO;
    
}
#pragma mark - 屏幕旋转（重力感应） 通知事件
-(void)screenChangeDirection:(NSNotification*)notify{
    
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    /*
     UIDeviceOrientationUnknown,
     UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
     UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
     UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
     UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
     UIDeviceOrientationFaceUp,              // Device oriented flat, face up
     UIDeviceOrientationFaceDown             // Device oriented flat, face down   */
    
    switch (orient)
    {
        case UIDeviceOrientationPortrait:{
            appdelegate.nav.navigationBarHidden = NO;

            [self makeSmallScreen];
            
        }
            NSLog(@"上");
            break;
        case UIDeviceOrientationLandscapeLeft:{
            
            //掩饰掉用
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerChangeScapeLeft) userInfo:nil repeats:NO];
            
        }
            NSLog(@"左");
            
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"下");
            
            break;
        case UIDeviceOrientationLandscapeRight:{
            //掩饰掉用
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerChangeScapeRight) userInfo:nil repeats:NO];
            
        }
            NSLog(@"右");
            
            break;
            
        default:
            break;
    }
}
-(void)timerChangeScapeLeft{
    
    isFullScreen = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    appdelegate.nav.navigationBarHidden = YES;

    [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    
    //获取全屏时的坐标
    [UIView animateWithDuration:0.35 animations:^{
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self resetToolBarAndSubViewFrame];
        titleLabel.frame =CGRectMake(50,12,SCREEN_HEIGHT-50,30);
        titleLabel.textAlignment =NSTextAlignmentCenter;
        
    }];
    
    [self.superview bringSubviewToFront:self];
    [mMplayer setVideoFillMode:VMVideoFillModeStretch];
    
}
-(void)timerChangeScapeRight{
    
    isFullScreen = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    appdelegate.nav.navigationBarHidden = YES;

    [self setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    
    //获取全屏时的坐标
    [UIView animateWithDuration:0.35 animations:^{
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self resetToolBarAndSubViewFrame];
        titleLabel.frame =CGRectMake(50,12,SCREEN_HEIGHT-50,30);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
    }];
    [self.superview bringSubviewToFront:self];
    [mMplayer setVideoFillMode:VMVideoFillModeStretch];
    
}

#pragma mark - 时间转换
-(NSString *)timeToHumanString:(unsigned long)ms
{
    unsigned long seconds, h, m, s;
    char buff[128] = { 0 };
    NSString *nsRet = nil;
    
    seconds = ms / 1000;
    h = seconds / 3600;
    m = (seconds - h * 3600) / 60;
    s = seconds - h * 3600 - m * 60;
    snprintf(buff, sizeof(buff), "%02ld:%02ld:%02ld", h, m, s);
    nsRet = [[NSString alloc] initWithCString:buff
                                     encoding:NSUTF8StringEncoding];
    return nsRet;
}

- (void)dealloc
{
   
    [mMplayer unSetupPlayer];
    
}

@end
