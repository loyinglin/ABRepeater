//
//  RecordViewCell.h
//  ABRepeater
//
//  Created by 林伟池 on 15/11/10.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordViewCell : UITableViewCell

@property (nonatomic , strong) IBOutlet UILabel* myTitleLabel;
@property (nonatomic , strong) IBOutlet UIImageView* myRecordImg;
@property (nonatomic , strong) IBOutlet UILabel* myDurationLabel;

- (void)viewInitwithTitle:(NSString*)title Duration:(long)duration;

@end
