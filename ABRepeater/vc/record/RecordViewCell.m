//
//  RecordViewCell.m
//  ABRepeater
//
//  Created by 林伟池 on 15/11/10.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import "RecordViewCell.h"

@implementation RecordViewCell

#define const_length  10

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)viewInitwithTitle:(NSString *)title Duration:(long)duration{
    self.myTitleLabel.text = title;
    UIImage* img = [UIImage imageNamed:@"Team_08.png"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 16) resizingMode:UIImageResizingModeStretch];
//    UIImage animatedImageNamed:<#(nonnull NSString *)#> duration:<#(NSTimeInterval)#>
    [self.myRecordImg setImage:img];
    long len = 0;
    
    if (duration <= 1) {
        len = const_length;
    }
    else if (duration <= 10){
        len = duration * const_length;
    }
    else {
        len = ((duration - 10) / 10) * const_length + 9 * const_length;
    }
    
    NSLog(@"%d -> %d", duration, len);
    
    for (NSLayoutConstraint* item in self.myRecordImg.constraints) {
        if ([item.identifier isEqualToString:@"width"]) {
            item.constant = 40 + len;
            [self layoutIfNeeded];
            break;
        }
    }
    
    
    self.myDurationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", duration / 60, duration % 60];
}
@end
