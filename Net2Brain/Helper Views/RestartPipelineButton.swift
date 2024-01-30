//
//  RestartPipelineButton.swift
//  Net2Brain
//
//  Created by Marco Weßel on 30.01.24.
//

import SwiftUI

struct RestartPipelineButton: View {
    @State var pipelineParameters: PipelineParameters
    @StateObject var pipelineData: PipelineData
    
    @Binding var path: NavigationPath
    
    @State private var showWarning = false
    
    var body: some View {
        Button("button.restart.title", systemImage: "restart", action: {
            showWarning.toggle()
        })
        .alert("pipeline.restart.alert.title", isPresented: $showWarning, actions: {
            Button("pipeline.restart.alert.cancel.button", role: .cancel, action: { })
            Button("pipeline.restart.alert.restart.button", role: .destructive, action: {
                pipelineParameters.resetAll()
                pipelineData.resetAll()
                path = NavigationPath([MenuTargetView.prediction])
            })
        }, message: {
            Text("pipeline.restart.alert.message")
        })
    }
}

#Preview {
    RestartPipelineButton(pipelineParameters: PipelineParameters(), pipelineData: PipelineData(), path: .constant(NavigationPath()))
}
