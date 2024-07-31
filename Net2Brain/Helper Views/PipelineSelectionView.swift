//
//  PipelineSelectionView.swift
//  Net2Brain
//
//  Created by Marco Weßel on 28.11.23.
//

import SwiftUI

/// view for displaying selected parameters, the parameter currently selected and the parameters that still need to be selected
/// - Parameters:
///   - currentlySelectedParameter: the currently selected parameter (enum value for highlighting the parameter)
///   - allowCollapse: whether the view can be collapsed or not
struct PipelineSelectionView: View {
    
    @EnvironmentObject var pipelineParameters: PipelineParameters
    var currentlySelectedParameter: PipelineParameter
    var allowCollapse = false
    @State private var collapsed = false
    @State private var chevronRotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 6) {
            if collapsed {
                Text(parameterSummary())
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.tail)
            } else {
                PipelineSelectionRow(title: "pipeline.dataset.title", description: parameterValueText(.dataset))
                    .foregroundStyle(parameterForegroundStyle(.dataset))
                PipelineSelectionRow(title: "pipeline.images.title", description: parameterValueText(.images))
                    .foregroundStyle(parameterForegroundStyle(.images))
                Divider()
                PipelineSelectionRow(title: "pipeline.model.title", description: parameterValueText(.mlModel))
                    .foregroundStyle(parameterForegroundStyle(.mlModel))
                /*PipelineSelectionRow(title: pipelineParameters.mlModelLayers.count == 1 ? "ML Model Layer" : "ML Model Layers", description: pipelineParameters.mlModel.name == "" ? "select a ML Model" : pipelineParameters.mlModelLayers.count == 0 ? "select model layers" : pipelineParameters.mlModelLayers.count == 1 ? (pipelineParameters.mlModelLayers.first ?? N2BMLLayer(name: "", description: "", coremlKey: "")).name : "\(pipelineParameters.mlModelLayers.count) Layers")
                 .foregroundStyle(parameterForegroundStyle(.mlModelLayer))*/
                PipelineSelectionRow(title: pipelineParameters.mlModelLayers.count == 1 ? "pipeline.model.layer.title" : "pipeline.model.layers.title", description: parameterValueText(.mlModelLayer))
                    .foregroundStyle(parameterForegroundStyle(.mlModelLayer))
                Divider()
                PipelineSelectionRow(title: "pipeline.rdm.title", description: parameterValueText(.rdmMetric))
                    .foregroundStyle(parameterForegroundStyle(.rdmMetric))
                Divider()
                PipelineSelectionRow(title: "pipeline.evaluation.title", description: parameterValueText(.evaluationType))
                    .foregroundStyle(parameterForegroundStyle(.evaluationType))
            }
        }.padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
            .border(Color.clear, width: 0)
            .padding()
            .overlay(alignment: .bottomTrailing, content: {
                if allowCollapse {
                    HStack(alignment: .top) {
                        Text(collapsed ? "pipeline.summary.show.more" : "pipeline.summary.show.less").font(.caption2).foregroundStyle(Color.accentColor)
                        Image(systemName: "chevron.up").foregroundStyle(Color.accentColor)
                            .rotationEffect(Angle(degrees: chevronRotationAngle))
                    }.padding(.trailing)
                }
            })
            .onTapGesture {
                if allowCollapse {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        collapsed.toggle()
                        chevronRotationAngle += 180
                    }
                    chevronRotationAngle = collapsed ? 180 : 0
                }
            }
    }
    
    func isParameterEmpty(_ parameter: PipelineParameter) -> Bool {
        switch parameter {
        case .none:
            return true
        case .dataset:
            return pipelineParameters.dataset.name == ""
        case .images:
            return pipelineParameters.datasetImages.count == 0
        case .mlModel:
            return pipelineParameters.mlModel.name == ""
        case .mlModelLayer:
            return pipelineParameters.mlModelLayers.count == 0
        case .rdmMetric:
            return pipelineParameters.rdmMetric.name == ""
        case .evaluationType:
            return pipelineParameters.evaluationType.name == ""
        case .evaluationParameter:
            return pipelineParameters.evaluationParameter.name == ""
        }
    }
    
    func valueForParameter(_ parameter: PipelineParameter) -> String {
        switch parameter {
        case .none:
            return ""
        case .dataset:
            return pipelineParameters.dataset.name
        case .images:
            //return pipelineParameters.datasetImages.count == 1 ? "1 image" : "\(pipelineParameters.datasetImages.count) images"
            return String(localized: "pipeline.images.\(pipelineParameters.datasetImages.count)")
        case .mlModel:
            return pipelineParameters.mlModel.name
        case .mlModelLayer:
            return pipelineParameters.mlModelLayers.count == 1 ? (pipelineParameters.mlModelLayers.first ?? N2BMLLayer(name: "", layerDescription: "", coremlKey: "")).name : String(localized: "pipeline.model.layers.\(pipelineParameters.mlModelLayers.count)")
        case .rdmMetric:
            return pipelineParameters.rdmMetric.name
        case .evaluationType, .evaluationParameter:
            return "\(pipelineParameters.evaluationType.name) – \(pipelineParameters.evaluationParameter.name)"
        }
    }
    
    func parameterValueText(_ parameter: PipelineParameter) -> String {
        return isParameterEmpty(parameter) ? parameter == currentlySelectedParameter ? String(localized: "pipeline.select.parameter.\(currentlySelectedParameter.localizedString())") : "pipeline.selected.later" : valueForParameter(parameter)
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
    
    func parameterSummary() -> String {
        let summaryParameters: [PipelineParameter] = [.dataset, .images, .mlModel, .mlModelLayer, .rdmMetric, .evaluationType]
        var summaryString = ""
        for summaryParameter in summaryParameters {
            if !isParameterEmpty(summaryParameter) {
                summaryString += summaryString == "" ? valueForParameter(summaryParameter) : " • \(valueForParameter(summaryParameter))"
            }
        }
        
        return summaryString == "" ? String(localized: "pipeline.summary.empty") : summaryString
    }
}

#Preview {
    PipelineSelectionView(currentlySelectedParameter: .mlModel)
}
