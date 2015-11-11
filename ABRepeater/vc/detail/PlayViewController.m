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
}

- (void)playRecord{
    self.myPlaying = YES;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [self.myPlayer play];
}

- (void)onProgress{
    [self.myProcess setProgress:(self.myPlayer.currentTime / self.myPlayer.duration) animated:NO];
    [self showCurrentTime];
}

- (void)showCurrentTime{
    int time = self.myPlayer.currentTime;
    self.myStartLabel.text = [NSString stringWithFormat:@"%20d:%02d", time / 60, time % 60];
    time = self.myPlayer.duration;
    self.myEndLabel.text = [NSString stringWithFormat:@"%02d:%02d", time / 60, time % 60];
}
#pragma mark - delegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"play end");
    self.myPlaying = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    NSLog(@"%@", [error description]);
}


#pragma mark - notify

@end
