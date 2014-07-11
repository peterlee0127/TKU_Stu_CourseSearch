//
//  TKU_CourseModel.h
//  TKU_CourseSearch
//
//  Created by Peterlee on 7/11/14.
//  Copyright (c) 2014 Peterlee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKU_CourseModel : NSObject

@property (nonatomic,assign) NSString *courseName;
@property (nonatomic,assign) NSString *room1;
@property (nonatomic,assign) NSString *time1;
@property (nonatomic,assign) NSString *day1;

@property (nonatomic,assign) BOOL hasTwoTime;
@property (nonatomic,assign) NSString *room2;
@property (nonatomic,assign) NSString *time2;
@property (nonatomic,assign) NSString *day2;


@end
