import SwiftUI

// 4-segment password strength bar used on the Signup screen.
struct PasswordStrengthBar: View {
    let strength: Int // 0...4

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index < strength ? AppColor.primaryNavy : AppColor.strengthBarInactive)
                    .frame(height: 4)
                    .overlay(
                        Capsule().stroke(AppColor.fieldBorder, lineWidth: index < strength ? 0 : 1)
                    )
            }
        }
    }

    static func evaluate(_ password: String) -> Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .letters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        let specials = CharacterSet(charactersIn: "!@#$%^&*()_+-={}[]|\\:;\"'<>,.?/~`")
        if password.rangeOfCharacter(from: specials) != nil { score += 1 }
        return score
    }
}

#Preview {
    VStack(spacing: 12) {
        PasswordStrengthBar(strength: 1)
        PasswordStrengthBar(strength: 2)
        PasswordStrengthBar(strength: 3)
        PasswordStrengthBar(strength: 4)
    }
    .padding()
    .background(AppColor.creamBackground)
}
