//
//  Heatmaps.swift
//  Net2Brain
//
//  Created by Marco Weßel on 09.04.24.
//

import SwiftUI

struct Heatmaps {
    /// heatmap from matplotlib/nilearn ("cold_hot")
    let coldHotUI = [
        //UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.28409019, green: 1.0, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.71212101, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.23484906, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0, green: 0.0, blue: 0.75755961, alpha: 1.0),
        UIColor(red: 0.0, green: 0.0, blue: 0.2802532, alpha: 1.0),
        UIColor(red: 0.2802532, green: 0.0, blue: 0.0, alpha: 1.0),
        UIColor(red: 0.75755961, green: 0.0, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 0.23484906, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 0.71212101, blue: 0.0, alpha: 1.0),
        UIColor(red: 1.0, green: 1.0, blue: 0.28409019, alpha: 1.0)
        //UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    ]
    
    /// heatmap from matplotlib/nilearn ("cold_hot")
    let coldHot = [
        Color(red: 0.28409019, green: 1.0, blue: 1.0),
        Color(red: 0.0, green: 0.71212101, blue: 1.0),
        Color(red: 0.0, green: 0.23484906, blue: 1.0),
        Color(red: 0.0, green: 0.0, blue: 0.75755961),
        Color(red: 0.0, green: 0.0, blue: 0.2802532),
        Color(red: 0.2802532, green: 0.0, blue: 0.0),
        Color(red: 0.75755961, green: 0.0, blue: 0.0),
        Color(red: 1.0, green: 0.23484906, blue: 0.0),
        Color(red: 1.0, green: 0.71212101, blue: 0.0),
        Color(red: 1.0, green: 1.0, blue: 0.28409019),
    ]
    
    let accentColor = [
        Color.accentColor.opacity(0.3),
        Color.accentColor
    ]
    
    let accentColorBlack = [
        Color.white,
        Color.accentColor,
        Color.black
    ]
}
