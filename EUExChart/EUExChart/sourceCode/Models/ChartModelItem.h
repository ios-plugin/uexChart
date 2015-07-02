//
//  ChartModelItem.h
//  EUExChart
//
//  Created by CC on 15/5/29.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ChartModelItem : NSObject


typedef NS_ENUM(NSInteger, uexChartModelItemType){
    uexChartModelItemFloat,
    uexChartModelItemString,
    uexChartModelItemInteger,
    uexChartModelItemBool,
    uexChartModelItemColor,
    uexChartModelItemPosition,
    uexChartModelItemOptionalObject
};

@property (nonatomic,strong)id value;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,assign)uexChartModelItemType type;

+(ChartModelItem*)itemWithValue:(id)value name:(NSString *)name type:(uexChartModelItemType) type;


@end

