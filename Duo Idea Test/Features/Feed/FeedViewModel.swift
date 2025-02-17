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

let topicCategories: [String] = [
    
    // Technology
    "Artificial Intelligence & Machine Learning",
    "Blockchain & Cryptocurrency",
    "Cybersecurity & Data Privacy",
    "iOS Development & Swift",
    "Cloud Computing & DevOps",
    "Biotechnology & Genetic Engineering",
    "Quantum Computing",
    "Space Exploration & Aerospace Tech",
    "Augmented Reality & Virtual Reality",
    "Automotive Technology & Electric Vehicles",
    "Renewable Energy & Sustainability",
    "Gaming Industry & Game Development",
    "Digital Marketing & SEO",
    "UX/UI Design & Product Development",
    "Philosophy of Technology & Ethics",
    
    // Business
    "Stock Market & Investment Strategies",
    "Entrepreneurship & Startups",
    "E-Commerce & Digital Business",
    "Corporate Leadership & Management",
    "Personal Finance & Wealth Management",
    "Marketing Strategies & Branding",
    "Supply Chain & Logistics",
    "Real Estate & Property Investment",
    
    // Health
    "Mental Health & Wellness",
    "Nutrition & Dietetics",
    "Fitness & Strength Training",
    "Holistic & Alternative Medicine",
    "Medical Breakthroughs & Innovations",
    "Public Health & Epidemiology",
    "Sleep Science & Optimization",
    "Neuroscience & Cognitive Health",
    
    // Education
    "EdTech & Online Learning",
    "STEM Education & Innovation",
    "Language Learning & Linguistics",
    "Special Education & Accessibility",
    "Higher Education & Research",
    "Study Techniques & Productivity",
    "Education Policy & Reform",
    "AI in Education & Personalized Learning",
    
    // Entertainment
    "Film & Television Industry",
    "Music Production & Trends",
    "Video Games & eSports",
    "Streaming Platforms & Content Creation",
    "Celebrity Culture & Pop Trends",
    "Animation & Visual Effects",
    "Podcasting & Audio Storytelling",
    "Comedy & Stand-Up Culture",
    
    // Sports
    "Soccer & International Football",
    "Basketball & NBA Trends",
    "Martial Arts & Combat Sports",
    "Formula 1 & Motorsport Racing",
    "Olympic Sports & Athletes",
    "Extreme Sports & Adventure Challenges",
    "Fitness Competitions & Bodybuilding",
    "Sports Science & Injury Prevention",
    
    // Lifestyle
    "Minimalism & Decluttering",
    "Personal Development & Mindfulness",
    "Fashion Trends & Sustainable Clothing",
    "Home Decor & Interior Design",
    "Parenting & Family Life",
    "Work-Life Balance & Productivity",
    "Hobbies & Creative Arts",
    "Self-Care & Mental Resilience",
    
    // Travel
    "Backpacking & Budget Travel",
    "Luxury Travel & Resorts",
    "Solo Travel & Digital Nomad Lifestyle",
    "Cultural Experiences & Heritage Tourism",
    "Adventure Travel & Extreme Destinations",
    "Eco-Tourism & Sustainable Travel",
    "Best Cities for Remote Work",
    "Airlines & Travel Hacks",
    
    // Food
    "Gourmet Cooking & Fine Dining",
    "Street Food & Local Cuisines",
    "Plant-Based & Vegan Recipes",
    "Baking & Dessert Trends",
    "Food Science & Nutrition",
    "Fermentation & Probiotic Foods",
    "Wine, Coffee & Beverage Culture",
    "Meal Prep & Healthy Eating"
]


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
    
    
    // MARK: - Subreddits
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
    
    @AppStorage("GeminiAPIKey") var apiKey = "AIzaSyBRb2joOU4_8KWWiJn2MhL1IS_Tm6-Q8Zo"
    @AppStorage("SerperAPIKey") var serperApiKey = "0d34a8e70e5fa38a3f3371169678d8eb6c93c96a"
    
    @Published var viewState: SearchState = .input
    
    @Published var model: GenerativeModel?
    @AppStorage("keywords") var keywords: String = ""
    @Published var answer: String = ""
    @Published var mainImage = ""
    @Published var title = ""
    @Published var currentWebpage = ""
    @Published var errorMessage = ""
    @Published var error = ""
    
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
        
        
        Task(priority: .high) {
            do {
                
                if array.isEmpty {
                    model = GenerativeModel(
                        name: "gemini-2.0-flash",
                        apiKey: apiKey,
                        generationConfig: GenerationConfig(temperature: 0.3),
                        safetySettings: safetySettings,
                        systemInstruction: """
                                           Here is a list of keywords the user has inputted: \(keywords).
                                           Here is also a list of different subreddits by category: \(generalInterestSubreddits), \(newsAndPoliticsSubreddits), \(scienceAndEducationSubreddits), \(technologySubreddits), \(gamingSubreddits), \(musicSubreddits), \(moviesAndTVSubreddits), \(sportsSubreddits), \(lifestyleAndHealthSubreddits), \(artAndDesignSubreddits), \(booksAndLiteratureSubreddits), \(foodAndCookingSubreddits), \(travelSubreddits), \(humorAndMemesSubreddits), \(personalFinanceSubreddits), \(educationAndLearningSubreddits), \(natureAndOutdoorsSubreddits), \(fashionAndStyleSubreddits), \(relationshipsAndAdviceSubreddits), \(miscellaneousSubreddits).
                                           
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
                        
//                        let data = try? await URLSession.shared.data(for: URLRequest(url: url, timeoutInterval: 15))
//                        
//                        guard let html = data.flatMap({ String(data: $0.0, encoding: .utf8) }) else { continue }
//                        
//                        let image = extractFaviconURL(from: html, baseURL: url)
                        
                        var postDate: Date? = nil
                        
                        if let host = url.host, host.contains("reddit.com") {
                            // Append ".json" if not already there.
                            let jsonURLString = url.absoluteString.hasSuffix(".json") ? url.absoluteString : url.absoluteString + ".json"
                            if let jsonURL = URL(string: jsonURLString) {
                                do {
                                    let (jsonData, _) = try await URLSession.shared.data(for: URLRequest(url: jsonURL, timeoutInterval: 15))
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any],
                                       let firstItem = jsonObject.first as? [String: Any],
                                       let dataDict = firstItem["data"] as? [String: Any],
                                       let children = dataDict["children"] as? [[String: Any]],
                                       let firstChild = children.first,
                                       let childData = firstChild["data"] as? [String: Any],
                                       let createdUTC = childData["created_utc"] as? TimeInterval {
                                        
                                        postDate = Date(timeIntervalSince1970: createdUTC)
                                        print("Parsed date from JSON: \(postDate!)")
                                    }
                                } catch {
                                    print("Error fetching JSON for post date: \(error)")
                                }
                            }
                        }
                        
                        
                        
                        
                        let categoryResponse = try await GenerativeModel(
                            name: "gemini-2.0-flash-lite-preview",
                            apiKey: apiKey,
                            generationConfig: GenerationConfig(temperature: 0.3),
                            safetySettings: safetySettings, systemInstruction: """
                               You are an AI responsible for categorizing Reddit posts using the predefined topic list: \(topicCategories).
                            
                               Give me ONLY a single category from this list—nothing else. Do not provide explanations, additional context, or categories that are not explicitly included in the list.
                            """
                        ).generateContent("Categorize this post: \(link.title ?? "")")
                        
                        
                        var item = SearchItem(
                            title: link.title ?? "No title",
                            link: urlString,
                            postDate: postDate ?? Date(),
                            category: categoryResponse.text ?? "General"
                        )
                        print("\nTitle: " + link.title!)
                        print("Category: " + categoryResponse.text! + "\n")
                        
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
    
    private func extractRedditPostDate(from html: String) -> Date? {
        do {
            let document = try HTMLDocument(string: html, encoding: .utf8)
            
            // First try to find a <time> tag with a datetime attribute
            if let timeElement = document.firstChild(xpath: "//time"),
               let datetime = timeElement.attr("datetime") {
                let formatter = ISO8601DateFormatter()
                if let date = formatter.date(from: datetime) {
                    return date
                }
            }
            
            // Alternatively, try a meta tag (if available)
            if let metaElement = document.firstChild(xpath: "//meta[@property='article:published_time']"),
               let content = metaElement.attr("content") {
                let formatter = ISO8601DateFormatter()
                if let date = formatter.date(from: content) {
                    return date
                }
            }
        } catch {
            print("Error extracting post date: \(error)")
        }
        return nil
    }
}
