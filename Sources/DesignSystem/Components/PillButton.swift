import SwiftUI

// Oval pill button used on Driving / Flights for multi/single select.
struct PillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.atmosmBody)
                .foregroundStyle(isSelected ? .white : AppColor.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(minWidth: 80)
                .background(
                    Capsule().fill(isSelected ? AppColor.primaryNavy : AppColor.fieldBackground)
                )
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : AppColor.primaryNavy, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// Small flowing row of pill buttons using wrapping FlexStack-style layout.
struct PillFlow<Item: Hashable>: View {
    let items: [Item]
    let title: (Item) -> String
    let isSelected: (Item) -> Bool
    let onTap: (Item) -> Void

    var body: some View {
        FlowLayout(spacing: 12, lineSpacing: 12) {
            ForEach(items, id: \.self) { item in
                PillButton(title: title(item), isSelected: isSelected(item)) {
                    onTap(item)
                }
            }
        }
    }
}

// Minimal wrapping flow layout for iOS 16+.
struct FlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var lineHeight: CGFloat = 0
        var x: CGFloat = 0

        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > maxWidth {
                totalHeight += lineHeight + lineSpacing
                x = 0
                lineHeight = 0
            }
            x += s.width + spacing
            lineHeight = max(lineHeight, s.height)
        }
        totalHeight += lineHeight
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += s.width + spacing
            lineHeight = max(lineHeight, s.height)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        PillButton(title: "Motorbike", isSelected: false) {}
        PillButton(title: "Car", isSelected: true) {}
        PillFlow(
            items: ["Motorbike","Car","Train","Bus","Bicycle","Walk"],
            title: { $0 },
            isSelected: { $0 == "Car" },
            onTap: { _ in }
        )
    }
    .padding()
    .background(AppColor.lightBlueBackground)
}
