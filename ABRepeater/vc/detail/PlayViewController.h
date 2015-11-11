//
//  PlayViewController.h
//  ABRepeater
//
//  Created by 林伟池 on 15/11/11.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DataModel.h"

@interface PlayViewController : UIViewController<AVAudioPlayerDelegate>

@property (nonatomic , strong) Record* myPlayRecord;

@property (nonatomic , strong) IBOutlet UIProgressView* myProcess;
@property (nonatomic , strong) IBOutlet UILabel*    myStartLabel;
@property (nonatomic , strong) IBOutlet UILabel*    myEndLabel;
@property (nonatomic , strong) IBOutlet UIButton*   myRepeatButton;

@end
