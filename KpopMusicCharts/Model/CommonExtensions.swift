//
//  CommonExtensions.swift
//  KpopMusicCharts
//
//  Created by HanaHan on 2021/01/17.
//

import Foundation

extension String {
    func getCurrentTime() -> String {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var currentTime = formatter.string(from: Date())
        return currentTime
    }
}

extension Int {
    func getRandomNumber(start : Int, end : Int) -> Int {
        let randomNumber = Int.random(in: start...end)
        return randomNumber
    }
}
