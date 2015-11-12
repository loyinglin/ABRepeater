//
//  PlayViewController.m
//  ABRepeater
//
//  Created by 林伟池 on 15/11/11.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import "PlayViewController.h"
#import "NSObject+LYUITipsView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayViewController ()
@property (nonatomic, strong) AVAudioPlayer*    myPlayer;
@property (nonatomic, strong) NSTimer*          myTimer;
@property (nonatomic, strong) Repeat*           myRepeat;

// state
@property (nonatomic) long                     myPlayRate;
@property (nonatomic) BOOL                      myPlayCycle;
@property (nonatomic) BOOL                      myPlaying;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myPlaying = NO;
    self.myPlayCycle = NO;
    self.myPlayRate = 10;
    [self.myVolumeSlider setValue:[AVAudioSession sharedInstance].outputVolume];
    
    self.myTitleText.text = self.myPlayRecord.title;
    
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(void *)[AVAudioSession sharedInstance]];
    
    [self addObserver:self forKeyPath:@"myPlayRate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self prepareToPlay];
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onProgress) userInfo:nil repeats:YES];
}

- (void)dealloc
{
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
    [self removeObserver:self forKeyPath:@"myPlayRate"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(context == (__bridge void *)[AVAudioSession sharedInstance]){
        float newValue = [[change objectForKey:@"new"] floatValue];
        float oldValue = [[change objectForKey:@"old"] floatValue];
        // TODO: 这里实现你的逻辑代码
        [self.myVolumeSlider setValue:newValue];
        NSLog(@"old -> new %.2f %.2f", oldValue, newValue);
    }
    else if([keyPath isEqualToString:@"myPlayRate"]){ //
//        self.myPlayRateLabel.text = [NSString stringWithFormat:@"%.1f", self.myPlayRate / 10.0];
//        self.myPlayer.rate = self.myPlayRate / 10.0;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - view init
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.myTimer invalidate];
}

#pragma mark - ibaction

- (IBAction)onForward:(id)sender{
    if (self.myPlayer.playing) {
        if (self.myPlayer.currentTime + 5 < self.myPlayer.duration) {
            self.myPlayer.currentTime += 5;
        }
        else{
            self.myPlayer.currentTime = self.myPlayer.duration;
        }
    }
}

- (IBAction)onBackward:(id)sender{
    
    if (self.myPlayer.playing) {
        if (self.myPlayer.currentTime - 5 > 0){
            self.myPlayer.currentTime -= 5;
        }
        else{
            self.myPlayer.currentTime = 0;
        }
    }
}


- (IBAction)onSlow:(id)sender{
    if (self.myPlayRate > 10) {
        self.myPlayRate -= 10;
    }
    else if (self.myPlayRate > 2){
        self.myPlayRate -= 2;
    }
    
    self.myPlayRateLabel.text = [NSString stringWithFormat:@"%.1f", self.myPlayRate / 10.0];
    self.myPlayer.rate = self.myPlayRate / 10.0;
}

- (IBAction)onFast:(id)sender{
    if (self.myPlayRate < 10) {
        
        self.myPlayRate += 2;
    }
    else if (self.myPlayRate < 50){
        self.myPlayRate += 10;
    }
    
    self.myPlayRateLabel.text = [NSString stringWithFormat:@"%.1f", self.myPlayRate / 10.0];
    self.myPlayer.rate = self.myPlayRate / 10.0;
}

- (IBAction)onPlayCycle:(UISwitch*)sender{
    self.myPlayCycle = sender.on;
    [self.myPlayer setNumberOfLoops:self.myPlayCycle ? -1 : 1];
}

- (IBAction)onSaveTitle:(id)sender{
    if (self.myTitleText.text.length > 0) {
        if ([self.myPlayRecord.title isEqualToString:self.myTitleText.text]) { // 文件名一样
            
        }
        else if([[DataModel instance] modifyTitleByRecord:self.myPlayRecord Title:self.myTitleText.text]){
            [self presentMessageTips:@"保存成功"];
        }
        else{
            [self presentMessageTips:@"保存失败\n请检查文件名"];
        }
    }
    else{
        [self presentMessageTips:@"文件名不能为空"];
    }
    [self.myTitleText resignFirstResponder];
}

- (IBAction)onVolume:(id)sender{
    
//    [self.myPlayer setVolume:self.myVolumeSlider.value];
//    return ;  设置的是player 的音量
    
    //设置的是系统音量 xia mian
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    // retrieve system volume
//    float systemVolume = volumeViewSlider.value;
    
    // change system volume, the value is between 0.0f and 1.0f
    [volumeViewSlider setValue:self.myVolumeSlider.value animated:NO];
    
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)onPlay:(id)sender{
//    [self prepareToPlay];
    [self playRecord];
}

- (IBAction)onPause:(id)sender{
    [self.myPlayer pause];
}

- (IBAction)onNext:(id)sender{
    self.myPlayRecord = [[DataModel instance] getNextRecordByRecord:self.myPlayRecord];
    [self prepareToPlay];
    if (self.myPlaying) {
        [self playRecord];
    }
}

- (IBAction)onLast:(id)sender{
    self.myPlayRecord = [[DataModel instance] getLastRecordByRecord:self.myPlayRecord];
    [self prepareToPlay];
    if (self.myPlaying) {
        [self playRecord];
    }
}

- (IBAction)onRepeat:(UIButton*)sender{
    if (!self.myPlaying) {
        return;
    }
    if (!self.myRepeat) { //进入repeat模式
        self.myRepeat = [Repeat new];
        self.myRepeat.timeA = self.myPlayer.currentTime;
        [sender setTitle:@"设置结束" forState:UIControlStateNormal];
    }
    else if (self.myRepeat.timeB){ //repeatB已经有了
        self.myRepeat = nil;
        [sender setTitle:@"A-B" forState:UIControlStateNormal];
    }
    else{ //设置b端
        self.myRepeat.timeB = self.myPlayer.currentTime;
        [sender setTitle:@"取消复读" forState:UIControlStateNormal];
    }
}
#pragma mark - ui

- (void)prepareToPlay{
    if (self.myPlayer) {
        [self.myPlayer stop];
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
        self.myPlayer = nil;
    }
    
    self.myPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.myPlayRecord.url error:nil];
    [self.myPlayer setDelegate:self];
    [self.myPlayer setEnableRate:YES];
    [self.myPlayer setRate:self.myPlayRate / 10.0];
    [self.myPlayer setVolume:0.5];
    if (self.myPlayCycle) {
        [self.myPlayer setNumberOfLoops:-1];
    }
    
    self.myRepeat = nil;
}

- (void)playRecord{
    self.myPlaying = YES;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [self.myPlayer play];
}

- (void)onProgress{
    if (self.myRepeat && self.myRepeat.timeB) { //复读模式中
        if (self.myPlayer.currentTime >= self.myRepeat.timeB) {
            self.myPlayer.currentTime = self.myRepeat.timeA;
        }
    }
    
    [self.myProcess setProgress:(self.myPlayer.currentTime / self.myPlayer.duration) animated:NO];
    [self showCurrentTime];
}

- (void)showCurrentTime{
    int time = self.myPlayer.currentTime;
    self.myStartLabel.text = [NSString stringWithFormat:@"%02d:%02d", time / 60, time % 60];
    time = self.myPlayer.duration;
    self.myEndLabel.text = [NSString stringWithFormat:@"%02d:%02d", time / 60, time % 60];
}

#pragma mark - delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"play end");
    self.myPlaying = NO;
    self.myRepeat = nil;
    [self.myRepeatButton setTitle:@"A-B" forState:UIControlStateNormal];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    NSLog(@"%@", [error description]);
}


#pragma mark - notify

@end
