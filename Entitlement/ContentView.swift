//
//  ContentView.swift
//  Entitlement
//
//  Created by s s on 2025/3/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AppIDView(viewModel: AppIDViewModel())
                .tabItem {
                    Label("appids".loc, systemImage: "square.stack.3d.up.fill")
                }
            SettingsView(viewModel: LoginViewModel())
                .tabItem {
                    Label("settings".loc, systemImage: "gearshape.fill")
                }
        }

        .environmentObject(DataManager.shared.model)
        

    }
    
    func test() {
        
    }
}

#Preview {
    ContentView()
}
