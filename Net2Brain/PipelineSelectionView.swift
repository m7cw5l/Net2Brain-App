//
//  PipelineSelectionView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 28.11.23.
//

import SwiftUI

struct PipelineSelectionView: View {
    
    @Binding var pipelineParameters: PipelineParameters
    var currentlySelectedParameter: PipelineParameter
    
    var body: some View {
        VStack(spacing: 6) {
            PipelineSelectionRow(title: "Dataset", description: parameterValueText(.dataset))
                .foregroundStyle(parameterForegroundStyle(.dataset))
            PipelineSelectionRow(title: "Images", description: parameterValueText(.images))
                .foregroundStyle(parameterForegroundStyle(.images))
            Divider()
            PipelineSelectionRow(title: "ML Model", description: parameterValueText(.mlModel))
                .foregroundStyle(parameterForegroundStyle(.mlModel))
            /*PipelineSelectionRow(title: pipelineParameters.mlModelLayers.count == 1 ? "ML Model Layer" : "ML Model Layers", description: pipelineParameters.mlModel.name == "" ? "select a ML Model" : pipelineParameters.mlModelLayers.count == 0 ? "select model layers" : pipelineParameters.mlModelLayers.count == 1 ? (pipelineParameters.mlModelLayers.first ?? N2BMLLayer(name: "", description: "", coremlKey: "")).name : "\(pipelineParameters.mlModelLayers.count) Layers")
                .foregroundStyle(parameterForegroundStyle(.mlModelLayer))*/
            PipelineSelectionRow(title: pipelineParameters.mlModelLayers.count == 1 ? "ML Model Layer" : "ML Model Layers", description: parameterValueText(.mlModelLayer))
                .foregroundStyle(parameterForegroundStyle(.mlModelLayer))
            Divider()
            PipelineSelectionRow(title: "RDM Metric", description: parameterValueText(.rdmMetric))
                .foregroundStyle(parameterForegroundStyle(.rdmMetric))
            Divider()
            PipelineSelectionRow(title: "Evaluation Type", description: parameterValueText(.evaluationType))
                .foregroundStyle(parameterForegroundStyle(.evaluationType))
        }.padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
            .border(Color.clear, width: 0)
            .padding()
    }
    
    func datasetEmpty() -> Bool {
        return pipelineParameters.dataset.name == ""
    }
    
    func imagesEmpty() -> Bool {
        return pipelineParameters.datasetImages.count == 0
    }
    
    func mlModelEmpty() -> Bool {
        return pipelineParameters.mlModel.name == ""
    }
    
    func mlModelLayerEmpty() -> Bool {
        return pipelineParameters.mlModelLayers.count == 0
    }
    
    func rdmMetricEmpty() -> Bool {
        return pipelineParameters.rdmMetric.name == ""
    }
    
    func evaluationTypeEmpty() -> Bool {
        return pipelineParameters.evaluationType.name == ""
    }
    
    func evaluationParameterEmpty() -> Bool {
        return pipelineParameters.evaluationParameter.name == ""
    }
    
    func isParameterEmpty(_ parameter: PipelineParameter) -> Bool {
        switch parameter {
        case .none:
            return true
        case .dataset:
            return datasetEmpty()
        case .images:
            return imagesEmpty()
        case .mlModel:
            return mlModelEmpty()
        case .mlModelLayer:
            return mlModelLayerEmpty()
        case .rdmMetric:
            return rdmMetricEmpty()
        case .evaluationType:
            return evaluationTypeEmpty()
        case .evaluationParameter:
            return evaluationParameterEmpty()
        }
    }
    
    func valueForParameter(_ parameter: PipelineParameter) -> String {
        switch parameter {
        case .none:
            return ""
        case .dataset:
            return pipelineParameters.dataset.name
        case .images:
            return pipelineParameters.datasetImages.count == 1 ? "1 image" : "\(pipelineParameters.datasetImages.count) images"
        case .mlModel:
            return pipelineParameters.mlModel.name
        case .mlModelLayer:
            return pipelineParameters.mlModelLayers.count == 1 ? (pipelineParameters.mlModelLayers.first ?? N2BMLLayer(name: "", description: "", coremlKey: "")).name : "\(pipelineParameters.mlModelLayers.count) layers"
        case .rdmMetric:
            return pipelineParameters.rdmMetric.name
        case .evaluationType, .evaluationParameter:
            return "\(pipelineParameters.evaluationType.name) – \(pipelineParameters.evaluationParameter.name)"
        }
    }
    
    func parameterValueText(_ parameter: PipelineParameter) -> String {
        return isParameterEmpty(parameter) ? parameter == currentlySelectedParameter ? "select \(parameter.rawValue)" : "will be selected later" : valueForParameter(parameter)
    }
    
    func parameterForegroundStyle(_ parameter: PipelineParameter) -> Color {
        if parameter == currentlySelectedParameter {
            // Accent
            return Color.accent
        } else {
            if isParameterEmpty(parameter) {
                // Secondary
                return Color.secondary
            } else {
                // Primary
                return Color.primary
            }
        }
    }
}

#Preview {
    PipelineSelectionView(pipelineParameters: .constant(PipelineParameters()), currentlySelectedParameter: .mlModel)
}
