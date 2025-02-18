//
//  LoadingView.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/19/25.
//



import SwiftUI


// MARK: - LoadingView
struct LoadingView: View {
    
    
    
    var body: some View {
        ScrollView {
            
            ForEach(0..<8) { _ in
                VStack(spacing: 16) {
                    
                    
                    VStack(spacing: 0) {
                        
                        
                        VStack {
                            
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 164) // Matches the expected size
                                .cornerRadius(8)
                                .shimmerEffect(isLoading: .constant(true))
                            
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 10) // Matches the expected size
                                .cornerRadius(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .shimmerEffect(isLoading: .constant(true))
                                .padding(.top, 4)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 10) // Matches the expected size
                                .cornerRadius(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .shimmerEffect(isLoading: .constant(true))
                                .padding(.top, 2)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        
                        
                        HStack(spacing: 4) {
                            Text("placeholder")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .opacity(0)
                            
                            Spacer()
                            
                            Text("placeholder")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .opacity(0)
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        
                        
                    }
                    .background(.gray.opacity(0.09))
                    .cornerRadius(8)
                    .redacted(reason: .placeholder)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary.opacity(0.1), lineWidth: 1)
                    }
                    
                    
                    HStack(spacing: 10) {
                        
                        // Like buttons
                        Image(systemName: "heart")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        
                        
                        // Dislike button
                        Image(systemName: "hand.thumbsdown")
                            .font(.system(size: 18.5))
                            .foregroundColor(.gray)
                        
                        
                        Image(systemName: "text.bubble")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        
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
                
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



