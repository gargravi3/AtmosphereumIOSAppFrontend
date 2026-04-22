import SwiftUI

// Three-step horizontal progress bar: Start → Work In Progress → Complete.
// Matches Figma node 157:158 on the Reduce detail screen.
struct GoalProgressBar: View {
    let status: GoalStatus

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColor.lightBluePill)
                        .frame(height: 4)
                    Capsule()
                        .fill(AppColor.primaryNavy)
                        .frame(width: geo.size.width * fraction, height: 4)
                }
            }
            .frame(height: 4)

            HStack {
                Text("Start")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Work in Progress")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Complete")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var fraction: Double {
        switch status {
        case .added:      return 0.05
        case .inProgress: return 0.5
        case .complete:   return 1.0
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        GoalProgressBar(status: .added)
        GoalProgressBar(status: .inProgress)
        GoalProgressBar(status: .complete)
    }
    .padding()
    .background(AppColor.lightBlueBackground)
}
