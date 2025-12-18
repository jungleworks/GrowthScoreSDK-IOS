//
//  FontLoader.swift
//  GrowthScore
//
//  Created by Neha on 18/12/25.
//

//
//  FontLoader.swift
//  GrowthScore
//

import UIKit
import CoreText

public final class FontLoader {

    private static var isRegistered = false

    public static func registerFonts() {
        guard !isRegistered else { return }

        guard
            let bundleURL = Bundle(for: FontLoader.self)
                .url(forResource: "GrowthScore", withExtension: "bundle"),
            let resourceBundle = Bundle(url: bundleURL)
        else {
            assertionFailure("❌ GrowthScore.bundle not found")
            return
        }

        let fontURLs = resourceBundle.urls(
            forResourcesWithExtension: "ttf",
            subdirectory: "Fonts"
        ) ?? []

        for url in fontURLs {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }

        isRegistered = true
    }
}
