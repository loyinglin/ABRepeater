//
//  DataModel.h
//  ABRepeater
//
//  Created by 林伟池 on 15/11/11.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBase.h"


@interface DataModel : NSObject



#pragma mark - init

+(instancetype)instance;

#pragma mark - set

- (void)saveRecord;

- (BOOL)deleteRecordByIndex:(long)index;

- (BOOL)modifyTitleByRecord:(Record*)record Title:(NSString*)title;

#pragma mark - get

- (NSURL*)getRecordTmpUrl;

- (Record*)getRecordByIndex:(long)index;

- (Record*)getLastRecordByRecord:(Record*)record;

- (Record*)getNextRecordByRecord:(Record*)record;

- (long)getRecordsCount;

#pragma mark - update



#pragma mark - message


@end
