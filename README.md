# Motion-controlled game of Tennis-for-Two
## Terminology
This project uses the terms *art-client* (art standing for Android Runtime) and *android-client* interchangably. This project also uses *xc-client* and *iOS-client* interchangably.


## Hardware used
We are using the following hardware in this project:
- **u32 board**: contains actual game logic and logic for SPI communication
- **Basic I/O shield:** receives data from the WiFi chip and also displays the actual game
- **ESP8266**: WiFi chip used
- **Samsung Galaxy S22 Ultra**: runs *art-client*
- **Apple iPhone 14 Pro**: runs *iOS-client*, which is the controller for player 1

# Components
### android-client
The *android-client* is built on top of the official AndroidSdk using Kotlin with support for API level 30 and above. 

### xc-client
The *xc-client* is built using the Swift programming language on *SwiftUI*, and has support for devices running iOS 16 and above. This client was tested only on iOS 16.3.1. The project makes use of Swift Concurrency, introduced in iOS 15, so it may be possible to add compatibility for devices running iOS 15. 

### wifi-driver
`// TODO`

### graphics-driver
``// TODO`

## Third-party libraries
The following is a list of third-party libraries that have been using in this project.
- [CoreMotion](https://developer.apple.com/documentation/coremotion)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [Network]()
- [Ktor]()
- [AndroidSDK]()


## Contributions
AC Serban contributed mainly into writing the game logic and calibration of the sensor data. Praanto wrote the WiFi drivers and the smartphone clients. Both group members had equal contributions in implementing the I2P protocol onto the u32 board.