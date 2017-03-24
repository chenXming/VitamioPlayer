//
//  VideoViewController.m
//  Vitamio_Player
//
//  Created by 陈小明 on 2017/3/24.
//  Copyright © 2017年 陈小明. All rights reserved.
//

#import "VideoViewController.h"
#import "CXM_VitamioPlayer.h"


@interface VideoViewController ()
{
    CXM_VitamioPlayer *videoView;
    
}
@end

@implementation VideoViewController

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    [videoView stopMediaPlayer];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"播放页面";
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    videoView = [[CXM_VitamioPlayer alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH,210)];
    videoView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:videoView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
