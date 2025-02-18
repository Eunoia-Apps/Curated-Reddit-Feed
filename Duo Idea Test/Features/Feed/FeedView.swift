//
//  ContentView.swift
//  Duo Idea Test
//
//  Created by Abe on 2/15/25.
//

import SwiftUI
import ActivityIndicatorView
import ChatField
import WebKit

// MARK: - WebView for WKWebView Sheet
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}



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
                
                
                // Favorite posts
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        
                    } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .buttonStyle(.plain)
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





// MARK: - Input View
struct InputView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            
            VStack {
                Text("Please input keywords in settings")
                    .font(.title3)
                    .fontWeight(.bold)
                
             
            }
            .padding(8)
            .padding(.bottom, 24)
            
            
            
            Spacer()
            
            
        }
        .padding(.horizontal, 8)
    }
}





// MARK: - FeedList
struct FeedList: View {
    
    @ObservedObject var viewModel: FeedViewModel
    @StateObject private var summaryVM = FeedSummaryViewModel()
    
    // Use an enum to manage which sheet is active
    @State private var activeSheet: ActiveSheet? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack {
                            ForEach(viewModel.sourceArray) { link in
                                
                                VStack(spacing: 16) {
                                    // Replacing the browser Link with a Button that opens a WebKit sheet.
                                    Button {
                                        if let url = URL(string: link.link) {
                                            activeSheet = .webView(url)
                                        }
                                    } label: {
                                        VStack(spacing: 0) {
                                            
                                            VStack {
                                                // Thumbnail image in place of the gray rectangle.
                                                if let thumbnail = link.thumbnail {
                                                    AsyncImage(url: thumbnail) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(maxWidth: .infinity, maxHeight: 164)
                                                            .clipped()
                                                            .cornerRadius(8)
                                                    } placeholder: {
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.1))
                                                            .frame(height: 164)
                                                            .cornerRadius(8)
                                                    }
                                                }
                                                
                                                Text(link.title)
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.top, 4)
                                                
                                                if link.thumbnail == nil && !link.text.isEmpty {
                                                    Text(link.text)
                                                        .font(.subheadline)
                                                        .multilineTextAlignment(.leading)
                                                        .lineLimit(4)
                                                        .padding(.vertical, 6)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                
                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrowshape.up")
                                                    
                                                    Text("\(link.upvoteCount)")
                                                        .padding(.trailing, 8)
                                                    
                                                    Image(systemName: "bubble")
                                                    
                                                    Text("\(link.commentCount)")
                                                    
                                                    Spacer()
                                                }
                                                .fontDesign(.rounded)
                                                .padding(.top, 4)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(.white)
                                            
                                            HStack(spacing: 4) {
                                                Text("Reddit")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                
                                                Spacer()
                                                
                                                Text(link.postDate, formatter: itemDateFormatter)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.vertical, 6)
                                            .padding(.horizontal)
                                            .frame(maxWidth: .infinity)
                                            
                                        }
                                        .background(.gray.opacity(0.09))
                                        .cornerRadius(8)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.primary.opacity(0.1), lineWidth: 1)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    
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
                                        
                                        // Summary button opens the summary sheet
                                        Button {
                                            summaryVM.sumWeb(post: link)
                                            activeSheet = .summary
                                        } label: {
                                            Image(systemName: "text.bubble")
                                                .font(.system(size: 20))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.vertical)
                                .padding(.horizontal, 18)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.07))
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
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
                                
                                Text("Fetching posts")
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
        // Single sheet modifier that switches on the active sheet type.
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .webView(let url):
                NavigationView {
                    WebView(url: url)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarItems(leading: Button("Close") {
                            activeSheet = nil
                        })
                }
            case .summary:
                VStack(spacing: 0.1) {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.4))
                        .frame(width: 60, height: 5)
                        .cornerRadius(20)
                        .padding(.vertical, 10)
                    
                    Divider()
                        .opacity(0.5)
                    
                    Spacer()
                    
                    ScrollView {
                        Text("Post Summary")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .padding(.vertical, 12)
                        
                        FeedSummaryView(viewModel: summaryVM)
                    }
                }
                .presentationDetents([.fraction(0.5)])
            }
        }
    }
    
    private let itemDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Enum to handle which sheet is active.
    enum ActiveSheet: Identifiable, Equatable {
        case summary
        case webView(URL)
        
        var id: Int {
            switch self {
            case .summary: return 0
            case .webView(_): return 1
            }
        }
    }
}





// MARK: - LoadingView
struct LoadingView: View {
    
    
    
    var body: some View {
        ScrollView {
            
            ForEach(0..<8) { _ in
                VStack(spacing: 16) {
                    
                    
                    VStack(spacing: 0) {
                        
                        
                        VStack {
                            
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 164) // Matches the expected size
                                .cornerRadius(8)
                                .shimmerEffect(isLoading: .constant(true))
                            
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 10) // Matches the expected size
                                .cornerRadius(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .shimmerEffect(isLoading: .constant(true))
                                .padding(.top, 4)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 10) // Matches the expected size
                                .cornerRadius(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .shimmerEffect(isLoading: .constant(true))
                                .padding(.top, 2)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        
                        
                        HStack(spacing: 4) {
                            Text("placeholder")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .opacity(0)
                            
                            Spacer()
                            
                            Text("placeholder")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .opacity(0)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        
                        
                    }
                    .background(.gray.opacity(0.09))
                    .cornerRadius(8)
                    .redacted(reason: .placeholder).overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary.opacity(0.1), lineWidth: 1)
                    }
                    
                    
                    HStack(spacing: 10) {
                        
                        // Like buttons
                        Image(systemName: "heart")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        
                        
                        // Dislike button
                        Image(systemName: "hand.thumbsdown")
                            .font(.system(size: 18.5))
                            .foregroundColor(.gray)
                        
                        
                        Image(systemName: "text.bubble")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.07))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .buttonStyle(.plain)
                
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}





// MARK: - ErrorView
struct ErrorView: View {
    
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        VStack {
            
            Text("Error Description:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(viewModel.errorMessage)
                .font(.subheadline)
                .padding(20)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
