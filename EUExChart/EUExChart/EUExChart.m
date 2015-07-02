//
//  EUExChart.m
//  EUExChart
//
//  Created by CC on 15/5/27.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExChart.h"
#import "EUExChartManager.h"
#import "EUExChartModels.h"
#import "JSON.h"
#import "EBrowserView.h"
#import "EUtility.h"
#import "objc/runtime.h"

/*
@implementation NSObject (PropertyListing)
//一般对象转化为字典
- (NSMutableDictionary *)properties_aps {
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setValue:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}





@end
*/



@interface EUExChart()<uexChartDelegate,ChartViewDelegate>
@property (nonatomic,strong) NSMutableDictionary *chartDict;
@property (nonatomic,assign) BOOL debugMode;
@property (nonatomic,strong) EUExChartManager *chartMgr;
@end




@implementation EUExChart

-(id)initWithBrwView:(EBrowserView *)eInBrwView{
    self=[super initWithBrwView:eInBrwView];
    if(self){
        _chartDict=[NSMutableDictionary dictionary];
        self.debugMode=YES;
        self.chartMgr=[[EUExChartManager alloc] init];
    }
    return  self;
}

-(void)clean{
    [self closeBarChart:nil];
    [self closePieChart:nil];
    [self closeLineChart:nil];
}

-(void)dealloc{
    
    [self clean];
}



#pragma mark - Main Methods
-(void)openPieChart:(NSMutableArray *)inArgument{
    if([inArgument count]<1) return;
    id dataDict=[self getDataFromJson:inArgument[0]];
    
    if(![dataDict isKindOfClass:[NSDictionary class]]){
        return;
    }
    PieChartModel *pieChart = [[PieChartModel alloc] initWithScreenWidth:[EUtility screenWidth]
                                                                  Height:[EUtility screenHeight]
                                                                   debug:_debugMode
                                                                delegate:self];
    
    [pieChart showWithDataDictionary:dataDict];
}

-(void)closePieChart:(NSMutableArray *)inArgument{
    if([inArgument count] <1){
        NSArray *idArray=[_chartMgr.pieCharts allKeys];
        for(int i=0;i<[idArray count];i++){
            [_chartMgr removeChartViewById:idArray[i] ChartType:uexChartTypePieChart];
        }
        return;
    }
    id info = [self getDataFromJson:inArgument[0]];
    if([info isKindOfClass:[NSArray class]]){
        
        for(int i=0;i<[info count];i++){
            [_chartMgr removeChartViewById:info[i] ChartType:uexChartTypePieChart];
        }
        
    }
    
}

-(void)openLineChart:(NSMutableArray *)inArgument{
    if([inArgument count]<1) return;
    id dataDict=[self getDataFromJson:inArgument[0]];
    
    if(![dataDict isKindOfClass:[NSDictionary class]]){
        return;
    }
    LineChartModel *lineChart = [[LineChartModel alloc] initWithScreenWidth:[EUtility screenWidth]
                                                                  Height:[EUtility screenHeight]
                                                                   debug:_debugMode
                                                                delegate:self];
    
    [lineChart showWithDataDictionary:dataDict];
}

-(void)closeLineChart:(NSMutableArray *)inArgument{
    if([inArgument count] <1){
        NSArray *idArray=[_chartMgr.lineCharts allKeys];
        for(int i=0;i<[idArray count];i++){
            [_chartMgr removeChartViewById:idArray[i] ChartType:uexChartTypeLineChart];
        }
        return;
    }
    id info = [self getDataFromJson:inArgument[0]];
    if([info isKindOfClass:[NSArray class]]){
        
        for(int i=0;i<[info count];i++){
            [_chartMgr removeChartViewById:info[i] ChartType:uexChartTypeLineChart];
        }
        
    }
    
}
-(void)openBarChart:(NSMutableArray *)inArgument{
    if([inArgument count]<1) return;
    id dataDict=[self getDataFromJson:inArgument[0]];
    
    if(![dataDict isKindOfClass:[NSDictionary class]]){
        return;
    }
    BarChartModel *lineChart = [[BarChartModel alloc] initWithScreenWidth:[EUtility screenWidth]
                                                                     Height:[EUtility screenHeight]
                                                                      debug:_debugMode
                                                                   delegate:self];
    
    [lineChart showWithDataDictionary:dataDict];
}

-(void)closeBarChart:(NSMutableArray *)inArgument{
    if([inArgument count] <1){
        NSArray *idArray=[_chartMgr.barCharts allKeys];
        for(int i=0;i<[idArray count];i++){
            [_chartMgr removeChartViewById:idArray[i] ChartType:uexChartTypeBarChart];
        }
        return;
    }
    id info = [self getDataFromJson:inArgument[0]];
    if([info isKindOfClass:[NSArray class]]){
        
        for(int i=0;i<[info count];i++){
            [_chartMgr removeChartViewById:info[i] ChartType:uexChartTypeBarChart];
        }
        
    }
    
}

#pragma mark - uexChartDelegate

-(void) uexChartWillReportLog:(NSArray *)logArray fromChartId:(NSString *)identifier chartType:(uexChartType) type{
    NSMutableString *logStr=[NSMutableString stringWithFormat:@"Log of chart %@:\n",identifier];
    for(int i=0;i<[logArray count];i++){
        [logStr appendString:[NSString stringWithFormat:@"%@\n",logArray[i]]];
    }
    
    //NSLog(logStr);
    [self returnJsonWithName:@"log" Object:logStr];
}
-(void) uexChartDidFatalErrorHappen:(NSString *)errorStr fromChartId:(NSString *)identifier chartType:(uexChartType) type{
    [self returnJsonWithName:@"onError" Object:errorStr];
}


-(void)uexChartShowChart:(ChartViewBase *)chartView
                  WithId:(NSString *) identifier
               chartType:(uexChartType) type
         isScrollWithWeb:(BOOL) isScroll
                duration:(CGFloat)duration{
    if([_chartMgr addChartView:chartView ChartType:type id:identifier]){
        if(isScroll){
            
            [EUtility brwView:meBrwView addSubviewToScrollView:chartView];
        }else{
            [EUtility brwView:meBrwView addSubview:chartView];
        }
        
        [chartView animateWithXAxisDuration:duration yAxisDuration:duration];
    }
    
    
}

#pragma mark - chartView Delegate




- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    
    
    NSDictionary *dict=[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:entry.value] forKey:@"value"];
    [self returnJsonWithName:@"onValueSelected" Object:dict];
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    
}
#pragma mark - JsonIO
/*
 回调方法name(data)  方法名为name，参数为 字典dict的转成的json字符串
 
 */
-(void) returnJsonWithName:(NSString *)name Object:(id)obj{
    /*
     
     
     
     if([NSJSONSerialization isValidJSONObject:dict]){
     NSError *error;
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
     options:NSJSONWritingPrettyPrinted
     error:&error
     ];
     
     NSString *result = [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
     */
    NSString *result=[obj JSONFragment];
    NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexChart.%@ != null){uexChart.%@('%@');}",name,name,result];
    
    [self performSelectorOnMainThread:@selector(callBack:) withObject:jsSuccessStr waitUntilDone:YES];
    
}
-(void)callBack:(NSString *)str{
    [self performSelector:@selector(delayedCallBack:) withObject:str afterDelay:0.01];
    //[meBrwView stringByEvaluatingJavaScriptFromString:str];
}

-(void)delayedCallBack:(NSString *)str{
    [EUtility brwView:meBrwView evaluateScript:str];
}



//从json字符串中获取数据
- (id)getDataFromJson:(NSString *)jsonData{
    NSError *error = nil;
    
    
    
    NSData *jsonData2= [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData2
                     
                                                    options:NSJSONReadingMutableContainers
                     
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        
        return jsonObject;
    }else{
        
        // 解析錯誤
        
        return nil;
    }
    
}


@end
