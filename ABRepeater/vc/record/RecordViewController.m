//
//  RecordViewController.m
//  ABRepeater
//
//  Created by 林伟池 on 15/11/10.
//  Copyright © 2015年 林伟池. All rights reserved.
//
#import "DataModel.h"
#import "PlayViewController.h"
#import "RecordViewController.h"
#import "RecordViewCell.h"
#import "NSObject+LYUITipsView.h"

@interface RecordViewController ()
@property (nonatomic, strong) AVAudioRecorder* myRecorder;
@property (nonatomic, strong) Record* myPlayReocord;

@property (nonatomic) BOOL mySave;
@property (nonatomic) BOOL myTouchRecord; //正在按键录音
@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //audio session
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //recorder setting
    NSDictionary* recordSetting = @{AVFormatIDKey:@(kAudioFormatMPEG4AAC), AVSampleRateKey:@(44100.0), AVNumberOfChannelsKey:@(2)};
    
    //init and prepare the recorder
    self.myRecorder = [[AVAudioRecorder alloc] initWithURL:[[DataModel instance] getRecordTmpUrl] settings:recordSetting error:nil];
    self.myRecorder.delegate = self;
    self.myRecorder.meteringEnabled = YES;
    [self.myRecorder prepareToRecord];
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DataModelChange" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.myRecordTable reloadData];
    }];
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




#pragma mark - play
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString: @"open_play_record_board"]) {
        PlayViewController* controller = segue.destinationViewController;
        controller.myPlayRecord = self.myPlayReocord;
    }
}

#pragma mark - action

- (IBAction)onLeftButton:(UIBarButtonItem*)sender{
    if (!self.myRecordTable.editing) {
        sender.title = @"完成";
        [self.myRecordTable setEditing:YES animated:YES];
    }
    else {
        sender.title = @"编辑";
        [self.myRecordTable setEditing:NO animated:NO];
    }
}

- (IBAction)onStartRecord:(id)sender{
    if (!self.myRecorder.recording) {      //开始录音
        [self.myRecordButton setTitle:@"结束" forState:UIControlStateNormal];
        [self startRecord];
        [self presentMessageTips:@"开始录音"];
    }
    else{   //结束录音
        [self.myRecordButton setTitle:@"开始" forState:UIControlStateNormal];
        [self stopRecordWithSave:YES];
    }
}

- (IBAction)onCancelRecord:(id)sender{
    [self.myRecordButton setTitle:@"开始" forState:UIControlStateNormal];
    [self stopRecordWithSave:NO];
}


#pragma mark - ui

- (void)startRecord{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [self.myRecorder record];
}

- (void)stopRecordWithSave:(BOOL)bSave{
    [self dismissTips];
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [self.myRecorder stop];
    [session setActive:NO error:nil];
    if (bSave) {
        [[DataModel instance] saveRecord];
        [self.myRecordTable reloadData];
    }
}


#pragma mark - button

- (IBAction)onTouchInside:(UIButton*)sender{
    NSLog(@"onTouchInside");
    [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
    [self presentLoadingTips:@"正在录音"];
}

- (IBAction)onTouchOutside:(UIButton*)sender{
    NSLog(@"onTouchOutside");
    [sender setTitle:@"上移 取消" forState:UIControlStateNormal];
    [self presentLoadingTips:@"上移 取消"];
}

- (IBAction)onToucnCancel:(UIButton*)sender{
    NSLog(@"onToucnCancel");
    [sender setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self stopRecordWithSave:NO];
}

- (IBAction)onTouchSure:(UIButton*)sender{
    NSLog(@"save");
    [sender setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self stopRecordWithSave:YES];
}

- (IBAction)onTouchBegin:(UIButton*)sender{
    NSLog(@"begin");
    [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
    [self startRecord];
    [self presentLoadingTips:@"正在录音"];
}
#pragma mark - delegate
// 多选删除 暂不支持
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[DataModel instance] getRecordsCount];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[DataModel instance] getRecordByIndex:indexPath.row].url error:nil];
    [cell viewInitwithTitle:[[DataModel instance] getRecordByIndex:indexPath.row].title Duration:player.duration];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSURL* url = [[DataModel instance] getRecordByIndex:indexPath.row].url;
//    [self playRecord:url];
    if (tableView.editing) {
        return indexPath;
    }
    self.myPlayReocord = [[DataModel instance] getRecordByIndex:indexPath.row];
    [self performSegueWithIdentifier:@"open_play_record_board" sender:self];
    return nil;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"删除", nil);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source.
        
        if ([[DataModel instance] deleteRecordByIndex:indexPath.row]) {
            [self.myRecordTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - AVAudioPlayerDelegate


- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
    NSLog(@"record end suc:%d", flag);
}

#pragma mark - notify


@end
