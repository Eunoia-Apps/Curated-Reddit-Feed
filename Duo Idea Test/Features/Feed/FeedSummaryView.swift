//
//  FeedSummaryView.swift
//  Duo Idea Test
//
//  Created by David Empire on 2/17/25.
//

import SwiftUI
import ActivityIndicatorView
import GoogleGeminiAI

enum ToolState {
    case input
    case loading
    case output
    case error
}


@MainActor
class FeedSummaryViewModel: ObservableObject {
        
    @Published var viewState: ToolState = .input
    @Published var output = ""
    @Published var url = ""
    @Published var errorText = ""
    @Published var progressText = ""
    @Published var apiKey = "AIzaSyDawRzTtS5kG-fO53AB644r3U8qoJLgHJQ"
    
    func restart() {
        viewState = .input
        output = ""
        url = ""
        errorText = ""
        progressText = ""
    }
    
    
    
    func sumWeb(post: SearchItem) {
        
        Task {
                        
            viewState = .loading
            
            do {
                
                let model = GenerativeModel(
                    name: "gemini-2.0-flash",
                    apiKey: apiKey,
                    generationConfig: GenerationConfig(temperature: 0.4),
                    systemInstruction: """
                                       Summarize this reddit post in 100 words or less.
                                   """
                )
                
                let response = try await model.generateContent("The following is the content of a reddit post, summarize it in 100 words or less: \(post.title),\n \(post.text)\n")
                
                output = response.text ?? "No summary found."
                
                viewState = .output
                
            } catch {
                print(error)
                
                viewState = .error
                errorText = error.localizedDescription
                
            }
        }
    }
    
    
}



struct FeedSummaryView: View {

    @ObservedObject var viewModel: FeedSummaryViewModel
   
    var body: some View {
        VStack {
            
            if viewModel.viewState == .loading  {
                VStack {
                    ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 4))
                        .frame(width: 34, height: 60)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            
            if viewModel.viewState == .output {
                ScrollView {
                    
                    Text(viewModel.output)
                        .font(.callout)
                        .padding()
                        .contextMenu {
                            Button(action: copyText) {
                                Text("Copy")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                }
            }
            
            if viewModel.viewState == .error {
                VStack {
                    ScrollView {
                        Text(viewModel.errorText)
                            .font(.callout)
                            .padding()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    
    private func copyText() {
        UIPasteboard.general.string = viewModel.output
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func findImage(text: String) -> String {
        let pattern = "(http|https)://[\\S]+?\\.(jpg|jpeg|png|gif)"
        
        do {
            print(text)
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            if matches.isEmpty {
                return ""
            } else {
                return String(text[Range(matches.first!.range, in: text)!])
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return ""
        }
    }
    
    
}
