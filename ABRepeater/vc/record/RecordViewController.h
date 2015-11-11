//
//  RecordViewController.h
//  ABRepeater
//
//  Created by 林伟池 on 15/11/10.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (nonatomic , strong) IBOutlet UIButton* myRecordButton; //start end button
@property (nonatomic , strong) IBOutlet UIButton* myCancelButton; //cancel

//@property (nonatomic , strong) IBOutlet UIButton* 

@property (nonatomic , strong) IBOutlet UITableView* myRecordTable;
@property (nonatomic , strong) NSMutableArray* myRecordArray;

@end
