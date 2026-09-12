//
//  SplashView.swift
//  CineTunes
//
//  Created by Joseph, Joel on 2025-06-09.
//

import SwiftUI

struct SplashView: View {
    @State private var isShowingSplash = true
    @State private var logoOpacity = 0.0

    var body: some View {
        ZStack {
            // Kept in the hierarchy from the start so the splash can actually
            // cross-fade into it instead of swapping views instantly.
            MainTabView()

            if isShowingSplash {
                splashOverlay
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            withAnimation(.easeIn(duration: 1.0)) {
                logoOpacity = 1.0
            }

            // Cancelled automatically if the view disappears, unlike asyncAfter.
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation(.easeOut(duration: 0.6)) {
                isShowingSplash = false
            }
        }
    }

    private var splashOverlay: some View {
        VStack {
            Spacer()

            Image("cinetunes_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .opacity(logoOpacity)

            Text("CineTunes")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .opacity(logoOpacity)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
