//
//  OfflineStateView.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI

/// A reusable view that displays an offline state with no cached data
struct OfflineStateView: View {
    let message: String?
    let retryAction: (() async -> Void)?
    
    init(
        message: String? = nil,
        retryAction: (() async -> Void)? = nil
    ) {
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        ContentUnavailableView {
            Label("offline.title".localized(), systemImage: "wifi.slash")
        } description: {
            VStack(spacing: 12) {
                Text(message ?? "offline.description".localized())
                    .multilineTextAlignment(.center)
                
                if let retryAction = retryAction {
                    Button {
                        Task {
                            await retryAction()
                        }
                    } label: {
                        Label("offline.retry".localized(), systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
            }
        } actions: {
            Text("offline.hint".localized())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// A banner that shows when the device is offline but cached data is being shown
struct OfflineBannerView: View {
    @Environment(\.dismiss) private var dismiss
    let canDismiss: Bool
    
    init(canDismiss: Bool = false) {
        self.canDismiss = canDismiss
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.body.weight(.medium))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("offline.banner.title".localized())
                    .font(.subheadline.weight(.semibold))
                Text("offline.banner.description".localized())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if canDismiss {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.15))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
        }
        .padding(.horizontal)
    }
}
