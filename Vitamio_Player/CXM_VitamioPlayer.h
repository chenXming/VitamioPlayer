//
//  CXM_VitamioPlayer.h
//  Vitamio_Player
//
//  Created by 陈小明 on 2017/3/24.
//  Copyright © 2017年 陈小明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXM_VitamioPlayer : UIView

- (instancetype)initWithFrame:(CGRect)frame;
/*
 * 开始播放视频
 */
-(void)startMediaPlayer;
/*
 *结束播放
 */
-(void)stopMediaPlayer;


@end
