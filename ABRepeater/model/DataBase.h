//
//  DataBase.h
//  ABRepeater
//
//  Created by 林伟池 on 15/11/11.
//  Copyright © 2015年 林伟池. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Record : NSObject

@property (nonatomic , strong) NSString* title;
@property (nonatomic , strong) NSURL* url;

@end


@interface Repeat : NSObject
@property (nonatomic) int timeA;
@property (nonatomic) int timeB;

@end