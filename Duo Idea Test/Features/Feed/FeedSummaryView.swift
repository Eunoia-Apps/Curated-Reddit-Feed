//
//  FeedSummaryView.swift
//  Duo Idea Test
//
//  Created by David Empire on 2/17/25.
//

import SwiftUI
import LangChain
import AsyncHTTPClient
import NIOPosix
import ActivityIndicatorView
import ChatField
import GoogleGeminiAI
import SwiftData

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
    @Published var customPrompt = ""
    @Published var errorText = ""
    @Published var progressText = ""
    @Published var imageURL = ""
    
    func restart() {
        viewState = .input
        output = ""
        url = ""
        customPrompt = ""
        imageURL = ""
        errorText = ""
        progressText = ""
    }
    
    
}



struct FeedSummaryView: View {

    @ObservedObject var viewModel: FeedSummaryViewModel
    @State private var showSelectTextSheet = false
    
    @AppStorage("hasCustomAPIKeyIAP") var hasCustomAPIKeyIAP = false
    
    static let userDefaults = UserDefaults(suiteName: "group.demo.app")!
    @AppStorage("hasPro", store: userDefaults) var hasPro: Bool = false
    
    @State private var showMessageLimitAlert = false
    
    var modelContext: ModelContext? = nil
    
    
    
    var body: some View {
        VStack {
            
            if viewModel.viewState == .loading  {
                VStack {
                    ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 4))
                        .frame(width: 54, height: 80)
                    
                    Text(viewModel.progressText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .animation(.smooth)
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
    
    
    
    
    //MARK: Viewmodel Functions
    
    func sumWeb() {
        
        Task {
            
            viewModel.progressText = "Beginning task."
            
            viewModel.viewState = .loading
            
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            
            let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            
            defer {
                try? httpClient.syncShutdown()
            }
            
            do {
                
                viewModel.progressText = "Fetching webpage."
                
                var request = HTTPClientRequest(url: viewModel.url)
                
                request.headers.add(name: "User-Agent", value: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/115.0.5790.130 Mobile/15E148 Safari/604.1")
                request.method = .GET
                
                let response = try await httpClient.execute(request, timeout: .seconds(180))
                print(response.headers)
                
                if response.status == .ok {
                    let plain = String(buffer: try await response.body.collect(upTo: 1024 * 1024 * 100))
                    
                    let customPromptText = viewModel.customPrompt
                    
                    let promptText = "The following is the content of the webpage: {content}, \(customPromptText)"
                    
                    viewModel.progressText = "Loading webpage."
                    
                    let loader = HtmlLoader(html: plain, url: viewModel.url)
                    let doc = await loader.load()
                    
                    if doc.isEmpty {
                        throw "Empty webpage data."
                    } else {
                        
                        let prompt = PromptTemplate(input_variables: ["content"], partial_variable: [:], template: promptText)
                        let request = prompt.format(args: ["content": String(doc.first!.page_content.prefix(1200))])
                        let llm = Gemini()
                        
                        LC.initSet([
                            "GOOGLEAI_API_KEY" : "AIzaSyDEO2Lre7O5utIO6uY2VreVa_paU3G3hSk"
                        ])
                        
                        viewModel.progressText = "Sending task to Gemini."
                        
                        let reply = await llm.generate(text: request)
                        
                        let image = findImage(text: plain)
                        
                        viewModel.imageURL = image
                        
                        print("image: \(image)")
                        
                        if reply == nil {
                            throw "There was a problem with the server response. Try again or restart the app."
                        }
                        
                        if reply!.llm_output == nil {
                            throw "There was a problem with Gemini's response. Try again or restart the app."
                        }
                        
                        viewModel.output = reply!.llm_output!
                        
                        
                        
                        viewModel.viewState = .output
                        
                        
                        
                    }
                    
                } else {
                    print("get html, http code is not 200. \(response.status)")
                    throw "HTTP Error Code: \(response.status)."
                }
                
            } catch {
                print(error)
                
                viewModel.viewState = .error
                viewModel.errorText = error.localizedDescription
                viewModel.progressText = ""
                
            }
        }
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
