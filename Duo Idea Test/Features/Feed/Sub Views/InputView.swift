//
//  InputView.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/19/25.
//


import SwiftUI


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



