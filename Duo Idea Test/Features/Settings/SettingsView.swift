//
//  SettingsView.swift
//  Duo Idea Test
//
//  Created by David Empire on 2/15/25.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("keywords") var keywords: String = ""
    
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                
                Text("Enter keywords to curate your feed 🚀")
                    .font(.callout)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                TextField("Keywords", text: $keywords)
                    .font(.callout)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.03))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray.opacity(0.15), lineWidth: 1)
                    )
                    .onChange(of: keywords, { oldValue, newValue in
                        if newValue.isEmpty == false {
                            viewModel.viewState = .loading
                        }
                    })
                    .padding(.horizontal)
                    .padding(.vertical, 12)
             
            }
            .padding()
            
        }
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.system(size: 16.5, weight: .bold, design: .rounded))
            }
        }
    }
   
}

#Preview {
    NavigationView {
        SettingsView(viewModel: FeedViewModel())
    }
}
