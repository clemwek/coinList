//
//  PerformanceChartView.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import SwiftUI
import Charts

struct PerformanceChartView: View {
  let data: [Double]

  var body: some View {
    Chart {
      ForEach(Array(data.enumerated()), id: \.offset) { idx, val in
        LineMark(
          x: .value("Index", idx),
          y: .value("Price", val)
        )
      }
    }
    .chartYAxis { AxisMarks(position: .leading) }
    .padding()
  }
}

#Preview {
  PerformanceChartView(data: [2.5, 4.5, 6.5, 8.5, 10.5])
}
