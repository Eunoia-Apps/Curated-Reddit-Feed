//
//  ContentView.swift
//  Duo Idea Test
//
//  Created by David Empire on 2/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            GemSearchView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
