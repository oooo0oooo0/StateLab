//
//  ViewController.m
//  StateLab
//
//  Created by 张光发 on 15/11/29.
//  Copyright © 2015年 张光发. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(strong,nonatomic) UILabel *label;
@end

@implementation ViewController
{
    BOOL animate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds=self.view.bounds;
    CGRect labelFrame=CGRectMake(bounds.origin.x, CGRectGetMidY(bounds)-50, bounds.size.width, 100);
    self.label=[[UILabel alloc] initWithFrame:labelFrame];
    self.label.font=[UIFont fontWithName:@"Helvetica" size:70];
    self.label.text=@"大风车";
    self.label.textAlignment=NSTextAlignmentCenter;
    self.label.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.label];
    //开始动画
    //在通知回调中启动动画
    //[self rotateLabelDown];
    
    //接收通知
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)applicationWillResignActive
{
    NSLog(@"VC:%@",NSStringFromSelector(_cmd));
    animate=NO;
}

-(void)applicationDidBecomeActive
{
    NSLog(@"VC:%@",NSStringFromSelector(_cmd));
    animate=YES;
    [self rotateLabelDown];
}

//文字倒置动画
-(void)rotateLabelDown
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         self.label.transform=CGAffineTransformMakeRotation(M_PI);
                     }
                     completion:^(BOOL finished){
                         if(animate){
                             [self rotateLabelUp];
                         }
                     }];
}

//文字正置动画
-(void)rotateLabelUp
{
    [UIView animateWithDuration:1.5
                     animations:^{self.label.transform=CGAffineTransformMakeRotation(0);}
                     completion:^(BOOL finished){
                         if (animate) {
                             [self rotateLabelDown];
                         }
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
