//
//  LineChart.swift
//  EUExChart
//
//  Created by CeriNo on 2016/11/1.
//  Copyright © 2016年 AppCan. All rights reserved.
//

import Foundation
import AppCanKit
import AppCanKitSwift
import Charts


class LineChart{
    struct Entity: JSArgummentConvertible {
        var lineName: String!
        var lineColor: UIColor!
        var lineWidth: CGFloat!
        var circleColor: UIColor!
        var circleSize: CGFloat!
        var isSolid = true
        var cubicIntensity: CGFloat = 0
        var data: [BarLineDataEntryGenerator.Unit] = []

        static func jsa_fromJSArgument(_ argument: JSArgumment) -> Entity? {
            var entity = Entity()
            guard
                entity.lineName <~ argument["lineName"],
                entity.lineColor <~ argument["lineColor"],
                entity.lineWidth <~ argument["lineWidth"],
                entity.circleColor <~ argument["circleColor"],
                entity.circleSize <~ argument["circleSize"],
                entity.data <~ argument["data"]
                else{
                return nil
            }
            entity.isSolid <~ argument["isSolid"]
            entity.cubicIntensity <~ argument["cubicIntensity"]
            return entity
        }
    }
    
    
    let view = LineChartView()
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


extension LineChart: BarLineChart{
    var barLineChartView: BarLineChartViewBase{
        get{
            return view
        }
    }
}




extension LineChart{
    func configureChartData(jsConfig: JSArgumment) {
        var dataSets = [LineChartDataSet]()
        let entryGenerator = BarLineDataEntryGenerator(jsConfig: jsConfig)
        guard let entities: [Entity] = ~jsConfig["lines"], entities.count > 0 else{
            return
        }
        var maxXCount = 0
        for entity in entities{
            let values = entryGenerator.generate(fromUnits: entity.data).map{ChartDataEntry(x: $0.x,y: $0.y)}
            maxXCount = max(maxXCount, values.count)
            let dataSet = LineChartDataSet(values: values, label: entity.lineName)
            dataSet.setCircleColor(entity.circleColor)
            dataSet.circleRadius = entity.circleSize
            dataSet.lineWidth = entity.lineWidth
            if !entity.isSolid{
                dataSet.lineDashLengths = [5,5]
            }
            if entity.cubicIntensity > 0{
                dataSet.mode = .cubicBezier
                dataSet.cubicIntensity = entity.cubicIntensity
            }
            dataSet.setColor(entity.lineColor, alpha: 1)
            dataSets.append(dataSet)
        }
        let data = LineChartData(dataSets: dataSets)
        data.setValueFont(formatData.valueFont)
        data.setValueTextColor(formatData.valueTextColor)
        data.highlightEnabled = true
        view.data = data

        view.xAxis.valueFormatter = entryGenerator.valueFormatter()
    }
}

extension LineChart: ChartViewDelegate{
    func chartValueSelected(_ chartView: Charts.ChartViewBase, entry: Charts.ChartDataEntry, highlight: Charts.Highlight){
        self.eventHandler?(ChartEvent.selected(entry: entry, highlight: highlight))
    }
}
