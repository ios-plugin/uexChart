//
//  PieChartModel.h
//  EUExChart
//
//  Created by AppCan on 15/5/28.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartModelBase.h"



@interface PieChartModel : ChartModelBase





-(instancetype)initWithScreenWidth:(CGFloat)width
                            Height:(CGFloat)height
                             debug:(BOOL) debug
                          delegate:(id<uexChartDelegate>)delegate;

@end
