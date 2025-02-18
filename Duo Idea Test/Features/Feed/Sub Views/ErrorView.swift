//
//  ErrorView.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/19/25.
//

import SwiftUI


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

