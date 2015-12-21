//
//  LineChartModel.m
//  EUExChart
//
//  Created by CC on 15/6/6.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "LineChartModel.h"
@interface LineChartModel () <ChartViewDelegate>


@property (nonatomic,strong) LineChartView *chartView;
@property(nonatomic,strong) NSMutableArray *xData;
@end





@implementation LineChartModel







-(instancetype)initWithScreenWidth:(CGFloat)width
                            Height:(CGFloat)height
                             debug:(BOOL)isDebug
                          delegate:(id<uexChartDelegate>)delegate{
    self=[super initWithScreenWidth:width
                             Height:height
                              debug:isDebug
                           delegate:delegate];
    if(self){
        self.chartType=uexChartTypeLineChart;
        
        [self setupLineChartItems];
    }
    return  self;
}

-(void)setupLineChartItems{
    [self.modelItems addObject:[ChartModelItem itemWithValue:@YES
                                                        name:@"highlightIndicatorEnabled"
                                                        type:uexChartModelItemBool]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:[UIColor blackColor]
                                                        name:@"borderColor"
                                                        type:uexChartModelItemColor]];

    [self.modelItems addObject:[ChartModelItem itemWithValue:nil
                                                        name:@"minValue"
                                                        type:uexChartModelItemOptionalObject]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:nil
                                                        name:@"maxValue"
                                                        type:uexChartModelItemOptionalObject]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:nil
                                                        name:@"extraLines"
                                                        type:uexChartModelItemOptionalObject]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:nil
                                                        name:@"option"
                                                        type:uexChartModelItemOptionalObject]];

    
}
-(void)loadCoreData{
    if([self.dataDict objectForKey:@"id"]){
        self.identifier=[NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"id"]];
        [self log:@"id" withString:@"succesfully!"];
    }else{
        [self fatalErrorHappenedWithReportString:@"Cannot load id"];
        
    }
    
    if([self.dataDict objectForKey:@"xData"]&&[[self.dataDict objectForKey:@"xData"] isKindOfClass:[NSArray class]]){
     //if([self.dataDict objectForKey:@"xDada"]){
        self.xData=[NSMutableArray array];
        NSArray *xData=[self.dataDict objectForKey:@"xData"];
        for(int i=0;i<[xData count];i++){
            [self.xData addObject:[NSString stringWithFormat:@"%@",xData[i]]];
        }
    }else{
        NSLog(@"xDate not set");
    }
    
    if([self.dataDict objectForKey:@"lines"]&&[[self.dataDict objectForKey:@"lines"] isKindOfClass:[NSArray class]]){
        
        [self log:@"linesArray" withString:@"succesfully!"];
        [self loadLines:[self.dataDict objectForKey:@"lines"]];
        
    }else{
        [self fatalErrorHappenedWithReportString:@"Cannot load linesArray"];
        
        
    }
    
    
    
}




-(void)loadLines:(NSArray *)dataArray{
    BOOL isError;
    NSMutableDictionary *tmpDict,*resultDict=nil;
    for(int i=0;i<[dataArray count];i++){
        isError=NO;
        resultDict=nil;
        tmpDict=nil;
        if ([dataArray[i] isKindOfClass:[NSDictionary class]]){
            tmpDict=dataArray[i];
            resultDict=[NSMutableDictionary dictionary];
            if([tmpDict objectForKey:@"lineName"]&&[[tmpDict objectForKey:@"lineName"] isKindOfClass:[NSString class]]){
                [self log:[NSString stringWithFormat:@"dataArray#%i lineName",i] withString:@"successfully!"];
                [resultDict setObject:[tmpDict objectForKey:@"lineName"] forKey:@"lineName"];
            }else isError=YES;
            if([tmpDict objectForKey:@"lineWidth"]){
                [resultDict setObject:[NSNumber numberWithFloat:[[tmpDict objectForKey:@"lineWidth"] floatValue]] forKey:@"lineWidth"];
                [self log:[NSString stringWithFormat:@"dataArray#%i lineWidth",i] withString:@"successfully!"];
            }else isError=YES;
            if([tmpDict objectForKey:@"circleSize"]){
                [resultDict setObject:[NSNumber numberWithFloat:[[tmpDict objectForKey:@"circleSize"] floatValue]] forKey:@"circleSize"];
                [self log:[NSString stringWithFormat:@"dataArray#%i circleSize",i] withString:@"successfully!"];
            }else isError=YES;
            if([tmpDict objectForKey:@"lineColor"]&&[[tmpDict objectForKey:@"lineColor"] isKindOfClass:[NSString class]]){
                [resultDict setObject:[ChartModelBase returnUIColorFromHTMLStr:[tmpDict objectForKey:@"lineColor"]] forKey:@"lineColor"];
                [self log:[NSString stringWithFormat:@"dataArray#%i lineColor",i] withString:@"successfully!"];
            }else isError=YES;
            if([tmpDict objectForKey:@"circleColor"]&&[[tmpDict objectForKey:@"circleColor"] isKindOfClass:[NSString class]]){
                [resultDict setObject:[ChartModelBase returnUIColorFromHTMLStr:[tmpDict objectForKey:@"circleColor"]] forKey:@"circleColor"];
                [self log:[NSString stringWithFormat:@"dataArray#%i circleColor",i] withString:@"successfully!"];
            }else isError=YES;
            
            [resultDict setValue:@YES forKey:@"isSolid"];
            if([tmpDict objectForKey:@"isSolid"]){
                id isSolid=[tmpDict objectForKey:@"isSolid"];
                if([isSolid  isEqual:@"false"]||([isSolid  integerValue]==0)){
                    [resultDict setValue:@NO forKey:@"isSolid"];
                    [self log:[NSString stringWithFormat:@"dataArray#%i isSolid",i] withString:@"successfully!"];
                }
            }
            
            
            if([tmpDict objectForKey:@"cubicIntensity"]&&([[tmpDict objectForKey:@"cubicIntensity"] floatValue]<=1.f)&&([[tmpDict objectForKey:@"cubicIntensity"] floatValue]>=0.05f)){
                [resultDict setValue:[NSNumber numberWithFloat:[[tmpDict objectForKey:@"cubicIntensity"] floatValue]] forKey:@"cubicIntensity"];
                [self log:[NSString stringWithFormat:@"dataArray#%i cubicIntensity",i] withString:@"successfully!"];
            }
            if([tmpDict objectForKey:@"fillColor"]&&[[tmpDict objectForKey:@"fillColor"] isKindOfClass:[NSString class]]){
                [resultDict setValue:[ChartModelBase returnUIColorFromHTMLStr:[tmpDict objectForKey:@"fillColor"]] forKey:@"fillColor"];
                [self log:[NSString stringWithFormat:@"dataArray#%i fillColor",i] withString:@"successfully!"];
            }

            BOOL xDataAvailable=YES;
            if(!self.xData){
                xDataAvailable=NO;
                self.xData=[NSMutableArray array];
            }
            
            
            NSMutableArray *points = [NSMutableArray array];
            if([tmpDict objectForKey:@"data"]&&[[tmpDict objectForKey:@"data"] isKindOfClass:[NSArray class]]){
                NSArray *data=[tmpDict objectForKey:@"data"];
                
                BOOL completeData=YES;
                for(int j=0;j<[data count];j++){
                    id pointTmp=data[j];
                    NSMutableDictionary *pointDict =[NSMutableDictionary dictionary];
                    if ([pointTmp isKindOfClass:[NSDictionary class]]){
                        
                        if([pointTmp objectForKey:@"xValue"]){
                            NSInteger xIndex=-1;
                            NSString *xValue=[NSString stringWithFormat:@"%@",[pointTmp objectForKey:@"xValue"]];
                            if(!xDataAvailable && ![self.xData containsObject:xValue]){
                                [self.xData addObject:xValue];
                            }
                            for(int k=0;k<[self.xData count];k++){
                                if([xValue isEqual:self.xData[k]]){
                                    xIndex=k;
                                }
                            }
                            if(xIndex!= -1){
                                [pointDict setObject:[NSNumber numberWithInteger:xIndex] forKey:@"xIndex"];
                            }else completeData=NO;
                            
                        }else completeData=NO;
                        if([pointTmp objectForKey:@"yValue"]){
                           
                            [pointDict setObject:[NSNumber numberWithFloat:[[pointTmp objectForKey:@"yValue"] floatValue]] forKey:@"yValue"];
                        }else completeData=NO;

                        
                        
                        
                    }else completeData=NO;
                    if(completeData) [points addObject:pointDict];
                    
                }
            }
            if([points count]<1 ){
                [self fatalErrorHappenedWithReportString:@"No valid data characteristic exists"];
            }else{
                [resultDict setObject:points forKey:@"data"];
            }
            
            
            
        }else{
            isError=YES;
        }
        
        if(isError){
            [self log:[NSString stringWithFormat:@"dataArray#%i",i] withString:@"failed,unrecognized data!"];
        }else{
            [self log:[NSString stringWithFormat:@"dataArray#%i",i] withString:@"successfully!"];
            [self.characteristics addObject:resultDict];
        }
        
    }
    
    if([self.characteristics count]<1){
        [self fatalErrorHappenedWithReportString:@"No valid data characteristic exists!"];
    }
    
}



-(void)prepareToShow{
    if(self.isFatalErrorHappened) return;
    
    self.chartView=[[LineChartView alloc]initWithFrame:CGRectMake([[self getValueByName:@"left"] floatValue],
                                                                 [[self getValueByName:@"top"] floatValue],
                                                                 [[self getValueByName:@"width"] floatValue],
                                                                 [[self getValueByName:@"height"] floatValue])];
    
    
    
    _chartView.delegate =self.delegate;
    NSInteger dataCount=[self.characteristics count];

    NSMutableArray *yData=[[NSMutableArray alloc] init];
    for(int i=0;i<dataCount;i++){
        NSMutableArray *yVals=[[NSMutableArray alloc] init];
        NSDictionary *dataDict=self.characteristics[i];
        NSArray *values=[dataDict objectForKey:@"data"];
        for(int j=0;j<[values count];j++){

            CGFloat yValueF =[[values[j] objectForKey:@"yValue"] floatValue];
            ChartDataEntry *entry=[[ChartDataEntry alloc] initWithValue:yValueF xIndex:[[values[j] objectForKey:@"xIndex"] integerValue]];
            [yVals addObject:entry];
            
        }
        
         LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithYVals:yVals label:[NSString stringWithFormat:@"line data%i",i]];
        dataSet.lineWidth=[[dataDict objectForKey:@"lineWidth"] floatValue];
        
        
        [dataSet setCircleColor:[dataDict objectForKey:@"circleColor"]];
        dataSet.label=[dataDict objectForKey:@"lineName"];
        dataSet.circleRadius=[[dataDict objectForKey:@"circleSize"] floatValue];
        //showValue:,//(可选) 是否显示value，默认true
        dataSet.drawValuesEnabled= [[self getValueByName:@"showValue"] boolValue];
        dataSet.colors=@[[dataDict objectForKey:@"lineColor"]];
        
        //isSolid
        if(![[dataDict objectForKey:@"isSolid"] boolValue]){
            dataSet.lineDashLengths = @[@5.f, @5.f];
        }
        
        //isCubic
        if([dataDict objectForKey:@"cubicIntensity"]){
            dataSet.drawCubicEnabled=YES;
            dataSet.cubicIntensity=[[dataDict objectForKey:@"cubicIntensity"] floatValue];
        }
        //isFilled
        if([dataDict objectForKey:@"fillColor"]){
            dataSet.drawFilledEnabled=YES;
            dataSet.fillColor=[dataDict objectForKey:@"fillColor"];
            dataSet.fillAlpha=1.f;

        }
        NSNumberFormatter *valueFormatter=[[NSNumberFormatter alloc]init];
        valueFormatter.numberStyle=NSNumberFormatterNoStyle;
        dataSet.valueFormatter=valueFormatter;
        [yData addObject:dataSet];
        

    }

    
    
    
     LineChartData *data = [[LineChartData alloc] initWithXVals:self.xData dataSets:yData];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    ChartXAxis *xAxis = _chartView.xAxis;
    
    
    
    
    
    
    //bgColor:,//(可选) 背景颜色，默认透明
    self.chartView.backgroundColor=[self getValueByName:@"bgColor"];
    self.chartView.gridBackgroundColor=[self getValueByName:@"bgColor"];

    self.chartView.highlightPerTapEnabled=[[self getValueByName:@"highlightIndicatorEnabled"] boolValue];
    self.chartView.highlightPerDragEnabled=[[self getValueByName:@"highlightIndicatorEnabled"] boolValue];
    //showUnit:,//(可选) 是否显示单位，默认false
    //unit:,//(可选) 单位

    
    

    
    //valueTextColor:,//(可选) 值的文本颜色，默认#ffffff
    [data setValueTextColor:[self getValueByName:@"valueTextColor"]];
    
    
    //valueTextSize:,//(可选) 值的字体大小，默认13
    [data setValueFont:[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"valueTextSize"] floatValue]]];
    
    
    
    //desc:,//(可选) 描述
    self.chartView.descriptionText = [self getValueByName:@"desc"];
    //descTextColor:,//(可选) 描述及图例文本颜色，默认#000000
    self.chartView.descriptionTextColor=[self getValueByName:@"descTextColor"];
    self.chartView.legend.textColor=[self getValueByName:@"descTextColor"];
    leftAxis.labelTextColor=[self getValueByName:@"descTextColor"];
    xAxis.labelTextColor=[self getValueByName:@"descTextColor"];
    //descTextSize:,//(可选) 描述及图例字体大小，默认12
    self.chartView.descriptionFont=[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"descTextSize"] floatValue]];
    self.chartView.legend.font=[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"descTextSize"] floatValue]];
    leftAxis.labelFont=[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"descTextSize"] floatValue]];
    xAxis.labelFont=[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"descTextSize"] floatValue]];

    
    //showLegend:,//(可选) 是否显示图例，默认false
    self.chartView.legend.enabled=[[self getValueByName:@"showLegend"] boolValue];
    //legendPosition:,//(可选) 图例显示的位置，取值范围：bottom-饼状图下方；right-饼状图右侧，默认bottom
    self.chartView.legend.position=[[self getValueByName:@"legendPosition"] integerValue];
    //showTitle:,//(可选) 是否显示title，默认true
    

    xAxis.gridColor=[self getValueByName:@"borderColor"];
    xAxis.axisLineColor=[self getValueByName:@"borderColor"];
    
    xAxis.labelPosition=XAxisLabelPositionBottom;
    
    
    NSString *symbol=@"";
    if([[self getValueByName:@"showUnit"] boolValue]){
        symbol=[self getValueByName:@"unit"];
    }
    if([self getValueByName:@"extraLines"]&&[[self getValueByName:@"extraLines"] isKindOfClass:[NSArray class]]){
        NSArray *limitlines=[self loadExtraLines:[self getValueByName:@"extraLines"]];
        for(ChartLimitLine *limitLine in limitlines){
            [leftAxis addLimitLine:limitLine];
        }
    }

    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    leftAxis.valueFormatter.negativeSuffix = symbol;
    leftAxis.valueFormatter.positiveSuffix = symbol;
    leftAxis.startAtZeroEnabled=NO;
    if([self getValueByName:@"minValue"]) leftAxis.customAxisMin=[[self getValueByName:@"minValue"] floatValue];
    if([self getValueByName:@"maxValue"]) leftAxis.customAxisMax =[[self getValueByName:@"maxValue"] floatValue];
    leftAxis.gridColor=[self getValueByName:@"borderColor"];
    leftAxis.axisLineColor=[self getValueByName:@"borderColor"];
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.drawLabelsEnabled=NO;
    rightAxis.drawGridLinesEnabled = NO;

    self.chartView.drawBordersEnabled=YES;
    self.chartView.borderColor=[self getValueByName:@"borderColor"];
    
    self.chartView.legend.xEntrySpace = 7.f;
    self.chartView.legend.yEntrySpace = 5.f;
    self.chartView.data=data;
    
    
    self.chartView.scaleXEnabled=YES;
    self.chartView.scaleYEnabled=YES;
    self.chartView.dragEnabled=YES;
    NSDictionary *option=[self getValueByName:@"option"];
    if(!option){
        [self.chartView setNeedsDisplay];
        return;
    }
    CGFloat scaleX=option[@"initZoomX"]?[option[@"initZoomX"] floatValue]:1;
    CGFloat scaleY=option[@"initZoomY"]?[option[@"initZoomY"] floatValue]:1;
    CGFloat positionX=option[@"initPositionX"]?[option[@"initPositionX"] floatValue]:0;
    CGFloat positionY=option[@"initPositionY"]?[option[@"initPositionY"] floatValue]:0;
    [self.chartView zoom:scaleX scaleY:scaleY x:positionX y:positionY];
    
    if (option[@"isSupportDrag"]) {
        self.chartView.dragEnabled=[option[@"isSupportDrag"] boolValue];
    }
    if (option[@"isSupportZoomX"]) {
        self.chartView.scaleXEnabled=[option[@"isSupportZoomX"] boolValue];
    }
    if (option[@"isSupportZoomY"]) {
        self.chartView.scaleYEnabled=[option[@"isSupportZoomY"] boolValue];
    }
    
    [self.chartView setNeedsDisplay];
    
}


-(void)show{
    if(self.isFatalErrorHappened) return;
    
    
    //duration:,//(可选) 显示饼状图动画时间，单位ms，默认1000
    CGFloat duration=[[self getValueByName:@"duration"] floatValue]/1000.f;
    
    //isScrollWithWeb:,//(可选) 是否跟随网页滑动，默认false
    BOOL isScrollWithWeb=[[self getValueByName:@"isScrollWithWeb"] boolValue];
    [self debugReport];
    
    [self.delegate uexChartShowChart:self.chartView WithId:self.identifier chartType:self.chartType isScrollWithWeb:isScrollWithWeb duration:duration];
    
    
    
}






@end
