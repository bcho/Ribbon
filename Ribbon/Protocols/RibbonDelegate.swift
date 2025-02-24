//
//  RibbonDelegate.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/26/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

import Foundation

@objc
public protocol RibbonDelegate { 

    // MARK: - Methods

    @objc
    optional func ribbon(imageForIdentifier itemIdentifier: RibbonItem.Identifier, imageName: String) -> Image?
    @objc
    optional func ribbon(didDecode item: RibbonItem)

    #if canImport(UIKit)
    @objc
    optional func ribbon(contextMenuInteractionWillPresent itemIdentifier: RibbonItem.Identifier)
    @objc
    optional func ribbon(contextMenuInteractionDidEnd itemIdentifier: RibbonItem.Identifier)
    #endif

}
