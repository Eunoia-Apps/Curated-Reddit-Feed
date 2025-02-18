//
//  WebView.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/18/25.
//


import WebKit
import SwiftUI


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


