//
//  PlayerViewController.m
//  Vitamio_Player
//
//  Created by 陈小明 on 2017/3/24.
//  Copyright © 2017年 陈小明. All rights reserved.
//

#import "PlayerViewController.h"
#import "VideoViewController.h"
#import "Vitamio.h"


@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"主页";
    [self initData];
    
}
-(void)initData{

    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    

    UIButton *playerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playerBtn setTitle:@"播放视频" forState:UIControlStateNormal];
    [playerBtn setBackgroundColor:[UIColor orangeColor]];
    playerBtn.frame = CGRectMake((self.view.frame.size.width - 150)/2,100, 150, 45);
    [playerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [playerBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:playerBtn];

}
-(void)playBtnClick{

    VideoViewController *videVc = [[VideoViewController alloc] init];
    
    [self.navigationController pushViewController:videVc animated:YES];

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
