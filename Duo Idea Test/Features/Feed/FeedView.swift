//
//  ContentView.swift
//  Duo Idea Test
//
//  Created by Abe on 2/15/25.
//

import SwiftUI
import LangChain
import GoogleGeminiAI
import Fuzi
import Foundation
import ActivityIndicatorView
import ChatField
import SkeletonUI


struct FeedView: View {
    
    @StateObject var viewModel = FeedViewModel()
    
    @FocusState private var isFieldFocused: Bool
    
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.viewState == .input {
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        
                        HStack {
                            Text("Please input keywords in settings")
                                .font(.title2)
                                .fontWeight(.heavy)
                            
                            Divider()
                                .frame(height: 20)
                            
                            Text("Reddit")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                            
                        }
                        .padding(8)
                        .padding(.bottom, 24)
                        
                        
                        
                        Spacer()
                        
                        
                    }
                    .padding(.horizontal, 8)
                }
                
                else if viewModel.viewState == .success {
                    
                    ZStack(alignment: .bottom) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 10) {
                                
                                ScrollView(.vertical, showsIndicators: false) {
                                    LazyVStack {
                                        ForEach(viewModel.sourceArray) { link in
                                            
                                            Link(destination: URL(string: link.link)!) {
                                                VStack(spacing: 16) {
                                                    
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.1))
                                                        .frame(height: 200)
                                                        .cornerRadius(8)
                                                    
                                                    HStack(spacing: 12) {
                                                        if link.icon != nil {
                                                            
                                                            AsyncImage(url: link.icon!) { image in
                                                                image
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .frame(width: 32, height: 32)
                                                                    .cornerRadius(4)
                                                                
                                                            } placeholder: {
                                                                Image(systemName: "globe")
                                                                    .font(.system(size: 20))
                                                                    .foregroundColor(.indigo)
                                                            }
                                                            
                                                        }
                                                        
                                                        Text(link.title)
                                                            .font(.headline)
                                                            .fontWeight(.semibold)
                                                            .multilineTextAlignment(.leading)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        
                                                    }
                                                    
                                                    
                                                    HStack(spacing: 10) {
                                                        
                                                        // Like buttons
                                                        if link.isLiked {
                                                            Button {
                                                                
                                                                viewModel.toggleUnlike(post: link)
                                                                
                                                            } label: {
                                                                Image(systemName: "heart.fill")
                                                                    .font(.system(size: 20))
                                                                    .foregroundColor(.red)
                                                                
                                                            }
                                                        } else {
                                                            Button {
                                                                
                                                                viewModel.toggleLike(post: link)
                                                                
                                                            } label: {
                                                                Image(systemName: "heart")
                                                                    .font(.system(size: 20))
                                                                    .foregroundColor(.gray)
                                                                
                                                            }
                                                        }
                                                        
                                                        // Dislike button
                                                        Button {
                                                            
                                                            viewModel.toggleDislike(post: link)
                                                            
                                                        } label: {
                                                            Image(systemName: "hand.thumbsdown")
                                                                .font(.system(size: 18.5))
                                                                .foregroundColor(.gray)
                                                            
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                    }
                                                    
                                                }
                                                .padding(.vertical)
                                                .padding(.horizontal, 18)
                                                .frame(maxWidth: .infinity)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                
                                                
                                            }
                                            .buttonStyle(.plain)
                                            .onScrollVisibilityChange({ bool in
                                                //                                            print("Link ID: \(link.title)")
                                                //                                            print("Last ID: \(viewModel.sourceArray.last!.title)")
                                                //
                                                if bool {
                                                    if link.id == viewModel.sourceArray.last!.id {
                                                        viewModel.loadMore()
                                                    }
                                                }
                                                
                                            })
                                        }
                                    }
                                    
                                    if viewModel.isLoadingMore {
                                        ProgressView()
                                            .padding()
                                    }
                                }
                            }
                        }
                    }
                    
                    
                }
                
                
                else if viewModel.viewState == .loading {
                    
                    ScrollView {
                        
                        ForEach(0..<8) { _ in
                            VStack(spacing: 16) {
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 200)
                                    .cornerRadius(8)
                                    .redacted(reason: .placeholder)
                                    .shimmerEffect(isLoading: .constant(true))
                                
                                HStack(spacing: 12) {
                                    
                                    Image(systemName: "globe")
                                        .font(.system(size: 24))
                                        .redacted(reason: .placeholder)
                                        .shimmerEffect(isLoading: .constant(true))
                                    
                                    Text("placeholder placeholder placeholder placeholder placeholder placeholders")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .redacted(reason: .placeholder)
                                        .shimmerEffect(isLoading: .constant(true))
                                    
                                }
                                
                                
                                
                                
                                HStack(spacing: 10) {
                                    
                                    // Like buttons
                                    
                                    Button {
                                        
                                        
                                        
                                    } label: {
                                        Image(systemName: "heart")
                                            .font(.system(size: 20))
                                            .foregroundColor(.gray)
                                        
                                    }
                                    
                                    
                                    
                                    Button {
                                        
                                        
                                        
                                    } label: {
                                        Image(systemName: "hand.thumbsdown")
                                            .font(.system(size: 18.5))
                                            .foregroundColor(.gray)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                }
                                
                            }
                            .padding(.vertical)
                            .padding(.horizontal, 18)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                
                else if viewModel.viewState == .error {
                    
                    VStack {
                        
                        Text("An error occurred: try restarting the app.")
                            .font(.subheadline)
                            .padding()
                        
                        Text(viewModel.errorMessage)
                            .font(.subheadline)
                            .padding(20)
                        
                        //                        ReportButton(message: Message(text: "gemsearch-error", isCurrentUser: false, hasError: true, apikeyUsed: viewModel.enableCustomAPIKey ? "user-custom-key" : viewModel.apiKey, errorMessage: "GemSearch ERROR: \(viewModel.error)"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .principal) {
                    Text("Feed")
                        .font(.system(size: 16.5, weight: .bold, design: .rounded))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        
                    } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .buttonStyle(.plain)
                }
                
            }
            .onAppear {
                
                print(viewModel.viewState)
                if viewModel.viewState != .success {
                    viewModel.fetch()
                }
                
            }
            
        }
        
    }
    
    
}


#Preview {
    
    FeedView()
    
}
