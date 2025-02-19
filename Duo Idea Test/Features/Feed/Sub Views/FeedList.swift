//
//  FeedList.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/19/25.
//

import SwiftUI
import ActivityIndicatorView


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
                                                
                                                //Post Title
                                                Text(link.title)
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.top, 4)
                                                
                                                //If thumbnail is not showing and post text can be fetched, show post text
                                                if link.thumbnail == nil && !link.text.isEmpty {
                                                    Text(link.text)
                                                        .font(.subheadline)
                                                        .multilineTextAlignment(.leading)
                                                        .lineLimit(4)
                                                        .padding(.vertical, 6)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                
                                                // Upvote and comment count
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
                                            
                                            //Reddit name and post date
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
                                            
                                            print("\(link.link)")
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
                                        if !viewModel.waiting {
                                            viewModel.loadMore()
                                        }
                                    }
                                })
                                
                            }
                        }
                        
                        //Loading animation
                        if viewModel.isLoadingMore || viewModel.waiting {
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
            // Web View
            case .webView(let url):
                NavigationView {
                    WebView(url: url)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarItems(leading: Button("Close") {
                            activeSheet = nil
                        })
                }
            // Summary View
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
    
    //Date Formatter
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


