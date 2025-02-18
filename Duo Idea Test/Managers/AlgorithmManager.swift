//
//  AlgorithmManager.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/18/25.
//

import Foundation


class AlgorithmManager {
    
    // Singleton
    static let shared = AlgorithmManager()
    
    
    var likedCategories = [String: Int]() {
        didSet {
            UserDefaults.standard.set(likedCategories, forKey: "likedCategories")
        }
    }
    
    
    var likedPosts = [SearchItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(likedPosts) {
                UserDefaults.standard.set(encoded, forKey: "likedPosts")
            }
        }
    }
    
    
    var dislikedPosts = [SearchItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(dislikedPosts) {
                UserDefaults.standard.set(encoded, forKey: "dislikedPosts")
            }
        }
    }
    
    init() {
        // Load likedCategories from UserDefaults
        if let savedLikedCategories = UserDefaults.standard.dictionary(forKey: "likedCategories") as? [String: Int] {
            likedCategories = savedLikedCategories
        }
        
        if let savedDislikedPostsData = UserDefaults.standard.data(forKey: "dislikedPosts"),
           let decodedPosts = try? JSONDecoder().decode([SearchItem].self, from: savedDislikedPostsData) {
            dislikedPosts = decodedPosts
        }
        
        // Load likedPosts from UserDefaults
        if let savedLikedPostsData = UserDefaults.standard.data(forKey: "likedPosts"),
           let decodedPosts = try? JSONDecoder().decode([SearchItem].self, from: savedLikedPostsData) {
            likedPosts = decodedPosts
        }
    }
}
