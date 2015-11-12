//
//  DataModel.m
//  ABRepeater
//
//  Created by 林伟池 on 15/11/11.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import "DataModel.h"


@implementation DataModel
{
    NSMutableArray<Record*>* myRecordArray;
}


#pragma mark - init


+(instancetype) instance
{
    static id test;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        test = [[[self class] alloc] init];
    });
    return test;
}

- (instancetype)init{
    self = [super init];
    
    myRecordArray = [NSMutableArray array];
    [self loadData];
    
    
    
    return self;
}


- (void)loadData{
    
    [myRecordArray removeAllObjects];
    NSString* paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //    [[NSFileManager defaultManager] removeItemAtPath:paths error:nil];
    NSDirectoryEnumerator* files = [[NSFileManager defaultManager] enumeratorAtPath:paths];
    NSString* fileName;
    while ((fileName = [files nextObject]) != nil) {
        
        NSString* title = [[fileName  lastPathComponent] stringByDeletingPathExtension];
        
        NSURL* url = [NSURL fileURLWithPath:[paths stringByAppendingPathComponent:fileName]];
        if (![title isEqualToString:@"__RecordTmp"]) {
            Record* item = [Record new];
            item.title = title;
            item.url = url;
            [myRecordArray addObject:item];
        }
    }

}
#pragma mark - set

- (BOOL)modifyTitleByRecord:(Record *)record Title:(NSString *)title{
    NSArray* paths =@[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], [NSString stringWithFormat:@"%@.m4a", title]];
    NSURL* copyToUrl = [NSURL fileURLWithPathComponents:paths];
    
    BOOL ret;
    ret = [[NSFileManager defaultManager] moveItemAtURL:record.url toURL:copyToUrl error:nil];
    if (ret) {
        record.url = copyToUrl;
        record.title = title;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataModelChange" object:nil];
    }
    return ret;
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
    
    Record* item = [Record new];
    item.title = name;
    item.url = copyToUrl;
    [myRecordArray addObject:item];
}

- (BOOL)deleteRecordByIndex:(long)index{
    
    BOOL ret = NO;
    if (index >= 0 && index < myRecordArray.count) {
        NSURL* url = myRecordArray[index].url;
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [myRecordArray removeObjectAtIndex:index];
        ret = YES;
    }
    return ret;
}

#pragma mark - get

- (NSURL *)getRecordTmpUrl{
    NSArray* paths = @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"__RecordTmp.m4a"];
    NSURL* outputUrl = [NSURL fileURLWithPathComponents:paths];
    return outputUrl;
}

- (long)getRecordsCount{
    return myRecordArray.count;
}

- (Record *)getRecordByIndex:(long)index{
    Record* ret = myRecordArray[index];
    return ret;    
}

- (Record *)getLastRecordByRecord:(Record *)record{
    Record* ret;
    long index = [myRecordArray indexOfObject:record];
    if (index > 0) {
        ret = myRecordArray[index - 1];
    }
    else{
        ret = [myRecordArray lastObject];
    }
    return ret;
}

- (Record *)getNextRecordByRecord:(Record *)record{
    Record* ret;
    long index = [myRecordArray indexOfObject:record];
    if (index + 1 < myRecordArray.count) {
        ret = myRecordArray[index + 1];
    }
    else{
        ret = myRecordArray[0];
    }
    return ret;
}
#pragma mark - update



#pragma mark - message


@end
