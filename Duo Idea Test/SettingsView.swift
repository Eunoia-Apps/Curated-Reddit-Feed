//
//  SettingsView.swift
//  Duo Idea Test
//
//  Created by David Empire on 2/15/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("X") private var isXEnabled = true
    @AppStorage("Reddit") private var isRedditEnabled = true
    @AppStorage("Instagram") private var isInstagramEnabled = true
    @AppStorage("YouTube") private var isYouTubeEnabled = true
    @AppStorage("LinkedIn") private var isLinkedInEnabled = true
    @AppStorage("Hacker News") private var isHackerNewsEnabled = true
    @AppStorage("Substack") private var isSubstackEnabled = true
    @AppStorage("Medium") private var isMediumEnabled = true
    
    var body: some View {
        VStack {
            List {
                socialMediaRow(name: "X", systemImage: "xmark", isOn: $isXEnabled)
                socialMediaRow(name: "Reddit", systemImage: "globe", isOn: $isRedditEnabled)
                socialMediaRow(name: "Instagram", systemImage: "camera", isOn: $isInstagramEnabled)
                socialMediaRow(name: "YouTube", systemImage: "play.rectangle", isOn: $isYouTubeEnabled)
                socialMediaRow(name: "LinkedIn", systemImage: "link", isOn: $isLinkedInEnabled)
                socialMediaRow(name: "Hacker News", systemImage: "bolt.horizontal", isOn: $isHackerNewsEnabled)
                socialMediaRow(name: "Substack", systemImage: "book", isOn: $isSubstackEnabled)
                socialMediaRow(name: "Medium", systemImage: "doc.text", isOn: $isMediumEnabled)
            }
            .listStyle(.plain)
            .navigationTitle("Settings")
        }
    }
    
    private func socialMediaRow(name: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: systemImage)
                .frame(width: 30)
                .fontWeight(.medium)
            
            Text(name)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    SettingsView()
}
