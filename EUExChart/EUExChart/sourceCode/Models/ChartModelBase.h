//
//  ChartModelBase.h
//  EUExChart
//
//  Created by CC on 15/5/28.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Charts/Charts.h>

#import "ChartModelItem.h"
#import "EUtility.h"

typedef NS_ENUM(NSInteger, uexChartType){
    uexChartTypePieChart,
    uexChartTypeBarChart,
    uexChartTypeLineChart
    
};

@protocol uexChartDelegate <ChartViewDelegate,NSObject>

@optional


-(void) uexChartWillReportLog:(NSArray *)logArray
                  fromChartId:(NSString *)identifier
                    chartType:(uexChartType) type;

-(void) uexChartDidFatalErrorHappen:(NSString *)errorStr
                        fromChartId:(NSString *)identifier
                          chartType:(uexChartType) type;



-(void) uexChartShowChart:(ChartViewBase *)chartView
                   WithId:(NSString *) identifier
                chartType:(uexChartType) type
          isScrollWithWeb:(BOOL) isScroll
                 duration:(CGFloat)duration;




@end




@interface ChartModelBase : NSObject











@property (nonatomic,strong) NSMutableArray *characteristics;
@property (nonatomic,strong) NSMutableArray *modelItems;
@property (nonatomic,strong) NSDictionary *dataDict;
@property (nonatomic,assign) CGFloat screenWidth;
@property (nonatomic,assign) CGFloat screenHeight;


@property (nonatomic,copy)NSString *identifier;
@property (nonatomic,copy)NSString *CSSFontName;





@property (nonatomic,strong) NSMutableArray *logArray;
@property (nonatomic,assign) BOOL debug;
@property (nonatomic,weak) id<uexChartDelegate> delegate;
@property (nonatomic,assign) uexChartType chartType;
@property (nonatomic,assign) BOOL isFatalErrorHappened;
-(instancetype)initWithScreenWidth:(CGFloat)width
                            Height:(CGFloat)height
                             debug:(BOOL) debug
                          delegate:(id<uexChartDelegate>)delegate;

-(void)showWithDataDictionary:(NSDictionary *)dataDict;





-(NSArray *)loadExtraLines:(NSArray *)array;

-(void)fatalErrorHappenedWithReportString:(NSString *)reportStr;
-(void)debugReport;

-(id)getValueByName:(NSString *)aName;
-(void)log:(NSString *)event withString:(NSString *)str;
-(void)setValue:(id)value forItem:(ChartModelItem *)aItem;


+(UIColor *)returnUIColorFromHTMLStr:(NSString *)ColorString;




@end


