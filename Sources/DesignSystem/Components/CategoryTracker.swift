import SwiftUI

// Navy-circle progress bar showing 6 tracker categories.
// The active category is larger (48x48) with a bigger icon; the rest are 32x32.
// A thin navy line connects them behind the circles.
struct CategoryTracker: View {
    let current: TrackerCategory

    var body: some View {
        ZStack(alignment: .center) {
            // Connecting line behind the circles.
            GeometryReader { geo in
                Rectangle()
                    .fill(AppColor.primaryNavy)
                    .frame(height: 2)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }

            HStack(spacing: 0) {
                ForEach(TrackerCategory.order, id: \.self) { cat in
                    let isCurrent = cat == current
                    ZStack {
                        Circle()
                            .fill(AppColor.primaryNavy)
                            .frame(width: isCurrent ? 48 : 32, height: isCurrent ? 48 : 32)
                        Image(systemName: cat.systemIcon)
                            .font(.system(size: isCurrent ? 20 : 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: 48)
    }
}

#Preview {
    VStack(spacing: 24) {
        CategoryTracker(current: .driving)
        CategoryTracker(current: .food)
        CategoryTracker(current: .waste)
    }
    .padding()
    .background(AppColor.lightBlueBackground)
}
