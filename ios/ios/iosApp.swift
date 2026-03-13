//
//  iosApp.swift
//  ios
//
//  Created by hj on 3/12/26.
//

import SwiftUI
import SwiftData

@main
struct iosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: StageCompletion.self)
    }
}
