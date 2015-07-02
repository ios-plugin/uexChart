//
//  ChartModelItem.m
//  EUExChart
//
//  Created by CC on 15/5/29.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "ChartModelItem.h"

@implementation ChartModelItem
+(ChartModelItem*)itemWithValue:(id)value name:(NSString *)name type:(uexChartModelItemType) type{
     ChartModelItem *obj=[[ChartModelItem alloc] init];
    if(obj){
        obj.value=value;
        obj.name=name;
        obj.type=type;
    }
    return  obj;

}



@end

