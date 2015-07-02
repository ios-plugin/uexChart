//
//  BarChartModel.h
//  EUExChart
//
//  Created by CC on 15/6/6.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "ChartModelBase.h"

@interface BarChartModel : ChartModelBase
-(instancetype)initWithScreenWidth:(CGFloat)width
                            Height:(CGFloat)height
                             debug:(BOOL) debug
                          delegate:(id<uexChartDelegate>)delegate;
@end

