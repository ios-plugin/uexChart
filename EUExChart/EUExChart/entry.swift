//
//  entry.swift
//  EUExChart
//
//  Created by CeriNo on 2016/10/27.
//  Copyright © 2016年 AppCan. All rights reserved.
//

import Foundation
import AppCanKit
import AppCanKitSwift
import JavaScriptCore








@objc(EUExChart) class EUExChart: EUExBase{
    var charts = [String : Chart]()
    
    override func clean() {
        for chart in charts.values{
            chart.removeView()
        }
        charts.removeAll()
    }
    
    
    
    func openChart<T: Chart>(type: T.Type,jsConfig: JSArgumment){
        guard let chart = T.init(jsConfig: jsConfig) else {
            ACLogError("uexChart~> Invalid Chart Data")
            return
        }
        guard !charts.keys.contains(chart.id) else{
            ACLogError("uexChart~> Duplicated Chart id")
            return
        }
        chart.eventHandler = { [unowned self,chart] event in
            switch event {
            case .selected(_,let highlight):
                let dict = [
                    "id": chart.id,
                    "value": highlight.y,
                    "xIndex": highlight.x,
                    "dataSetIndex": highlight.dataSetIndex
                    ] as NSDictionary
                let jsStr: Any = dict.ac_JSONFragment() ?? NSNull()
                self.webViewEngine?.callback(withFunctionKeyPath: "uexChart.onValueSelected", arguments: [jsStr])
            }
            
        }

        if chart.isScrollWithWeb{
            self.webViewEngine?.webScrollView?.addSubview(chart.chartView)
        }else{
            self.webViewEngine?.webView?.addSubview(chart.chartView)
        }
        chart.animate()
        charts[chart.id] = chart
    }
    
    func removeChart<T: Chart>(type: T.Type ,ids: JSArgumment){
        let chartIds: [String] = ~ids ?? Array(charts.keys)
        for id in chartIds{
            if let chart = self.charts[id],chart is T{
                chart.removeView()
                self.charts[id] = nil
            }
        }
    }
    
    
    @objc func openPieChart(_ args: JSValue){
        openChart(type: PieChart.self , jsConfig: JSArgumment(args)[0])
    }
    
    @objc func closePieChart(_ args: JSValue){
        removeChart(type: PieChart.self, ids:  JSArgumment(args)[0])
    }
    @objc func openLineChart(_ args: JSValue){
        openChart(type: LineChart.self, jsConfig: JSArgumment(args)[0])
    }
    @objc func closeLineChart(_ args: JSValue){
        removeChart(type: LineChart.self, ids:  JSArgumment(args)[0])
    }

    @objc func openBarChart(_ args: JSValue){
        openChart(type: BarChart.self, jsConfig: JSArgumment(args)[0])
    }
    @objc func closeBarChart(_ args: JSValue){
        removeChart(type: BarChart.self, ids:  JSArgumment(args)[0])
    }
    

    
}








