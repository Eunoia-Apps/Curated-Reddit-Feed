//
//  ContentView.swift
//  Duo Idea Test
//
//  Created by Abe on 2/15/25.
//

import SwiftUI
import ActivityIndicatorView
import ChatField


struct FeedView: View {
    
    @StateObject var viewModel = FeedViewModel()
    
    @FocusState private var isFieldFocused: Bool
    
    
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        
                    } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .buttonStyle(.plain)
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
                
                
                
            }
            .onAppear {
                
                if !viewModel.keywords.isEmpty && viewModel.viewState != .success {
                    viewModel.fetch()
                }
             
            }
            
        }
        
    }
    
}


#Preview {
    
    FeedView()
    
}




// MARK: - Subviews

struct InputView: View {
    var body: some View {
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
}


struct FeedList: View {
    
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack {
                            ForEach(viewModel.sourceArray) { link in
                                
                                Link(destination: URL(string: link.link)!) {
                                    VStack(spacing: 16) {
                                        // Thumbnail image in place of the gray rectangle.
                                        if let thumbnail = link.icon {
                                            AsyncImage(url: thumbnail) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit() // Ensures the image fits inside the frame without expansion
                                                    .frame(maxWidth: .infinity, maxHeight: 200) // Keeps it contained
                                                    .clipped() // Prevents any overflow
                                                    .cornerRadius(8)
                                            } placeholder: {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.1))
                                                    .frame(height: 200) // Matches the expected size
                                                    .cornerRadius(8)
                                            }
                                        } else {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(height: 200) // Ensures consistent height
                                                .cornerRadius(8)
                                        }
                                        
                                        
                                          
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(link.title)
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .multilineTextAlignment(.leading)
                                            
                                            Text(link.postDate, formatter: itemDateFormatter)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        
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
                                .onScrollVisibilityChange({ visible in
                                    if visible, link.id == viewModel.sourceArray.last?.id {
                                        viewModel.loadMore()
                                    }
                                })
                            }
                        }
                        
                        if viewModel.isLoadingMore {
                            VStack {
                                ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots(count: 3, inset: 2))
                                    .frame(width: 32, height: 20)
                                
                                Text("Fetching your posts")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                            }
                            .padding()
                        }
                    }
                }
            }
        }
    }
    
    private let itemDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

struct LoadingView: View {
    
    
    
    var body: some View {
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
}


struct ErrorView: View {
    
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
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
