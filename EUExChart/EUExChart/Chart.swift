//
//  Chart.swift
//  EUExChart
//
//  Created by CeriNo on 2016/10/31.
//  Copyright © 2016年 AppCan. All rights reserved.
//

import Foundation
import AppCanKit
import AppCanKitSwift
import Charts

enum ChartEvent{
    typealias Handler = (_ event: ChartEvent) -> ()
    case selected(entry: ChartDataEntry, highlight: Highlight)
}


struct FormatData{
    var showUnit = false
    var unit = ""
    var showValue = true
    var valueTextColor = UIColor.white
    var valueTextSize: CGFloat = 13
    var descTextSize: CGFloat = 12
    var descTextColor: UIColor = UIColor.black
    
    init(jsConfig: JSArgumment) {
        showUnit <~ jsConfig["showUnit"]
        unit <~ jsConfig["unit"]
        showValue <~ jsConfig["showValue"]
        valueTextColor <~ jsConfig["valueTextColor"]
        valueTextSize <~ jsConfig["valueTextSize"]
        descTextSize <~ jsConfig["descTextSize"]
        descTextColor <~ jsConfig["descTextColor"]
    }
}
extension FormatData{
    var descFont: UIFont{
        get{
            return UIFont.systemFont(ofSize: descTextSize)
        }
    }
    var valueFont: UIFont{
        get{
            return UIFont.systemFont(ofSize: valueTextSize)
        }
    }
}




enum LegendPosition: String{
    case bottom
    case right
    init(jsConfig: JSArgumment){
        if let positionStr: String = ~jsConfig["legendPosition"],let position = LegendPosition(rawValue: positionStr.lowercased()){
            self = position
        }else{
            self = .bottom
        }
    }
}








protocol Chart: class{
    var eventHandler: ChartEvent.Handler? {get set}
    var chartView: ChartViewBase {get}
    var id: String! {get set}
    var isScrollWithWeb: Bool {get set}
    var duration: TimeInterval! {get set}
    var formatData: FormatData! {get set}
    init?(jsConfig: JSArgumment)

}

extension Chart{

    func animate(){
        let durationSeconds = duration / 1000
        chartView.animate(xAxisDuration: durationSeconds, yAxisDuration: durationSeconds)
    }
    func removeView(){
        chartView.removeFromSuperview()
    }
}


extension Chart{
    func initialize(jsConfig: JSArgumment) -> Bool {
        guard  id <~ jsConfig["id"] else {
            return false
        }
        isScrollWithWeb <~ jsConfig["isScrollWithWeb"]
        duration = ~jsConfig["duration"] ?? 1000                //默认1000ms
        formatData = FormatData(jsConfig: jsConfig)
        return true
    }
    

    
    
    func configureFrame(jsConfig: JSArgumment){
        var frame = UIScreen.main.bounds    //默认全屏
        frame.origin.x      <~ jsConfig["left"]
        frame.origin.y      <~ jsConfig["top"]
        frame.size.width    <~ jsConfig["width"]
        frame.size.height   <~ jsConfig["height"]
        chartView.frame = frame
    }
    
    func configureBackgroundColor(jsConfig: JSArgumment){
        var bgColor = UIColor.clear
        bgColor <~ jsConfig["bgColor"]
        chartView.backgroundColor = bgColor
    }
    
    func configureLegend(jsConfig: JSArgumment) {
        chartView.legend.enabled = ~jsConfig["showLegend"] ?? false
        let position = LegendPosition(jsConfig: jsConfig)
        switch position {
        case .bottom:
            chartView.legend.verticalAlignment = .bottom
        case .right:
            chartView.legend.horizontalAlignment = .right
        }
        chartView.legend.xEntrySpace = 7
        chartView.legend.yEntrySpace = 5
        chartView.legend.font = formatData.descFont
    }
    
    func configureDescription(jsConfig: JSArgumment){
        let desc = Charts.Description()
        desc.text <~ jsConfig["desc"]
        desc.font = formatData.descFont
        desc.textColor = formatData.descTextColor
        chartView.chartDescription = desc
        
    }
    
}


struct ExtraLineData: JSArgummentConvertible{
    var limit: Double!
    var label: String!
    var lineColor: UIColor?
    var lineWidth: CGFloat?
    var valueTextColor: UIColor?
    var fontSize: CGFloat?
    var isSolid = true
    
    static func jsa_fromJSArgument(_ argument: JSArgumment) -> ExtraLineData? {
        var data = ExtraLineData()
        guard
            data.limit <~ argument["yValue"],
            data.label <~ argument["lineName"]
            else{
                return nil
        }
        data.lineColor <~ argument["lineColor"]
        data.lineWidth <~ argument["lineWidth"]
        data.valueTextColor <~ argument["textColor"]
        data.isSolid <~ argument["isSolid"]
        return data
    }
    
    func toLimitLine() -> ChartLimitLine{
        let line = ChartLimitLine(limit: limit, label: label)
        if let lineColor = lineColor{
            line.lineColor = lineColor
        }
        if let lineWidth = lineWidth{
            line.lineWidth = lineWidth
        }
        if let valueTextColor = valueTextColor{
            line.valueTextColor = valueTextColor
        }
        if let fontSize = fontSize{
            line.valueFont = UIFont.systemFont(ofSize: fontSize)
        }
        if isSolid{
            line.lineDashLengths = [5,5]
        }
        return line
    }
}


struct BarLineChartOptions{
    var initZoomX: CGFloat = 1
    var initZoomY: CGFloat = 1
    var initPositionX: CGFloat = 0
    var initPositionY: CGFloat = 0
    var isSupportDrag = true
    var isSupportZoomX = true
    var isSupportZoomY = true
    
    init(jsConfig: JSArgumment){
        initZoomX <~ jsConfig["initZoomX"]
        initZoomY <~ jsConfig["initZoomY"]
        initPositionX <~ jsConfig["initPositionX"]
        initPositionY <~ jsConfig["initPositionY"]
        isSupportDrag <~ jsConfig["isSupportDrag"]
        isSupportZoomX <~ jsConfig["isSupportZoomX"]
        isSupportZoomY <~ jsConfig["isSupportZoomY"]
    }
    
    
}

class BarLineDataEntryGenerator{
    struct Unit : JSArgummentConvertible{
        var xValue: String!
        var yValue: Double!
        static func jsa_fromJSArgument(_ argument: JSArgumment) -> Unit? {
            var unit = Unit()
            if unit.xValue <~ argument["xValue"],unit.yValue <~ argument["yValue"] {
                return unit
            }
            return nil
        }
    }
    struct Entry {
        let x: Double
        let y: Double
    }
    
    
    class XValueFormatter: NSObject,IAxisValueFormatter {
        let xValues: [String]
        init(xValues: [String]){
            self.xValues = xValues
        }
        func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String{
            let index = Int(value)
            if index >= 0 && index < xValues.count{
                return xValues[index]
            }
            return ""
        }
    }
    
    
    let userCustomized: Bool
    var xValues = [String]()
    
    init(jsConfig: JSArgumment){
        userCustomized = xValues <~ jsConfig["xData"]
    }
    func generate(fromUnits units: [Unit]) -> [Entry]{
        var result = [Entry]()
        for unit in units{
            if let index = xValues.index(of: unit.xValue){
                result.append(Entry(x: Double(index), y: unit.yValue))
                continue
            }
            if userCustomized{
                continue
            }
            xValues.append(unit.xValue)
            result.append(Entry(x: Double(xValues.count - 1), y: unit.yValue))
        }
        return result
    }
    func valueFormatter() -> XValueFormatter{
        return XValueFormatter(xValues: xValues)
    }
    
}



protocol BarLineChart: Chart{
    var barLineChartView: BarLineChartViewBase {get}
}



extension BarLineChart{

    var chartView: ChartViewBase{
        get{
            return barLineChartView
        }
    }
    
    func configureBackgroundColor(jsConfig: JSArgumment){
        var bgColor = UIColor.clear
        bgColor <~ jsConfig["bgColor"]
        barLineChartView.backgroundColor = bgColor
        barLineChartView.gridBackgroundColor = bgColor
    }
    
    func configureBorder(jsConfig: JSArgumment) {
        var borderColor = UIColor.black
        borderColor <~ jsConfig["borderColor"]
        barLineChartView.drawBordersEnabled = true
        
        let leftAxis = barLineChartView.leftAxis
        leftAxis.labelFont = formatData.descFont
        leftAxis.labelTextColor = formatData.valueTextColor
        leftAxis.gridColor = borderColor
        leftAxis.axisLineColor = borderColor
        //leftAxis.drawGridLinesEnabled = true;
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 5
        let symbol = formatData.showUnit ? formatData.unit : ""
        formatter.negativeSuffix = symbol
        formatter.positiveSuffix = symbol
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        leftAxis.labelPosition = .outsideChart
        if let minValue: Double = ~jsConfig["minValue"]{
            leftAxis.axisMinimum = minValue
        }
        if let maxValue: Double = ~jsConfig["maxValue"]{
            leftAxis.axisMaximum = maxValue
        }
        if let extraLines: [ExtraLineData] = ~jsConfig["extraLines"]{
            for lineData in extraLines{
                leftAxis.addLimitLine(lineData.toLimitLine())
            }
        }
        
        let rightAxis = barLineChartView.rightAxis
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawGridLinesEnabled = false

        let xAxis = chartView.xAxis
        xAxis.labelFont = formatData.descFont
        xAxis.labelTextColor = formatData.valueTextColor
        xAxis.gridColor = borderColor
        xAxis.axisLineColor = borderColor
        xAxis.labelPosition = .bottom
        
    }
    
    func configureOptions(jsConfig: JSArgumment){
        let option = BarLineChartOptions(jsConfig: jsConfig["option"])
        barLineChartView.dragEnabled = option.isSupportDrag
        barLineChartView.scaleXEnabled = option.isSupportZoomX
        barLineChartView.scaleYEnabled = option.isSupportZoomY
        barLineChartView.zoom(scaleX: option.initZoomX, scaleY: option.initZoomY, x: option.initPositionX, y: option.initPositionY)
    }
}







infix operator <~
@discardableResult
func <~ (_ left: inout UIColor,_ right: JSArgumment) -> Bool{
    if
        let colorString: String = ~right,
        let color = UIColor.ac_Color(withHTMLColorString: colorString){
        left = color
        return true
    }
    return false
}
@discardableResult
func <~ (_ left: inout UIColor!,_ right: JSArgumment) -> Bool{
    if
        let colorString: String = ~right,
        let color = UIColor.ac_Color(withHTMLColorString: colorString){
        left = color
        return true
    }
    return false
}

func <~ (_ left: inout UIColor?,_ right: JSArgumment){
    if
        let colorString: String = ~right,
        let color = UIColor.ac_Color(withHTMLColorString: colorString){
        left = color
    }
}
