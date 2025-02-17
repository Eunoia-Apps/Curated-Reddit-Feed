//
//  View.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/18/25.
//

import Foundation
import SwiftUI


extension View {
    func shimmerEffect(isLoading: Binding<Bool>, gradient: Gradient = ShimmerEffect.defaultGradient, animation: Animation =  ShimmerEffect.defaultAnimation, angle: Angle =  ShimmerEffect.defaultAngle) -> some View {
        self.modifier(ShimmerEffect(isLoading: isLoading, gradient: gradient, animation: animation, angle: angle))
    }
}


struct ShimmerEffect: Animatable, ViewModifier {
    @Binding var isLoading: Bool
    
    @State private var isAnimating: Bool = false
    private let animation: Animation
    private let gradient: Gradient
    private let angle: Angle
    private let min = -0.5
    private let max = 1.5
    
    
    public static let defaultGradient: Gradient = Gradient(colors: [.gray.opacity(0.4), .primary.opacity(0.3), .gray.opacity(0.4)])
    public static let defaultAnimation = Animation.linear(duration: 1.25).repeatForever(autoreverses: false)
    public static let defaultAngle = Angle.degrees(0.0)
    
    init(isLoading: Binding<Bool>,
         gradient: Gradient = Self.defaultGradient,
         animation: Animation = Self.defaultAnimation,
         angle: Angle = Self.defaultAngle
    ) {
        self._isLoading = isLoading
        self.gradient = gradient
        self.animation = animation
        self.angle = angle
    }
    
    func body(content: Content) -> some View {
        if isLoading {
            content.overlay(content: {
                shimmerView
                    .mask(content)
            })
        } else {
            content
        }
    }
    
    var startPoint: UnitPoint {
        isAnimating ? UnitPoint(x: 1, y: 1) : UnitPoint(x: min, y: min)
    }
    var endPoint: UnitPoint {
        isAnimating ? UnitPoint(x: max, y: max) : UnitPoint(x: 0, y: 0)
    }
    
    var shimmerView: some View {
        LinearGradient(gradient: self.gradient, startPoint: startPoint , endPoint: endPoint)
            .rotationEffect(angle)
            .scaleEffect(1.5)
            .clipped()
            .animation(animation, value: isAnimating)
            .onAppear {
                guard isLoading else {return}
                isAnimating = true
            }
            .onChange(of: isLoading, {
                isAnimating.toggle()
            })
    }
}
