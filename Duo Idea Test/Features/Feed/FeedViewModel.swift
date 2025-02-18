//
//  FeedViewModel.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/18/25.
//

import SwiftUI
import GoogleGeminiAI
import LangChain
import Fuzi


@MainActor
class FeedViewModel: ObservableObject {
    
    //MARK: - Properties
    
    @AppStorage("GeminiAPIKey") var apiKey = "AIzaSyDawRzTtS5kG-fO53AB644r3U8qoJLgHJQ"
    @AppStorage("SerperAPIKey") var serperApiKey = "7ede09eb36d4ca8a82acb8c04e15f4ca18ccafc3"
    @AppStorage("keywords") var keywords: String = ""
    
    @Published var viewState: SearchState = .input
    @Published var model: GenerativeModel?
    @Published var sourceArray: [SearchItem] = []
    
    @Published var errorMessage = ""
    @Published var error = ""
    @Published var waiting = false
    
    // Add these properties to FeedViewModel
    @Published var currentPage = 1
    @Published var linkCount = 1
    @Published var isLoadingMore = false
    @Published var keywordResultArray = [String]()
    
    private var safetySettings = [
        SafetySetting(harmCategory: .dangerousContent, threshold: .blockNone),
        SafetySetting(harmCategory: .harassment, threshold: .blockNone),
        SafetySetting(harmCategory: .hateSpeech, threshold: .blockNone),
        SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockNone),
    ]
    
    
    
    
    
    //MARK: - Fetch methods
    
    // Load more for pagination method
    func loadMore() {
        guard !isLoadingMore else { return }
        fetch(loadMore: true)
    }
    
    // Main fetch method
    func fetch(loadMore: Bool = false) {
        
        waiting = true
        
        print("Current page: \(currentPage)")
        
        if !loadMore {
            viewState = .loading
            currentPage = 1
            sourceArray.removeAll()
        } else {
            isLoadingMore = true
        }
        
        
        Task(priority: .high) {
            do {
                
                if keywordResultArray.isEmpty {
                    model = GenerativeModel(
                        name: "gemini-2.0-flash",
                        apiKey: apiKey,
                        generationConfig: GenerationConfig(temperature: 0.3),
                        safetySettings: safetySettings,
                        systemInstruction: """
                                           Here is a list of keywords the user has inputted: \(keywords).
                                           Here is also a list of different subreddits by category: \(Sources.allSubreddits)
                                           
                                           Based on the given keywords, return an array of relevant subreddit names as many as you need. 
                                           The response **MUST** be in the following format:
                                       
                                           ["r/name", "r/name", ...]
                                       
                                           Do not include any explanations or JSON, ONLY give me a raw array.
                                       """
                    )
                    
                    let response = try await model!.generateContent(keywords)
                    
                    do {
                        if let data = response.text!.data(using: .utf8) {
                            let subreddits = try JSONSerialization.jsonObject(with: data, options: []) as? [String]
                            print(subreddits ?? [])
                            keywordResultArray = subreddits ?? []
                        }
                    } catch {
                        print("Error parsing response: \(error)")
                    }
                }
                
                if keywordResultArray.count >= 3 {
                    linkCount = 3
                } else if keywordResultArray.count == 2 {
                    linkCount = 2
                } else {
                    
                    //One subreddit, fetch 5 posts at a time
                    linkCount = 5
                }
                
                var miniArray = [SearchItem]()
                
                for subreddit in keywordResultArray {
                    
                    let parameters = "{\"q\":\"site:reddit.com/\(subreddit)\",\"num\":\(linkCount),\"tbs\":\"qdr:w\",\"page\":\(currentPage)}"
                    let postData = parameters.data(using: .utf8)
                    
                    var request = URLRequest(url: URL(string: "https://google.serper.dev/search")!, timeoutInterval: 30)
                    request.addValue(serperApiKey, forHTTPHeaderField: "X-API-KEY")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    request.httpBody = postData
                    
                    let data = try await URLSession.shared.data(for: request)
                    let decoder = JSONDecoder()
                    let serperResult = try decoder.decode(SerperResult.self, from: data.0)
                    
                    guard let organic = serperResult.organic else { continue }
                    
                    print("\nLink Count for \(subreddit): \(organic.count)\n")
                    
                    
                    for link in organic {
                        
                        guard var urlString = link.link else { continue }
                        
                        urlString = normalizeRedditURL(urlString)
                        
                        guard let url = URL(string: urlString) else { continue }
                        
                        // Variables for getting the post date (and other data) from Reddit's JSON endpoint
                        var title: String = link.title ?? "No title"
                        var author: String = ""
                        var score: Int = 0
                        var thumbnail: URL? = nil
                        var bodyText = ""
                        var postDate: Date? = nil
                        var postURL: String = urlString
                        var commentCount = 0
                        
                        if let host = url.host {
                            
                            // Construct the JSON URL, ensuring it ends with ".json"
                            let jsonURLString = url.absoluteString.hasSuffix(".json") ? url.absoluteString : url.absoluteString + ".json"
                            
                            if let jsonURL = URL(string: jsonURLString),
                               let (jsonData, _) = try? await URLSession.shared.data(for: URLRequest(url: jsonURL, timeoutInterval: 20)),
                               let jsonArray = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any],
                               let firstItem = jsonArray.first as? [String: Any],
                               let dataDict = firstItem["data"] as? [String: Any],
                               let children = dataDict["children"] as? [[String: Any]],
                               let firstChild = children.first,
                               let childData = firstChild["data"] as? [String: Any] {
                                
                                // Extract primary post details
                                title = childData["title"] as? String ?? title
                                author = childData["author"] as? String ?? ""
                                score = childData["score"] as? Int ?? 0
                                
                                // Extract post body text (if applicable)
                                bodyText = childData["selftext"] as? String ?? ""
                                
                                // Extract comment count (if available)
                                if let secondItem = jsonArray.dropFirst().first as? [String: Any],
                                   let commentsData = secondItem["data"] as? [String: Any],
                                   let commentsChildren = commentsData["children"] as? [[String: Any]] {
                                    commentCount = commentsChildren.count
                                }
                                
                                // Extract post creation date (if available)
                                if let createdUTC = childData["created_utc"] as? TimeInterval {
                                    postDate = Date(timeIntervalSince1970: createdUTC)
                                }
                                
                                // Extract thumbnail image URL (if applicable and valid)
                                if let thumbString = childData["thumbnail"] as? String,
                                   !thumbString.isEmpty,
                                   thumbString.lowercased() != "self",
                                   thumbString.lowercased() != "default",
                                   let thumbURL = URL(string: thumbString) {
                                    thumbnail = thumbURL
                                }
                                
                                // Debugging logs for extracted data
                                print("\nParsed from JSON – Title: \(title), Author: \(author)")
                                print("Post Date: \(postDate?.description ?? "nil"), Thumbnail: \(thumbnail?.absoluteString ?? "none")")
                                print("Post Body: \(bodyText)\n")
                            }
                        }

                        
                        
                        // Get category of post via LLM.
                        let categoryResponse = try await GenerativeModel(
                            name: "gemini-2.0-flash-lite-preview",
                            apiKey: apiKey,
                            generationConfig: GenerationConfig(temperature: 0.3),
                            safetySettings: safetySettings,
                            systemInstruction: """
                               You are an AI responsible for categorizing Reddit posts using the predefined topic list: \(Sources.topicCategories).
                            
                               Give me ONLY a single category from this list—nothing else. Do not provide explanations or additional context.
                            """
                        )
                        .generateContent("Categorize this post: \(title)")
                        
                        
                        // Build SearchItem
                        var item = SearchItem(
                            title: title,
                            link: postURL,
                            postDate: postDate ?? Date(), // now hopefully extracted from JSON (or fallback)
                            category: categoryResponse.text ?? "General",
                            thumbnail: thumbnail,
                            commentCount: commentCount,
                            upvoteCount: score,
                            text: bodyText
                        )
                        
                        print("\nFinal Item – Title: \(title), Category: \(categoryResponse.text ?? "General")\n")
                        
                        item.calculateAIScore()
                        
                        if AlgorithmManager.shared.likedPosts.contains(where: { existing in
                            (existing.title == link.title!) || (existing.link == link.link!)
                        }) {
                            item.isLiked = true
                        }
                        
                        if AlgorithmManager.shared.dislikedPosts.contains(where: { existing in
                            (existing.title == link.title!) || (existing.link == link.link!)
                        }) {
                            item.isDisliked = true
                        }
                        
                        if !item.isDisliked {
                            miniArray.append(item)
                        }
                        
                        miniArray.sort { $0.aiScore > $1.aiScore }
                    }
                    
                    // After nested loop ends; by subreddit
                    if keywordResultArray.count >= 3 {
                        withAnimation(.smooth(duration: 0.3)) {
                            sourceArray += miniArray
                        }
                        miniArray = []
                    }
                    
                    withAnimation(.smooth(duration: 0.3)) {
                        viewState = .success
                    }
                    
                }
                
                // After entire loop ends
                if keywordResultArray.count < 3 {
                    withAnimation(.smooth(duration: 0.3)) {
                        sourceArray += miniArray
                    }
                    miniArray = []
                }
                
                
                currentPage += 1
                isLoadingMore = false
                waiting = false
                
                
            } catch {
                waiting = false
                isLoadingMore = false
                self.error = "\(error)"
                errorMessage = "\(error)"
                
                withAnimation(.smooth(duration: 0.3)) {
                    viewState = .error
                }
                
                print(error)
            }
        }
    }
    
    // Refetch method
    func refetch() {
        
        //Reset variables
        sourceArray.removeAll()
        keywordResultArray.removeAll()
        
        currentPage = 1
        linkCount = 1
        isLoadingMore = false
        
        error = ""
        errorMessage = ""
        
        fetch()
    }
    
    
    
    
    
    //MARK: - Helper methods
    
    private func extractFaviconURL(from html: String, baseURL: URL) -> URL? {
        let pattern = "<link[^>]+rel=\"shortcut icon\"[^>]+href=\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(html.startIndex..., in: html)
        
        if let match = regex?.firstMatch(in: html, options: [], range: range),
           let hrefRange = Range(match.range(at: 1), in: html) {
            let href = String(html[hrefRange])
            return URL(string: href, relativeTo: baseURL)
        }
        
        return URL(string: "/favicon.ico", relativeTo: baseURL)
    }
    
    private func normalizeRedditURL(_ url: String) -> String {
        let pattern = "^https?://old\\.reddit\\.com(.*)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: url.utf16.count)
            if regex.firstMatch(in: url, options: [], range: range) != nil {
                return url.replacingOccurrences(of: "old.reddit.com", with: "reddit.com")
            }
        }
        return url
    }
    
    
}




extension FeedViewModel {
    
    //MARK: - Post interaction methods
    func toggleLike(post: SearchItem) {
        if let index = sourceArray.firstIndex(where: { $0.id == post.id }) {
            sourceArray[index].likePost()
        }
    }
    
    
    func toggleUnlike(post: SearchItem) {
        if let index = sourceArray.firstIndex(where: { $0.id == post.id }) {
            sourceArray[index].unlikePost()
        }
    }
    
    
    func toggleDislike(post: SearchItem) {
        if let index = sourceArray.firstIndex(where: { $0.id == post.id }) {
            sourceArray[index].dislikePost()
            withAnimation(.smooth(duration: 0.35)) {
                sourceArray.remove(at: index)
            }
        }
    }
    
    
}
