//
//  NetworkStatusBanner.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI

struct NetworkStatusBanner: View {
    let isConnected: Bool
    
    var body: some View {
        if !isConnected {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.headline)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text("network.offline.title".localized())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Text("network.offline.description".localized())
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.gradient)
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
