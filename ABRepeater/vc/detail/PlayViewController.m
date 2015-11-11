//
//  PlayViewController.m
//  ABRepeater
//
//  Created by 林伟池 on 15/11/11.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController ()
@property (nonatomic, strong) AVAudioPlayer* myPlayer;
@property (nonatomic) BOOL myPlaying;
@property (nonatomic, strong) NSTimer* myTimer;
@property (nonatomic, strong) Repeat* myRepeat;
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myPlaying = NO;
    [self prepareToPlay];
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onProgress) userInfo:nil repeats:YES];
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

#pragma mark - view init
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.myTimer invalidate];
}

#pragma mark - ibaction

- (IBAction)onPlay:(id)sender{
//    [self prepareToPlay];
    [self playRecord];
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
        if (self.myPlayer.currentTime > self.myRepeat.timeB) {
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
