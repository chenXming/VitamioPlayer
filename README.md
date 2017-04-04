# VitamioPlayer
iOS 基于第三方Vitamio视频播放开发的播放器。支持95%的视频格式，可播放本地与网络视频源 重力横屏、手势快进、左侧亮度、右侧音量控制等功能。
![](https://github.com/chenXming/VitamioPlayer/raw/master/VitamioPlayer.gif) <br> 

*使用CocoaPods集成Vitamio库见我的GitHub*:[VitamoSDK-iOS](https://github.com/chenXming/VitamioSDK-iOS)
***
 <br> *主要使用方法*：
```OC
//获取本地视频路径
NSString *docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
NSString *videoUrl = [NSString stringWithFormat:@"%@/%@", docDir, @"demo.mkv"];
/*
* 网络视频源 NSString *videoUrl = @"http://meta.video.qiyi.com/242/de25dc2b5d385a8e27304d1e6dcd1a35.m3u8"
*/
```
初始化视频播放器 使用类 VMediaPlayer 的类方法 +sharedInstance 获取播放器共享实例, 然后调用实例 方法 -setupPlayerWithCarrierView:withDelegate: 来注册使用播放器.
```OC
mMPayer = [VMediaPlayer sharedInstance];
[mMPayer setupPlayerWithCarrierView:self.view withDelegate:self];
```
  给播放器传入要播放的视频URL, 并告知其进行播放准备
  ```OC
  self.videoURL = [NSURL URLWithString:videoUrl];
  [mMPayer setDataSource:self.videoURL header:nil];
  [mMPayer prepareAsync];
  ```
   实现 VMediaPlayerDelegate 协议, 以获得'播放器准备完成'等通知
   ```
   // 当'播放器准备完成'时, 该协议方法被调用, 我们可以在此调用 [player start]
// 来开始音视频的播放.
- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    [player start];
}
// 当'该音视频播放完毕'时, 该协议方法被调用, 我们可以在此作一些播放器善后
// 操作, 如: 重置播放器, 准备播放下一个音视频等
- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    [player reset];
}
// 如果播放由于某某原因发生了错误, 导致无法正常播放, 该协议方法被调用, 参
// 数 arg 包含了错误原因.
- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    NSLog(@"NAL 1RRE &&&& VMediaPlayer Error: %@", arg);
}
```
当不再使用播放器时, 可以调用 -unSetupPlayer 实例方法来取消注册播放器.
```OC
[mMPayer unSetupPlayer];
```
Vitamio官方地址：[Vitamio](https://www.vitamio.org/Download) 觉得好用就给个star吧^_^
