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
    
    
    // MARK: -
    let generalInterestSubreddits: [String] = [
        "r/AskReddit", "r/funny", "r/pics", "r/videos", "r/todayilearned"
    ]
    
    let newsAndPoliticsSubreddits: [String] = [
        "r/worldnews", "r/news", "r/politics"
    ]
    
    let scienceAndEducationSubreddits: [String] = [
        "r/science", "r/askscience", "r/ExplainLikeImFive"
    ]
    
    let technologySubreddits: [String] = [
        "r/technology", "r/gadgets", "r/programming"
    ]
    
    let gamingSubreddits: [String] = [
        "r/gaming", "r/pcmasterrace", "r/LeagueofLegends"
    ]
    
    let musicSubreddits: [String] = [
        "r/Music", "r/listentothis", "r/hiphopheads"
    ]
    
    let moviesAndTVSubreddits: [String] = [
        "r/movies", "r/television", "r/netflix"
    ]
    
    let sportsSubreddits: [String] = [
        "r/sports", "r/nba", "r/soccer"
    ]
    
    let lifestyleAndHealthSubreddits: [String] = [
        "r/fitness", "r/nutrition", "r/LifeProTips"
    ]
    
    let artAndDesignSubreddits: [String] = [
        "r/Art", "r/Design", "r/graphic_design"
    ]
    
    let booksAndLiteratureSubreddits: [String] = [
        "r/books", "r/writing", "r/Fantasy"
    ]
    
    let foodAndCookingSubreddits: [String] = [
        "r/food", "r/Cooking", "r/AskCulinary"
    ]
    
    let travelSubreddits: [String] = [
        "r/travel", "r/Shoestring", "r/solotravel"
    ]
    
    let humorAndMemesSubreddits: [String] = [
        "r/memes", "r/dankmemes", "r/wholesomememes"
    ]
    
    let personalFinanceSubreddits: [String] = [
        "r/personalfinance", "r/investing", "r/financialindependence"
    ]
    
    let educationAndLearningSubreddits: [String] = [
        "r/learnprogramming", "r/languagelearning", "r/AskHistorians"
    ]
    
    let natureAndOutdoorsSubreddits: [String] = [
        "r/EarthPorn", "r/hiking", "r/camping"
    ]
    
    let fashionAndStyleSubreddits: [String] = [
        "r/malefashionadvice", "r/femalefashionadvice", "r/streetwear"
    ]
    
    let relationshipsAndAdviceSubreddits: [String] = [
        "r/relationships", "r/AskMen", "r/AskWomen"
    ]
    
    let miscellaneousSubreddits: [String] = [
        "r/DIY", "r/Documentaries", "r/nosleep"
    ]
    
    // UserDefaults storage
    static let userDefaults = UserDefaults(suiteName: "group.demo.app")!
    
    @AppStorage("hasPro", store: userDefaults) var hasPro: Bool = true
    @AppStorage("enableCustomApiKey") var enableCustomAPIKey = false
    @AppStorage("customApiKey") var customAPIKey = ""
    @AppStorage("GeminiAPIKey") var apiKey = ""
    @AppStorage("SerperAPIKey") var serperApiKey = "0d34a8e70e5fa38a3f3371169678d8eb6c93c96a"
    
    @Published var viewState: SearchState = .input
    @Published var waiting: Bool = false
    
    @Published var model: GenerativeModel?
    @AppStorage("keywords") var keywords: String = ""
    @Published var answer: String = ""
    @Published var mainImage = ""
    @Published var title = ""
    @Published var currentWebpage = ""
    @Published var errorMessage = ""
    @Published var error = ""
    
    @AppStorage("X") private var isXEnabled = true
    @AppStorage("Reddit") private var isRedditEnabled = true
    @AppStorage("Instagram") private var isInstagramEnabled = true
    @AppStorage("YouTube") private var isYouTubeEnabled = true
    @AppStorage("LinkedIn") private var isLinkedInEnabled = true
    @AppStorage("Hacker News") private var isHackerNewsEnabled = true
    @AppStorage("Substack") private var isSubstackEnabled = true
    @AppStorage("Medium") private var isMediumEnabled = true
    
    @Published var sourceArray: [SearchItem] = []
    
    @Published var safetySettings = [
        SafetySetting(harmCategory: .dangerousContent, threshold: .blockNone),
        SafetySetting(harmCategory: .harassment, threshold: .blockNone),
        SafetySetting(harmCategory: .hateSpeech, threshold: .blockNone),
        SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockNone),
    ]
    
    // Add these properties to FeedViewModel
    @Published var currentPage = 1
    @Published var linkCount = 1
    @Published var isLoadingMore = false
    
    @Published var array = [String]()
    
    // Add loadMore function
    func loadMore() {
        guard !isLoadingMore else { return }
        fetch(loadMore: true)
    }
    
    func fetch(loadMore: Bool = false) {
        
        print("Current page: \(currentPage)")
        
        if !loadMore {
            viewState = .loading
            currentPage = 1
            sourceArray.removeAll()
        } else {
            isLoadingMore = true
        }
        
        
        
        waiting = true
        
        let apiKey = "AIzaSyBRb2joOU4_8KWWiJn2MhL1IS_Tm6-Q8Zo"
        
        Task(priority: .high) {
            do {
                
                if array.isEmpty {
                    model = GenerativeModel(
                        name: "gemini-2.0-flash-thinking-exp",
                        apiKey: apiKey,
                        safetySettings: safetySettings,
                        systemInstruction: """
                                           Here is a list of keywords the user has inputted: \(keywords).
                                           Here is also a list of different subreddits by category: \(generalInterestSubreddits), \(newsAndPoliticsSubreddits), \(scienceAndEducationSubreddits), \(technologySubreddits), \(gamingSubreddits), \(musicSubreddits), \(moviesAndTVSubreddits), \(sportsSubreddits), \(lifestyleAndHealthSubreddits), \(artAndDesignSubreddits), \(booksAndLiteratureSubreddits), \(foodAndCookingSubreddits), \(travelSubreddits), \(humorAndMemesSubreddits), \(personalFinanceSubreddits), \(educationAndLearningSubreddits), \(natureAndOutdoorsSubreddits), \(fashionAndStyleSubreddits), \(relationshipsAndAdviceSubreddits), \(miscellaneousSubreddits).
                                           
                                           Based on the given keywords, return an array of relevant subreddit names as many as you need. 
                                           The response **MUST** be in the following format:
                                       
                                           ["r/name", "r/name", ...]
                                       
                                           Do not include any explanations, ONLY give a raw array. No json needed.
                                       """
                    )
                    
                    let response = try await model!.generateContent(keywords)
                    
                    do {
                        if let data = response.text!.data(using: .utf8) {
                            let subreddits = try JSONSerialization.jsonObject(with: data, options: []) as? [String]
                            print(subreddits ?? [])
                            array = subreddits ?? []
                        }
                    } catch {
                        print("Error parsing response: \(error)")
                    }
                }
                
                if array.count >= 3 {
                    linkCount = 3
                } else if array.count == 2 {
                    linkCount = 2
                } else {
                    
                    //One subreddit, fetch 5 posts at a time
                    linkCount = 5
                }
                
                var miniArray = [SearchItem]()
                
                for subreddit in array {
                    
                    let parameters = "{\"q\":\"site:reddit.com/\(subreddit)\",\"num\":\(linkCount),\"tbs\":\"qdr:w\",\"page\":\(currentPage)}"
                    let postData = parameters.data(using: .utf8)
                    
                    var request = URLRequest(url: URL(string: "https://google.serper.dev/search")!, timeoutInterval: Double.infinity)
                    request.addValue(serperApiKey, forHTTPHeaderField: "X-API-KEY")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    request.httpBody = postData
                    
                    let data = try await URLSession.shared.data(for: request)
                    let decoder = JSONDecoder()
                    let serperResult = try decoder.decode(SerperResult.self, from: data.0)
                    
                    guard let organic = serperResult.organic else { throw "Missing API Data" }
                    
                    print("\nLink Count for \(subreddit): \(organic.count)\n")
                    
                    
                    for link in organic {
                        guard let urlString = link.link, let url = URL(string: urlString) else { continue }
                        
                        let data = try? await URLSession.shared.data(for: URLRequest(url: url, timeoutInterval: 15))
                        
                        guard let html = data.flatMap({ String(data: $0.0, encoding: .utf8) }) else { continue }
                        
                        let doc = try? HTMLDocument(string: html, encoding: .utf8)
                        let image = extractFaviconURL(from: html, baseURL: url)
                        
                        let categoryResponse = try await GenerativeModel(
                            name: "gemini-2.0-flash",
                            apiKey: apiKey,
                            safetySettings: safetySettings, systemInstruction: """
                                You are an AI that assigns categories to Reddit posts like 'technology', 'gaming', 'finance', etc.
                            
                                Do not include any explanations, ONLY give a raw category.
                            """
                        ).generateContent("Categorize this post: \(link.title ?? "")")
                        
                        var item = SearchItem(
                            title: link.title ?? "No title",
                            link: urlString,
                            postDate: Date(),
                            category: categoryResponse.text ?? "General",
                            icon: image
                        )
                        
                        item.calculateAIScore()
                        
                        print(item.aiScore)
                        
                        //check if already been liked before
                        if AlgorithmCore.shared.likedPosts.contains(where: { item in
                            (item.title == link.title!) || (item.link == link.link!)
                        }) {
                            item.isLiked = true
                        }
                        
                        
                        //check if disliked before
                        if AlgorithmCore.shared.dislikedPosts.contains(where: { item in
                            (item.title == link.title!) || (item.link == link.link!)
                        }) {
                            item.isDisliked = true
                        }
                        
                        
                        if !item.isDisliked {
                            miniArray.append(item)
                        }
                        
                        // Sort by AI Score descending
                        miniArray.sort { $0.aiScore > $1.aiScore }
                        
                        
                    }
                    
                    // After nested loop ends; by subreddit
                    if array.count >= 3 {
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
                if array.count < 3 {
                    withAnimation(.smooth(duration: 0.3)) {
                        sourceArray += miniArray
                    }
                    miniArray = []
                }
                
                
                currentPage += 1
                isLoadingMore = false
                
//                withAnimation(.smooth(duration: 0.3)) {
//                    viewState = .success
//                }
                
                
            } catch {
                isLoadingMore = false
                self.error = "\(error)"
                errorMessage = "Error loading content"
                
                withAnimation(.smooth(duration: 0.3)) {
                    viewState = .error
                }
                
                print(error)
            }
        }
    }
    
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
}
