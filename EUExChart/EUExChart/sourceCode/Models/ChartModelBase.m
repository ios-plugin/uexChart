//
//  ChartModelBase.m
//  EUExChart
//
//  Created by CC on 15/5/28.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "ChartModelBase.h"

@interface ChartViewBase()<ChartViewDelegate>





@end


@implementation ChartModelBase





-(instancetype)initWithScreenWidth:(CGFloat)width
                            Height:(CGFloat)height
                             debug:(BOOL)isDebug
                          delegate:(id<uexChartDelegate>)delegate{
    self=[super init];
    if(self){
        self.identifier=nil;
        self.delegate=delegate;
        self.CSSFontName=@"HelveticaNeue-Light";
        _modelItems=[NSMutableArray array];
        _characteristics=[NSMutableArray array];
        _debug=isDebug;
        if(_debug) _logArray =[NSMutableArray array];
        _screenHeight = height;
        _screenWidth = width;
        self.isFatalErrorHappened=NO;
        
        [self setupBaseItems];
        
    }
    return  self;
}


-(void)log:(NSString *)event withString:(NSString *)str{
    
    if(_debug){
        [_logArray addObject:[NSString stringWithFormat:@"%@ loaded %@",event,str]];
    }
    
    
}

-(void)setupBaseItems{
    [_modelItems addObject:[ChartModelItem itemWithValue:@0.f
                                                    name:@"left"
                                                    type:uexChartModelItemFloat]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@0.f
                                                    name:@"top"
                                                    type:uexChartModelItemFloat]];
    [_modelItems addObject:[ChartModelItem itemWithValue:[NSNumber numberWithFloat:_screenWidth]
                                                    name:@"width"
                                                    type:uexChartModelItemFloat]];
    [_modelItems addObject:[ChartModelItem itemWithValue:[NSNumber numberWithFloat:_screenHeight]
                                                    name:@"height"
                                                    type:uexChartModelItemFloat]];
    [_modelItems addObject:[ChartModelItem itemWithValue:[UIColor clearColor]
                                                    name:@"bgColor"
                                                    type:uexChartModelItemColor]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@""
                                                    name:@"unit"
                                                    type:uexChartModelItemString]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@NO
                                                    name:@"showUnit"
                                                    type:uexChartModelItemBool]];
    [_modelItems addObject:[ChartModelItem itemWithValue:[ChartModelBase returnUIColorFromHTMLStr:@"#ffffff"]
                                                    name:@"valueTextColor"
                                                    type:uexChartModelItemColor]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@13
                                                    name:@"valueTextSize"
                                                    type:uexChartModelItemInteger]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@""
                                                    name:@"desc"
                                                    type:uexChartModelItemString]];
    [_modelItems addObject:[ChartModelItem itemWithValue:[ChartModelBase returnUIColorFromHTMLStr:@"#000000"]
                                                    name:@"descTextColor"
                                                    type:uexChartModelItemColor]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@12
                                                    name:@"descTextSize"
                                                    type:uexChartModelItemInteger]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@YES
                                                    name:@"showValue"
                                                    type:uexChartModelItemBool]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@NO
                                                    name:@"showLegend"
                                                    type:uexChartModelItemBool]];
    [_modelItems addObject:[ChartModelItem itemWithValue:[NSNumber numberWithInteger:ChartLegendPositionRightOfChart]
                                                    name:@"legendPosition"
                                                    type:uexChartModelItemPosition]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@1000
                                                    name:@"duration"
                                                    type:uexChartModelItemInteger]];
    [_modelItems addObject:[ChartModelItem itemWithValue:@NO
                                                    name:@"isScrollWithWeb"
                                                    type:uexChartModelItemBool]];
    
    
    
    
}

-(ChartModelItem *)getItemByName:(NSString *)aName{
    for(int i=0;i<[_modelItems count];i++){
        ChartModelItem *modelItem=_modelItems[i];
        if([modelItem.name isEqual:aName]){
            return modelItem;
        }
        
        
        
    }
    return nil;
}


-(id)getValueByName:(NSString *)aName{
    ChartModelItem *modelItem=[self getItemByName:aName];
    if(modelItem){
        return modelItem.value;
    }
    return nil;
}


-(void)showWithDataDictionary:(NSDictionary *)dataDict{
    self.dataDict=dataDict;
    [self loadCoreData];
    [self loadOptionalData];
    [self prepareToShow];
    [self show];
    
}


-(void)loadCoreData{
    //an empty method
    return;
}

-(void)prepareToShow{
    //an empty method
    return;
}

-(void)loadOptionalData{
    if(self.isFatalErrorHappened){
        return;
    }
    
    
    //load optional data
    for(int i=0;i<[_modelItems count];i++){
        ChartModelItem *modelItem=_modelItems[i];
        NSString *name=modelItem.name;
        
        
        if([self.dataDict objectForKey:name]){
            [self setValue:[self.dataDict objectForKey:name] forItem:modelItem];
        }
    }
    
}
-(void)show{
    //an empty method
    return;
}


-(void)setValue:(id)value forItem:(ChartModelItem *)aItem{
    NSInteger positionCode=-1;
    switch (aItem.type) {
        case uexChartModelItemBool:
            // value =[value lowercaseString];
            if([value integerValue]==1||[value isEqual:@"true"]){
                aItem.value=[NSNumber numberWithBool:YES];
                [self log:aItem.name withString:@"succesfully with bool value:true"];
            }else if([value integerValue]==0||[value isEqual:@"false"]){
                aItem.value=[NSNumber numberWithBool:NO];
                [self log:aItem.name withString:@"succesfully with bool value:false"];
            }else {
                [self log:aItem.name withString:@"failed,unrecognized bool value!"];
            }
            break;
        case uexChartModelItemColor:
            
            aItem.value=[ChartModelBase returnUIColorFromHTMLStr:value];
            [self log:aItem.name withString:[NSString stringWithFormat:@"with color:%@",value]];
            break;
        case uexChartModelItemFloat:
            aItem.value=[NSNumber numberWithFloat:[value floatValue]];
            [self log:aItem.name withString:[NSString stringWithFormat:@"with float value:%@",value]];
            break;
        case uexChartModelItemInteger:
            aItem.value=[NSNumber numberWithInteger:[value integerValue]];
            [self log:aItem.name withString:[NSString stringWithFormat:@"with integer value:%@",value]];
            break;
        case uexChartModelItemString:
            aItem.value=[NSString stringWithFormat:@"%@",value];
            [self log:aItem.name withString:[NSString stringWithFormat:@"with string value:%@",value]];
            break;
        case uexChartModelItemPosition:
            if([[value lowercaseString] isEqual:@"right"]){
                positionCode=0;
            }else if([[value lowercaseString] isEqual:@"bottom"]){
                positionCode=8;
            }else {
                positionCode=[value integerValue];
                if(positionCode >9){
                    positionCode =-1;
                }
            }
            if(positionCode <0){
                [self log:aItem.name withString:@"failed,unrecognized position type!"];
            }else{
                aItem.value=[NSNumber numberWithInteger:positionCode];
                [self log:aItem.name withString:[NSString stringWithFormat:@"successfully with positionCode:%ld",(long)positionCode]];
            }
            
            break;
        case uexChartModelItemOptionalObject:
            aItem.value=value;
            [self log:aItem.name withString:nil];
            break;
        default:
            [self log:@"ITEM" withString:@"FAILED!!UNDEFINED ITEM TYPES!"];
            break;
    }
    
    
}

/*
 yValue:8.9,
 lineName:"优秀",
 lineColor:"#0f0",
 textColor:"#0f0",
 textSize:12,
 isSolid:false,
 lineWidth:4
 */
-(NSArray *)loadExtraLines:(NSArray *)array{
    NSMutableArray *extras=[NSMutableArray array];
    
    for(NSDictionary *dict in array){
        
        BOOL isError =NO;
        ChartLimitLine *extraLine=[[ChartLimitLine alloc] init];
        if([dict objectForKey:@"yValue"]){
            extraLine.limit=[[dict objectForKey:@"yValue"] floatValue];
        }else isError=YES;
        
        if([dict objectForKey:@"lineName"]){
            extraLine.label=[dict objectForKey:@"lineName"];
        }
        
        if([dict objectForKey:@"lineColor"]){
            extraLine.lineColor=[ChartModelBase returnUIColorFromHTMLStr:[dict objectForKey:@"lineColor"]];
        }
        
        if([dict objectForKey:@"textColor"]){
            extraLine.valueTextColor=[ChartModelBase returnUIColorFromHTMLStr:[dict objectForKey:@"textColor"]];
        }
        
        if([dict objectForKey:@"textSize"]){
            extraLine.valueFont=[UIFont fontWithName:self.CSSFontName size:[[dict objectForKey:@"textSize"] floatValue]];
        }
        
        if([dict objectForKey:@"lineWidth"]){
            extraLine.lineWidth=[[dict objectForKey:@"lineWidth"] floatValue];
        }
        if([dict objectForKey:@"isSolid"]){
            id isSolid=[dict objectForKey:@"isSolid"];
            if(![isSolid boolValue]||[isSolid isEqual:@"false"]){
                extraLine.lineDashLengths=@[@5.f, @5.f];
            }
            
        }
        if(!isError) [extras addObject:extraLine];
        
    }
    
    
    
    return extras;
}

-(void)fatalErrorHappenedWithReportString:(NSString *)reportStr{
    if(_debug){
        [_logArray addObject:[NSString stringWithFormat:@"FATAL ERROR HAPPENED!%@",reportStr]];
    }
    self.isFatalErrorHappened=YES;
    if([self.delegate respondsToSelector:@selector(uexChartDidFatalErrorHappen:fromChartId:chartType:)]){
        [self.delegate uexChartDidFatalErrorHappen:reportStr fromChartId:self.identifier chartType:self.chartType];
    }
    
    
    [self debugReport];
}


-(void)debugReport{
    if(self.debug && [self.delegate respondsToSelector:@selector(uexChartWillReportLog:fromChartId:chartType:)]){
        [self.delegate uexChartWillReportLog:self.logArray fromChartId:self.identifier chartType:self.chartType];
    }
}

#define CLEAR return [UIColor clearColor]


+(UIColor *)returnUIColorFromHTMLStr:(NSString *)colorString{
    colorString=[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([colorString hasPrefix:@"#"]){
        
        unsigned int r,g,b,a;
        
        NSRange range;
        NSMutableArray *colorArray=[NSMutableArray arrayWithCapacity:4];
        switch ([colorString length]) {
            case 4://"#123"型字符串
                [colorArray addObject:@"ff"];
                for(int k=0;k<3;k++){
                    range.location=k+1;
                    range.length=1;
                    NSMutableString *tmp=[[colorString substringWithRange:range] mutableCopy];
                    [tmp  appendString:tmp];
                    [colorArray addObject:tmp];
                    
                }
                break;
            case 7://"#112233"型字符串
                [colorArray addObject:@"ff"];
                for(int k=0;k<3;k++){
                    range.location=2*k+1;
                    range.length=2;
                    [colorArray addObject:[colorString substringWithRange:range]];
                    
                }
                break;
            case 9://"#11223344"型字符串
                for(int k=0;k<4;k++){
                    range.location=2*k+1;
                    range.length=2;
                    [colorArray addObject:[colorString substringWithRange:range]];
                }
                break;
                
            default:
                CLEAR;
                break;
        }
        [[NSScanner scannerWithString:colorArray[0]] scanHexInt:&a];
        [[NSScanner scannerWithString:colorArray[1]] scanHexInt:&r];
        [[NSScanner scannerWithString:colorArray[2]] scanHexInt:&g];
        [[NSScanner scannerWithString:colorArray[3]] scanHexInt:&b];
        
        return [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:(float)a/255.0];
    }
    if (([colorString hasPrefix:@"RGB("]||[colorString hasPrefix:@"rgb("])&&[colorString hasSuffix:@")"]){
        colorString=[colorString substringWithRange:NSMakeRange(4, [colorString length] -5)];
        return [self returnColorWithRGBAArray:[colorString componentsSeparatedByString:@","]];
    }
    if (([colorString hasPrefix:@"RGBA("]||[colorString hasPrefix:@"rgba("])&&[colorString hasSuffix:@")"]){
        colorString=[colorString substringWithRange:NSMakeRange(5, [colorString length] -6)];
        return [self returnColorWithRGBAArray:[colorString componentsSeparatedByString:@","]];
    }
    CLEAR;
    
    
}

+(UIColor*) returnColorWithRGBAArray:(NSArray *)rgbaStr{
    if([rgbaStr count]<3) CLEAR;
    NSMutableArray *rgb=[NSMutableArray array];
    NSString *alpha=@"1";
    if([rgbaStr count]>3 && [rgbaStr[3] isKindOfClass:[NSString class]]){
        alpha=[rgbaStr[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    for(int i=0;i<3;i++) {
        if(![rgbaStr[i] isKindOfClass:[NSString class]]) CLEAR;
        NSString *str=rgbaStr[i];
        str=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([str hasSuffix:@"%"]){
            str=[str substringWithRange:NSMakeRange(0, [str length] - 1)];
            [rgb addObject:[NSNumber numberWithFloat:([str floatValue]*255.0f/100.0f)]];
        }else{
            [rgb addObject:[NSNumber numberWithFloat:[str floatValue]]];
        }
    }
    return [UIColor colorWithRed:[rgb[0] floatValue] green:[rgb[1] floatValue] blue:[rgb[2] floatValue] alpha:[alpha floatValue]];
    
    
}

@end
