# README #

To run and test this app on local machine please do below steps:

### What is this repository for? ###

* This is iOS app of Appforall project.

### How do I get set up? ###

* Summary of set up:
    + Pull project.
    + Setup Cocoapods.
    + Download dependency libraries.

* Configuration:
    + Check to see if you have cocoapods install or not by running this command in terminal: pod --version
    + If you receive a version number, you have cocoapods. :)
    + If you don't have cocoapods, first install it with this guide: http://guides.cocoapods.org/using/getting-started.html

* Dependencies
    + After installing cocoapods go to root folder of this project where you will find a file with this name:"Podfile"
    + Now type this in terminal and hit enter: "pod install"
    + After a while all dependency libraries will downloaded and now you see a file with this name: "PROJECT.xcworkspace"
    + It is the workspace file of PROJECT which contains source project and its dependencies.
    + From now on always open this workspace in Xcode.
