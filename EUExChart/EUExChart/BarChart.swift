//
//  BarChart.swift
//  EUExChart
//
//  Created by CeriNo on 2016/11/2.
//  Copyright © 2016年 AppCan. All rights reserved.
//


import Foundation
import AppCanKit
import AppCanKitSwift
import Charts


class BarChart{
    struct Entity: JSArgummentConvertible {
        var barName: String!
        var barColor: UIColor!
        var data: [BarLineDataEntryGenerator.Unit] = []
        
        static func jsa_fromJSArgument(_ argument: JSArgumment) -> Entity? {
            var entity = Entity()
            guard
                entity.barName <~ argument["barName"],
                entity.barColor <~ argument["barColor"],
                entity.data <~ argument["data"]
                else{
                    return nil
            }
            return entity
        }
    }
    
    
    
    let view = BarChartView()
    var eventHandler: ChartEvent.Handler?
    var id: String!
    var isScrollWithWeb = false
    var duration: TimeInterval!
    var formatData: FormatData!
    
    required init?(jsConfig: JSArgumment){
        guard self.initialize(jsConfig: jsConfig) else{
            return nil
        }
        view.delegate = self
        view.highlightPerTapEnabled = true
        view.highlightPerDragEnabled = true 
        
        configureFrame(jsConfig: jsConfig)
        configureLegend(jsConfig: jsConfig)
        configureDescription(jsConfig: jsConfig)
        configureBackgroundColor(jsConfig: jsConfig)
        configureBorder(jsConfig: jsConfig)
        configureChartData(jsConfig: jsConfig)
        configureOptions(jsConfig: jsConfig)
        
    }
}

extension BarChart: BarLineChart{
    var barLineChartView: BarLineChartViewBase{
        get{
            return view
        }
    }
}


extension BarChart{
    func configureChartData(jsConfig: JSArgumment) {
        var dataSets = [BarChartDataSet]()
        let entryGenerator = BarLineDataEntryGenerator(jsConfig: jsConfig)
        guard let entities: [Entity] = ~jsConfig["bars"] ,entities.count > 0 else{
            return
        }
        var maxXCount = 0
        for entity in entities{
            let values = entryGenerator.generate(fromUnits: entity.data).map{BarChartDataEntry(x: $0.x,y: $0.y)}
            maxXCount = max(maxXCount, values.count)
            let dataSet = BarChartDataSet(values: values, label: entity.barName)
            dataSet.setColor(entity.barColor)
            dataSets.append(dataSet)
        }

        let data = BarChartData(dataSets: dataSets)
        let count = Double(dataSets.count)
        
        if count > 1{
            //group bars
            let groupSpace = 0.08
            let barSpace = (1 - groupSpace) / count * 0.2
            let barWidth = (1 - groupSpace) / count * 0.8
            data.barWidth = barWidth;
            data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
            view.xAxis.axisMinimum = 0
            view.xAxis.axisMaximum = 0 + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(maxXCount)
            view.xAxis.centerAxisLabelsEnabled = true
        }else{
            view.xAxis.drawGridLinesEnabled = false
        }
        
        
        
        data.setValueFont(formatData.valueFont)
        data.setValueTextColor(formatData.valueTextColor)
        data.highlightEnabled = true
        
        view.data = data
        
        view.xAxis.setLabelCount(maxXCount, force: false)
        view.xAxis.valueFormatter = entryGenerator.valueFormatter()
        
    }
}

extension BarChart: ChartViewDelegate{
    func chartValueSelected(_ chartView: Charts.ChartViewBase, entry: Charts.ChartDataEntry, highlight: Charts.Highlight){
        self.eventHandler?(ChartEvent.selected(entry: entry, highlight: highlight))
    }
}

