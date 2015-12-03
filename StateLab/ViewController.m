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
@property(strong,nonatomic) UIImage *smiley;
@property(strong,nonatomic) UIImageView *smileyView;
@property(strong,nonatomic) UISegmentedControl *segementControl;
@end

@implementation ViewController
{
    BOOL animate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds=self.view.bounds;
    CGRect labelFrame=CGRectMake(bounds.origin.x, CGRectGetMidY(bounds)-25, bounds.size.width, 100);
    self.label=[[UILabel alloc] initWithFrame:labelFrame];
    self.label.font=[UIFont fontWithName:@"Helvetica" size:70];
    self.label.text=@"大风车";
    self.label.textAlignment=NSTextAlignmentCenter;
    self.label.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.label];
    
    CGRect smilyFram=CGRectMake(CGRectGetMaxX(bounds)/2-42, CGRectGetMaxY(bounds)/2-132, 84, 84);
    self.smileyView=[[UIImageView alloc] initWithFrame:smilyFram];
    self.smileyView.contentMode=UIViewContentModeCenter;
    NSString *smileyPath=[[NSBundle mainBundle] pathForResource:@"smiley" ofType:@"png"];
    self.smiley=[UIImage imageWithContentsOfFile:smileyPath];
    self.smileyView.image=self.smiley;
    [self.view addSubview:self.smileyView];
    
    self.segementControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"one",@"two",@"three",@"Four", nil]];
    self.segementControl.frame=CGRectMake(bounds.origin.x+20, 50, bounds.size.width-40, 30);
    [self.view addSubview:self.segementControl];
    
    //首先尝试读取用户上次点击的分段控件的值
    //如果读取成功，就恢复为上次点击的值
    NSNumber *indexNumber=[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedIndex"];
    if (indexNumber) {
        NSInteger selectedIndex=[indexNumber intValue];
        self.segementControl.selectedSegmentIndex=selectedIndex;
    }
    
    //开始动画
    //在通知回调中启动动画
    //[self rotateLabelDown];
    
    //接收通知
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    
    //注册不活跃通知
    [center addObserver:self
               selector:@selector(applicationWillResignActive)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    //注册活跃前通知
    [center addObserver:self
               selector:@selector(applicationDidBecomeActive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    
    //注册后台通知
    [center addObserver:self
               selector:@selector(applicationDidEnterBackground)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    //注册将要进入前台通知
    [center addObserver:self
               selector:@selector(applicationWillEnterForground)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
}

//不活跃通知回调
//设置动画标识为禁止动画
-(void)applicationWillResignActive
{
    NSLog(@"VC:%@",NSStringFromSelector(_cmd));
    animate=NO;
}
//活跃前通知回调
//设置动画标识为可以开始
-(void)applicationDidBecomeActive
{
    NSLog(@"VC:%@",NSStringFromSelector(_cmd));
    animate=YES;
    [self rotateLabelDown];
}

//后台通知回调
//释放图片资源
-(void)applicationDidEnterBackground
{
    NSLog(@"VC:%@",NSStringFromSelector(_cmd));
    
    UIApplication *app=[UIApplication sharedApplication];
    
    
    __block UIBackgroundTaskIdentifier taskId;
    //这个地方没太明白
    taskId=[app beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"后台任务超时，并且被终止");
        [app endBackgroundTask:taskId];
    }];
    
    //申请失败
    if (taskId==UIBackgroundTaskInvalid) {
        NSLog(@"申请后台任务失败");
        return;
    }
    //真正进入后台任务
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"进入后台任务,共获得%f秒",app.backgroundTimeRemaining);
        
        self.smiley=nil;
        self.smileyView.image=nil;
        
        //进入后台时记录分段控件选择的值
        //在程序加载时读取
        NSInteger selectedIndex=self.segementControl.selectedSegmentIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"selectedIndex"];
        
        //模拟10秒任务
        [NSThread sleepForTimeInterval:10];
        
        NSLog(@"后台任务执行完成，剩余%f秒",app.backgroundTimeRemaining);
        [app endBackgroundTask:taskId];
    });
    
}

//将进入前台回调
//重新加载图片资源
-(void)applicationWillEnterForground
{
    NSLog(@"VC:%@",NSStringFromSelector(_cmd));
    NSString *smileyPath=[[NSBundle mainBundle] pathForResource:@"smiley" ofType:@"png"];
    self.smiley=[UIImage imageWithContentsOfFile:smileyPath];
    self.smileyView.image=self.smiley;
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

@end
