//
//  PieChart.swift
//  EUExChart
//
//  Created by CeriNo on 2016/10/27.
//  Copyright © 2016年 AppCan. All rights reserved.
//

import Foundation
import AppCanKit
import AppCanKitSwift
import Charts

class PieChart{
    struct Entity: JSArgumentConvertible{
        var title: String!
        var color: UIColor!
        var value: Double!
        static func jsa_fromJSArgument(_ argument: JSArgument) -> Entity? {
            var entity = Entity()
            guard
                entity.color <~ argument["color"],
                entity.title <~ argument["title"],
                entity.value <~ argument["value"]
                else{
                    return nil
            }
            return entity
        }
    }

    
    let view = PieChartView()
    var showPercent = false
    var eventHandler: ChartEvent.Handler?
    var id: String!
    var isScrollWithWeb = false
    var duration: TimeInterval!
    var formatData: FormatData!

    
    required init?(jsConfig: JSArgument){
        guard self.initialize(jsConfig: jsConfig) else{
            return nil
        }
        view.delegate = self
        var holeColor = UIColor.clear
        holeColor <~ jsConfig["centerColor"]
        view.holeColor = holeColor
        view.rotationAngle = 0
        view.rotationEnabled = true
        view.highlightPerTapEnabled = true
        showPercent <~ jsConfig["showPercent"]
        view.usePercentValuesEnabled = showPercent
        configureFrame(jsConfig: jsConfig)
        configureLegend(jsConfig: jsConfig)
        configureDescription(jsConfig: jsConfig)
        configureBackgroundColor(jsConfig: jsConfig)
        configureHole(jsConfig: jsConfig)
        configureCenterString(jsConfig: jsConfig)
        configureChartData(jsConfig: jsConfig)
        
    }

}
extension PieChart: Chart{
    var chartView: ChartViewBase{
        get{
            return view
        }
    }
}




extension PieChart{
    func configureHole(jsConfig: JSArgument){
        view.drawHoleEnabled = ~jsConfig["showCenter"] ?? true
        view.holeColor <~ jsConfig["centerColor"]
        let centerRadius: CGFloat = ~jsConfig["centerRadius"] ?? 40
        let centerTransRadius: CGFloat = ~jsConfig["centerTransRadius"] ?? 42
        view.holeRadiusPercent = centerRadius / 100
        view.transparentCircleRadiusPercent = centerTransRadius / 100
        
    }
    func configureCenterString(jsConfig: JSArgument){
        let centerTitle = ~jsConfig["centerTitle"] ?? ""
        let centerSummary = ~jsConfig["centerSummary"] ?? ""
        let str = NSMutableAttributedString(string: "\(centerTitle)\n\(centerSummary)")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        str.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, str.length))
        let range = NSMakeRange(0, centerTitle.characters.count)
        str.addAttribute(NSFontAttributeName, value: formatData.descFont, range: range)
        str.addAttribute(NSForegroundColorAttributeName, value: formatData.descTextColor, range: range)
        view.centerAttributedText = str
        view.drawCenterTextEnabled <~ jsConfig["showTitle"]
    }
    func configureChartData(jsConfig: JSArgument){
        
        guard let entities: [Entity] = ~jsConfig["data"] ,entities.count > 0 else{
            return
        }
        var dataArray = [PieChartDataEntry]()
        var colorArray = [UIColor]()
        for entity in entities{
            dataArray.append(PieChartDataEntry(value: entity.value, label: entity.title))
            colorArray.append(entity.color)
        }
        let dataSet = PieChartDataSet(values: dataArray, label: "")
        dataSet.colors = colorArray
        dataSet.sliceSpace = 3.0
        dataSet.selectionShift = 6
        dataSet.valueTextColor = formatData.valueTextColor
        dataSet.valueFont = formatData.valueFont
        dataSet.drawValuesEnabled = formatData.showValue
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumIntegerDigits = 10
        formatter.maximumFractionDigits = 2
        if showPercent{
            formatter.percentSymbol = "%"
            formatter.multiplier = 1.0
        }else if formatData.showUnit{
            formatter.percentSymbol = formatData.unit
        }else{
            formatter.percentSymbol = ""
        }
        
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        let chartData = PieChartData(dataSet: dataSet)
        view.data = chartData
    }
}



extension PieChart: ChartViewDelegate{
    func chartValueSelected(_ chartView: Charts.ChartViewBase, entry: Charts.ChartDataEntry, highlight: Charts.Highlight){
        self.eventHandler?(ChartEvent.selected(entry: entry, highlight: highlight))
    }
}







