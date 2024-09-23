#  Net2Brain App

The Net2Brain App is a App for the iPhone that is based on the [Net2Brain toolbox](https://github.com/cvai-roig-lab/Net2Brain) and parts of the [Algonauts Challenge 2023](http://algonauts.csail.mit.edu/index.html). It is part of a bachelor thesis and has the goal to give students and newbies an easy entry into Machine Learning, Neuroscience and their connection.

## Key Functions
1. **ROI Visualization on 3D Brain:** a 3D visualization of a human brain and different ROIs (Regions of Interest) on its surface
2. **Brain Response Visualization on 3D Brain:** a 3D visualization of a human brain and the brain response of a human to different images in different ROIs
3. **Net2Brain Pipeline:** this is the main feature of the app. The user selects parameters like the dataset, a subset of images from the dataset, the ML model, its layers, the distance metric for RDM (Representational Dissimilarity Matrix) creation and the evaluation type and parameter. The app now performs a prediction using the selected ML model with the selected images and calculates the RDM from the features of the ML model layers that then can be visualized using a Heatmap Chart. In the end RSA (Representational Similarity Analysis) is calculated and the results are shown in a bar chart.

## Current State
The current state of the app forms the basis and is fully functional. It contains the following datasets and models:

### Datasets
- **78images** from [Algonauts2019 Challenge Training Set A](http://algonauts.csail.mit.edu/2019/download.html)
- **92images** from [Algonauts2019 Challenge Test Set](http://algonauts.csail.mit.edu/2019/download.html)

### ML Models
- AlexNet
- ResNet18
- ResNet34
- ResNet50
- VGG11
- VGG13

Every model comes with its own subset of layers.

## How to run the app on your Computer
**Prerequisites:** To open the project and run it on your computer you need a Mac and the program [Xcode](https://apps.apple.com/de/app/xcode/id497799835?mt=12).

After opening the project in Xcode you can run it on an iPhone Simulator.

## Trademark Notice and Attribution
The Net2Brain App is an independent publication and has not been authorized, sponsored, or otherwise approved by Apple Inc.
iPhone is a trademark of Apple Inc., registered in the U.S. and other countries and regions.