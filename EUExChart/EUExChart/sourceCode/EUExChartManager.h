//
//  EUExChartManager.h
//  EUExChart
//
//  Created by CC on 15/6/5.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExChartModels.h"

@interface EUExChartManager : NSObject
@property (nonatomic,strong) NSMutableDictionary *pieCharts;
@property (nonatomic,strong) NSMutableDictionary *lineCharts;
@property (nonatomic,strong) NSMutableDictionary *barCharts;



-(BOOL)addChartView:(ChartViewBase *)chartView
          ChartType:(uexChartType) type
                 id:(NSString *)identifier;

-(void)removeChartViewById:(NSString *)identifier  ChartType:(uexChartType) type;
@end
