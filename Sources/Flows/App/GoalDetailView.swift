import SwiftUI
import UIKit

// Figma node 55:252 — Reduce detail "Advocacy and Choice > Vacation Close to Home".
// Hero image, Add-to-my-goals + coin reward badge, 3-step progress bar, description,
// social share row.
struct GoalDetailView: View {
    @Bindable var app: AppState
    let goal: Goal
    let onBack: () -> Void

    @State private var isProcessing = false
    // Bumped whenever this goal transitions into `.complete`, which drives
    // the one-shot confetti burst overlay.
    @State private var celebrationTick = 0

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                ZStack {
                    HStack {
                        IconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
                        Spacer()
                    }
                    Text("Reduce")
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.primaryNavy)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        breadcrumb
                            .padding(.top, 8)

                        heroImage
                            .padding(.top, 4)

                        // Add-to-my-goals + coin reward
                        HStack(alignment: .center, spacing: 16) {
                            addButton
                            Spacer(minLength: 0)
                            coinReward
                        }
                        .padding(.top, 8)

                        if let current = app.myGoal(for: goal.id) {
                            GoalProgressBar(status: GoalStatus(rawValue: current.status) ?? .added)
                                .padding(.top, 8)

                            advanceButtons(for: current)
                                .padding(.top, 4)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.atmosmTitle)
                                .foregroundStyle(AppColor.primaryNavy)
                            Text(goal.body)
                                .font(.atmosmBody)
                                .foregroundStyle(AppColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 16)

                        shareRow
                            .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .overlay(
            ConfettiBurst(trigger: celebrationTick)
                .allowsHitTesting(false)
        )
        .onChange(of: app.myGoal(for: goal.id)?.status) { _, newStatus in
            // Celebrate when the server confirms the goal flipped to
            // `.complete`. Driving off the actual status change means we
            // also celebrate if the user completes from another device or
            // the retry path eventually succeeds.
            if newStatus == GoalStatus.complete.rawValue {
                Haptics.success()
                celebrationTick &+= 1
            }
        }
        .navigationBarBackButtonHidden()
        // NOTE: intentionally no `.task { reload }` here — AppShellView
        // already refreshes on tab switch, and reloadFromServer() has a
        // 5s freshness cache, so we'd either duplicate work or no-op.
    }

    // MARK: - Pieces

    private var breadcrumb: some View {
        (
            Text("\(goal.category) > ")
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
            + Text(goal.title)
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
        )
    }

    private var heroImage: some View {
        Group {
            if UIImage(named: goal.imageAsset) != nil {
                Image(goal.imageAsset)
                    .resizable().scaledToFill()
            } else {
                Rectangle().fill(AppColor.fieldBackground)
                    .overlay(Image(systemName: "photo").foregroundStyle(AppColor.textSecondary))
            }
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var addButton: some View {
        let isAdded = app.myGoal(for: goal.id) != nil
        Button {
            guard !isAdded, !isProcessing else { return }
            isProcessing = true
            Task {
                await app.addGoal(goal.id)
                await MainActor.run { isProcessing = false }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 18, weight: .semibold))
                Text(isAdded ? "Added" : "Add to my goals")
                    .font(.atmosmBody.bold())
            }
            .foregroundStyle(AppColor.primaryNavy)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Capsule().stroke(AppColor.primaryNavy, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .disabled(isAdded || isProcessing)
    }

    private var coinReward: some View {
        HStack(spacing: 8) {
            if UIImage(named: "AtmosmCoin") != nil {
                Image("AtmosmCoin")
                    .resizable().scaledToFit()
                    .frame(width: 38, height: 42)
            } else {
                Image(systemName: "dollarsign.circle.fill")
                    .resizable().scaledToFit()
                    .frame(width: 38, height: 42)
                    .foregroundStyle(.yellow)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("\(goal.coinReward)")
                    .font(.atmosmTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text("Atmosm Coins")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
    }

    @ViewBuilder
    private func advanceButtons(for current: UserGoal) -> some View {
        let status = GoalStatus(rawValue: current.status) ?? .added
        HStack(spacing: 12) {
            if status == .added {
                PrimaryButton(title: "Start working on it", style: .navy) {
                    Haptics.impact(.medium)
                    Task { await app.updateGoal(goal.id, status: .inProgress) }
                }
            }
            if status == .inProgress {
                PrimaryButton(title: "Mark Complete", style: .green) {
                    // Fire feedback *before* the network round-trip so it
                    // feels instant. The confetti + success haptic gate on
                    // the actual transition to `.complete` via onChange.
                    Haptics.impact(.medium)
                    Task { await app.updateGoal(goal.id, status: .complete) }
                }
            }
            if status == .complete {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("You earned \(current.coinsEarned) Atmosm Coins!")
                        .font(.atmosmBody.bold())
                        .foregroundStyle(AppColor.primaryNavy)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.lightBluePill))
            }
        }
    }

    private var shareRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share Ideas")
                .font(.atmosmTitle)
                .foregroundStyle(AppColor.primaryNavy)

            HStack(spacing: 16) {
                shareChip(systemName: "f.circle.fill",        color: Color(red: 24/255, green: 119/255, blue: 242/255))
                shareChip(systemName: "l.circle.fill",        color: Color(red: 10/255, green: 102/255, blue: 194/255))
                shareChip(systemName: "phone.bubble.fill",    color: Color(red: 37/255, green: 211/255, blue: 102/255))
                shareChip(systemName: "camera.fill",          color: Color(red: 255/255, green: 252/255, blue: 0/255))
                shareChip(systemName: "camera.aperture",      color: Color(red: 220/255, green: 39/255, blue: 143/255))
            }
        }
    }

    private func shareChip(systemName: String, color: Color) -> some View {
        Button {
            presentShareSheet(text: goal.shareText ?? "Check out '\(goal.title)' on Atmosm — I'm earning \(goal.coinReward) Atmosm Coins!")
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 8).fill(color))
        }
        .buttonStyle(.plain)
    }

    private func presentShareSheet(text: String) {
        guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        root.present(vc, animated: true)
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(
            app: AppState(),
            goal: Goal(
                id: UUID(),
                category: "Advocacy and Choice",
                title: "Vacation Close to Home",
                body: "Skip the long-haul flight this year and discover somewhere within a few hours of home.",
                imageAsset: "ReduceCardForest",
                coinReward: 500,
                shareText: nil
            ),
            onBack: {}
        )
    }
}
