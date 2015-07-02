//
//  EUExChartManager.m
//  EUExChart
//
//  Created by CC on 15/6/5.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExChartManager.h"

@implementation EUExChartManager


-(instancetype)init{
    self=[super init];
    if(self){
        _pieCharts=[NSMutableDictionary dictionary];
        _barCharts=[NSMutableDictionary dictionary];
        _lineCharts=[NSMutableDictionary dictionary];
    }
    return  self;
}



-(BOOL)addChartView:(ChartViewBase *)chartView
          ChartType:(uexChartType) type
                 id:(NSString *)identifier{
    switch (type) {
        case uexChartTypePieChart:
        if(![_pieCharts objectForKey:identifier]){
            [_pieCharts setObject:chartView forKey:identifier];
            return YES;
        }
        break;
        
        case uexChartTypeBarChart:
        if(![_barCharts objectForKey:identifier]){
            [_barCharts setObject:chartView forKey:identifier];
            return YES;
        }
        break;
        
        case uexChartTypeLineChart:
        if(![_lineCharts objectForKey:identifier]){
            [_lineCharts setObject:chartView forKey:identifier];
            return YES;
        }
        break;
        default:
        break;
    }
 
    return NO;
}

-(void)removeChartViewById:(NSString *)identifier  ChartType:(uexChartType) type{
    identifier =[NSString stringWithFormat:@"%@",identifier];
    switch (type) {
        case uexChartTypePieChart:
        if([_pieCharts objectForKey:identifier]){
            ChartViewBase *chartView =[_pieCharts objectForKey:identifier];
            [chartView removeFromSuperview];
            [_pieCharts removeObjectForKey:identifier];
        }
        break;
        
        case uexChartTypeBarChart:
        if([_barCharts objectForKey:identifier]){
            ChartViewBase *chartView =[_barCharts objectForKey:identifier];
            [chartView removeFromSuperview];
            [_barCharts removeObjectForKey:identifier];        }
        break;
        
        case uexChartTypeLineChart:
        if([_lineCharts objectForKey:identifier]){
            ChartViewBase *chartView =[_lineCharts objectForKey:identifier];
            [chartView removeFromSuperview];
            [_lineCharts removeObjectForKey:identifier];
        }
        break;
        default:
        break;
    }
}

@end
