//
//  PieChartModel.m
//  EUExChart
//
//  Created by CC on 15/5/28.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "PieChartModel.h"




@interface PieChartModel () <ChartViewDelegate>


@property (nonatomic,strong) PieChartView *chartView;
@end



@implementation PieChartModel





-(instancetype)initWithScreenWidth:(CGFloat)width
                            Height:(CGFloat)height
                             debug:(BOOL)isDebug
                          delegate:(id<uexChartDelegate>)delegate{
    self=[super initWithScreenWidth:width
                             Height:height
                              debug:isDebug
                           delegate:delegate];
    if(self){
        self.chartType=uexChartTypePieChart;
        
        [self setupPieChartItems];
    }
    return  self;
}

-(void)setupPieChartItems{
    [self.modelItems addObject:[ChartModelItem itemWithValue:@YES
                                                        name:@"showTitle"
                                                        type:uexChartModelItemBool]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:@YES
                                                        name:@"showPercent"
                                                        type:uexChartModelItemBool]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:@YES
                                                        name:@"showCenter"
                                                        type:uexChartModelItemBool]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:[UIColor clearColor]
                                                        name:@"centerColor"
                                                        type:uexChartModelItemColor]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:@""
                                                        name:@"centerTitle"
                                                        type:uexChartModelItemString]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:@""
                                                        name:@"centerSummary"
                                                        type:uexChartModelItemString]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:@40.f
                                                        name:@"centerRadius"
                                                        type:uexChartModelItemFloat]];
    [self.modelItems addObject:[ChartModelItem itemWithValue:@42.f
                                                        name:@"centerTransRadius"
                                                        type:uexChartModelItemFloat]];
    
}



-(void)loadCoreData{
    if([self.dataDict objectForKey:@"id"]){
        self.identifier=[NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"id"]];
        [self log:@"id" withString:@"succesfully!"];
    }else{
        [self fatalErrorHappenedWithReportString:@"Cannot load id"];
        
    }
    
    if([self.dataDict objectForKey:@"data"]&&[[self.dataDict objectForKey:@"data"] isKindOfClass:[NSArray class]]){
        
        [self log:@"dataArray" withString:@"succesfully!"];
        [self loadDataArray:[self.dataDict objectForKey:@"data"]];
        
    }else{
        [self fatalErrorHappenedWithReportString:@"Cannot load dataArray"];
        
        
    }
    
}


-(void)loadDataArray:(NSArray *)dataArray{
    BOOL isError;
    NSMutableDictionary *tmpDict,*resultDict=nil;
    for(int i=0;i<[dataArray count];i++){
        isError=NO;
        resultDict=nil;
        tmpDict=nil;
        if ([dataArray[i] isKindOfClass:[NSDictionary class]]){
            tmpDict=dataArray[i];
            resultDict=[NSMutableDictionary dictionary];
            if([tmpDict objectForKey:@"title"]&&[[tmpDict objectForKey:@"title"] isKindOfClass:[NSString class]]){
                [resultDict setObject:[tmpDict objectForKey:@"title"] forKey:@"title"];
            }else isError=YES;
            if([tmpDict objectForKey:@"value"]){
                [resultDict setObject:[NSNumber numberWithFloat:[[tmpDict objectForKey:@"value"] floatValue]] forKey:@"value"];
            }else isError=YES;
            if([tmpDict objectForKey:@"color"]&&[[tmpDict objectForKey:@"color"] isKindOfClass:[NSString class]]){
                [resultDict setObject:[ChartModelBase returnUIColorFromHTMLStr:[tmpDict objectForKey:@"color"]] forKey:@"color"];
            }else isError=YES;
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
    
    self.chartView=[[PieChartView alloc]initWithFrame:CGRectMake([[self getValueByName:@"left"] floatValue],
                                                                 [[self getValueByName:@"top"] floatValue],
                                                                 [[self getValueByName:@"width"] floatValue],
                                                                 [[self getValueByName:@"height"] floatValue])];
    
    
    
    _chartView.delegate =self.delegate;
    NSInteger dataCount=[self.characteristics count];
    NSMutableArray *yVals1 = [NSMutableArray array];
    NSMutableArray *xVals = [NSMutableArray array];
    NSMutableArray *colors = [NSMutableArray array];
    
    // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
    for (int i = 0; i < dataCount; i++)
    {
        [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:[[self.characteristics[i] objectForKey:@"value"] floatValue] xIndex:i]];
        [xVals addObject:[self.characteristics[i] objectForKey:@"title"]];
        [colors addObject:[self.characteristics[i] objectForKey:@"color"]];
    }
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithYVals:yVals1 label:@"Election Results"];
    
    dataSet.sliceSpace = 3.f;
    dataSet.colors=colors;
    dataSet.selectionShift=6;
    //showValue:,//(可选) 是否显示value，默认true
    dataSet.drawValuesEnabled= [[self getValueByName:@"showValue"] boolValue];
    
    PieChartData *data = [[PieChartData alloc] initWithXVals:xVals dataSet:dataSet];
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    
    
    
    
    
    
    //bgColor:,//(可选) 背景颜色，默认透明
    
    
    
    //showPercent:,//(可选) 是否用百分比代替value,默认true
    self.chartView.usePercentValuesEnabled = [[self getValueByName:@"showPercent"] boolValue];
    
    //showUnit:,//(可选) 是否显示单位，默认false
    //unit:,//(可选) 单位
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 2;
    pFormatter.multiplier = @1.f;
    if(self.chartView.usePercentValuesEnabled){
        pFormatter.percentSymbol = @" %";
    }else if([[self getValueByName:@"showUnit"] boolValue]){
        pFormatter.percentSymbol=[self getValueByName:@"unit"];
    }else{
        pFormatter.percentSymbol=@"";
    }
    
    [data setValueFormatter:pFormatter];
    
    //valueTextColor:,//(可选) 饼状图上值的文本颜色，默认#ffffff
    [data setValueTextColor:[self getValueByName:@"valueTextColor"]];
    
    
    //valueTextSize:,//(可选) 饼状图上值的字体大小，默认13
    [data setValueFont:[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"valueTextSize"] floatValue]]];
    
    //desc:,//(可选) 描述
    self.chartView.descriptionText = [self getValueByName:@"desc"];
    //descTextColor:,//(可选) 描述及图例文本颜色，默认#000000
    self.chartView.descriptionTextColor=[self getValueByName:@"descTextColor"];
    self.chartView.legend.textColor=[self getValueByName:@"descTextColor"];
    
    //descTextSize:,//(可选) 描述及图例字体大小，默认12
    self.chartView.descriptionFont=[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"descTextSize"] floatValue]];
    self.chartView.legend.font=[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"descTextSize"] floatValue]];

    
    //showLegend:,//(可选) 是否显示图例，默认false
    self.chartView.legend.enabled=[[self getValueByName:@"showLegend"] boolValue];
    //legendPosition:,//(可选) 图例显示的位置，取值范围：bottom-饼状图下方；right-饼状图右侧，默认bottom
    self.chartView.legend.position=[[self getValueByName:@"legendPosition"] integerValue];
    //showTitle:,//(可选) 是否显示title，默认true
    
    
    
    //showCenter:,//(可选) 是否显示中心圆，默认true
    self.chartView.drawHoleEnabled = [[self getValueByName:@"showCenter"] boolValue];
    
    //centerColor:,//(可选) 中心圆颜色，默认透明
    self.chartView.holeColor=[self getValueByName:@"centerColor"];
    
    self.chartView.tag = [self.identifier intValue];
    
    //centerTitle:,//(可选) 中心标题
    //centerSummary:,//(可选) 中心子标题
    
    NSMutableAttributedString *centerText=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n%@",[self getValueByName:@"centerTitle"],[self getValueByName:@"centerSummary"]]];
    NSRange range=NSMakeRange(0, centerText.length);
    [centerText addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.CSSFontName size:[[self getValueByName:@"descTextSize"] floatValue]] range:range];
    [centerText addAttribute:NSForegroundColorAttributeName value:[self getValueByName:@"descTextColor"] range:range];
    self.chartView.centerAttributedText=centerText;
    
    
    
    //centerRadius:,//(可选) 中心圆半径百分比，默认40
    self.chartView.holeRadiusPercent =([[self getValueByName:@"centerRadius"] floatValue]/100.f);
    //centerTransRadius:,//(可选) 中心圆半透明部分半径百分比，默认42
    self.chartView.transparentCircleRadiusPercent =([[self getValueByName:@"centerTransRadius"] floatValue]/100.f);
    
    
    
    
    
    self.chartView.drawCenterTextEnabled = YES;
    
    self.chartView.rotationAngle = 0.f;
    self.chartView.rotationEnabled = YES;
    
    self.chartView.holeTransparent =YES;
    self.chartView.legend.xEntrySpace = 7.f;
    self.chartView.legend.yEntrySpace = 5.f;
    self.chartView.data=data;
    [self.chartView setNeedsDisplay];
    
}



-(void)show{
    if(self.isFatalErrorHappened) return;
    
    
    //duration:,//(可选) 显示饼状图动画时间，单位ms，默认1000
    CGFloat duration=[[self getValueByName:@"duration"] floatValue]/1000.f;
    
    //isScrollWithWeb:,//(可选) 是否跟随网页滑动，默认false
    BOOL isScrollWithWeb=[[self getValueByName:@"isScrollWithWeb"] boolValue];
    
    [self.delegate uexChartShowChart:self.chartView WithId:self.identifier chartType:self.chartType isScrollWithWeb:isScrollWithWeb duration:duration];
    [self debugReport];
    
    
}


@end
