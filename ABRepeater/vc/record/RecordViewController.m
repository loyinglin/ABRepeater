//
//  RecordViewController.m
//  ABRepeater
//
//  Created by 林伟池 on 15/11/10.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import "RecordViewController.h"
#import "RecordViewCell.h"

@interface RecordViewController ()
@property (nonatomic, strong) AVAudioRecorder* myRecorder;
@property (nonatomic, strong) AVAudioPlayer* myPlayer;

@property (nonatomic) long mySeedId;
@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mySeedId = 1;
    // Do any additional setup after loading the view.
    self.myRecordArray = [[NSMutableArray alloc] init];
    [self loadRecord];
    
    //audio file
    NSArray* paths = @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"__RecordTmp.m4a"];
    NSURL* outputUrl = [NSURL fileURLWithPathComponents:paths];
    
    //audio session
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //recorder setting
    NSDictionary* recordSetting = @{AVFormatIDKey:@(kAudioFormatMPEG4AAC), AVSampleRateKey:@(44100.0), AVNumberOfChannelsKey:@(2)};
    
    //init and prepare the recorder
    self.myRecorder = [[AVAudioRecorder alloc] initWithURL:outputUrl settings:recordSetting error:nil];
    self.myRecorder.delegate = self;
    self.myRecorder.meteringEnabled = YES;
    [self.myRecorder prepareToRecord];
    
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

- (void)loadRecord{
    [self.myRecordArray removeAllObjects];
    NSString* paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    [[NSFileManager defaultManager] removeItemAtPath:paths error:nil];
    NSDirectoryEnumerator* files = [[NSFileManager defaultManager] enumeratorAtPath:paths];
    NSString* fileName;
    while ((fileName = [files nextObject]) != nil) {
        
        NSString* title = [[fileName  lastPathComponent] stringByDeletingPathExtension];

        NSURL* url = [NSURL fileURLWithPath:[paths stringByAppendingPathComponent:fileName]];
        if (![title isEqualToString:@"__RecordTmp"]) {
            [self.myRecordArray addObject:@{@"title":title, @"url":url}];
        }
    }
}

#pragma mark - ui
- (IBAction)onStartRecord:(id)sender{
    if (!self.myRecorder.recording) {      //开始录音
        [self.myRecordButton setTitle:@"结束" forState:UIControlStateNormal];
        [self startRecord];
    }
    else{   //结束录音
        [self.myRecordButton setTitle:@"开始" forState:UIControlStateNormal];
        [self stopRecordWithSave:YES];
    }
}

- (void)startRecord{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [self.myRecorder record];
}

- (void)stopRecordWithSave:(BOOL)bSave{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [self.myRecorder stop];
    [session setActive:NO error:nil];
    if (bSave) {
        [self saveRecord];
    }
}

- (IBAction)onCancelRecord:(id)sender{
    [self.myRecordButton setTitle:@"开始" forState:UIControlStateNormal];
    [self stopRecordWithSave:NO];
}

- (void)saveRecord{
    NSArray* paths = @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"__RecordTmp.m4a"];
    NSURL* copyFromUrl = [NSURL fileURLWithPathComponents:paths];
    
    //name
    NSDate* now = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyMMddHHmmss"];
    NSString* name = [format stringFromDate:now];
    
    
    paths = @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], [NSString stringWithFormat:@"%@.m4a", name]];
    NSURL* copyToUrl = [NSURL fileURLWithPathComponents:paths];
    [[NSFileManager defaultManager] copyItemAtURL:copyFromUrl toURL:copyToUrl error:nil];
    
    
    [self.myRecordArray addObject:@{@"title":name, @"url":copyToUrl}];
    [self.myRecordTable reloadData];
}

- (void)playRecord:(NSURL*)url{
    if (self.myPlayer) {
        [self.myPlayer stop];
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
        self.myPlayer = nil;
    }
    
    self.myPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.myPlayer setDelegate:self];
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [self.myPlayer play];
}

- (void)onDelete:(NSIndexPath*)index{
    NSURL* url = [self.myRecordArray[index.row] objectForKey:@"url"];
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    [self.myRecordArray removeObjectAtIndex:index.row];
    [self.myRecordTable deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - button

- (IBAction)onTouchInside:(UIButton*)sender{
    NSLog(@"onTouchInside");
    [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
}

- (IBAction)onTouchOutside:(UIButton*)sender{
    NSLog(@"onTouchOutside");
    [sender setTitle:@"上移 取消" forState:UIControlStateNormal];
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
}
#pragma mark - delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myRecordArray.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.myTitleLabel.text = [[self.myRecordArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSURL* url = [self.myRecordArray[indexPath.row] objectForKey:@"url"];
    [self playRecord:url];
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
        [self onDelete:indexPath];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"play end");
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}


- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
    NSLog(@"record end");
}

#pragma mark - notify


@end
