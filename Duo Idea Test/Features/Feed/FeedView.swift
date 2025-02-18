//
//  ContentView.swift
//  Duo Idea Test
//
//  Created by Abe on 2/15/25.
//

import SwiftUI


struct FeedView: View {
    
    @StateObject var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                
                switch viewModel.viewState {
                case .input:
                    InputView()
                case .loading:
                    LoadingView()
                case .success:
                    FeedList(viewModel: viewModel)
                case .error:
                    ErrorView(viewModel: viewModel)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Your Feed")
                        .font(.system(size: 16.5, weight: .bold, design: .rounded))
                }
                
                // Reload feed
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refetch()
                    } label: {
                        Image(systemName: "arrow.circlepath")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.viewState == .loading)
                    .disabled(viewModel.viewState == .input)
                    
                }
                
            
                // Settings
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(viewModel: viewModel)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .buttonStyle(.plain)
                }
                
                
                
            }
            .onAppear {
                
                if viewModel.keywords.isEmpty {
                    viewModel.viewState = .input
                } else {
                    
                    if viewModel.viewState != .success {
                        viewModel.fetch()
                    }
                    
                }
                
            }
            
        }
        
    }
    
}


#Preview {
    
    FeedView()
    
}
