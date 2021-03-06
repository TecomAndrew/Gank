//
//  GankResponse.h
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GankResult.h"
#import "GankDaily.h"

@interface GankResponse : NSObject
- (instancetype)initWithResponse:(id)responseObj;
- (NSArray<GankResult *> *)resultFromResponse;
- (GankDaily *)resultOfDaily;
- (NSArray *)resultOfDaysHistory;
@end
