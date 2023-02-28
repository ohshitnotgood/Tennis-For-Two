//
//  TapticKit.swift
//  ios-client
//
//  Created by Praanto on 2023-02-28.
//

import UIKit
import SwiftUI
import Logging


class TaptikKit {
    
    private let logger = Logger(label: Logger.TAG_TAPTIC_KIT)
    
    private class TapticGenerator {
        static let levelOne = UIImpactFeedbackGenerator(style: .light)
        static let levelTwo = UIImpactFeedbackGenerator(style: .medium)
        static let levelThree = UIImpactFeedbackGenerator(style: .heavy)
        static let levelFour = UIImpactFeedbackGenerator(style: .rigid)
        
        static func gameOver() {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    func provideHapticFeedbackFrom(serverResponse networkResponse: String) {
        switch networkResponse {
            case NetworkKit.ClientSlaveSyncProtocolMessage.dataRequestFromServer.rawValue:
                logger.info("Level zero taptic feedback provided.")
            case NetworkKit.ClientSlaveSyncProtocolMessage.dataRequestWithHapticLevelOne.rawValue:
                TapticGenerator.levelOne.impactOccurred()
                logger.info("Level one taptic feedback provided.")
            case NetworkKit.ClientSlaveSyncProtocolMessage.dataRequestWithHapticLevelTwo.rawValue:
                logger.info("Level two taptic feedback provided.")
                TapticGenerator.levelTwo.impactOccurred()
            case NetworkKit.ClientSlaveSyncProtocolMessage.dataRequestWithHapticLevelThree.rawValue:
                logger.info("Level three taptic feedback provided.")
                TapticGenerator.levelThree.impactOccurred()
            case NetworkKit.ClientSlaveSyncProtocolMessage.dataRequestWithHapticLevelFour.rawValue:
                logger.info("Level four taptic feedback provided.")
                TapticGenerator.levelFour.impactOccurred()
            default:
                logger.error("Inappropriate haptic level provided")
        }
    }
}
