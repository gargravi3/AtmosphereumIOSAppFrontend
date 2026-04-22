import SwiftUI

struct AtmosmTextField<Field: Hashable>: View {
    let label: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var labelColor: Color = AppColor.textPrimary

    // Keyboard / input behaviour — callers can override per-field.
    var capitalization: TextInputAutocapitalization = .never
    var autocorrect: Bool = false
    var keyboardType: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .done
    var textContentType: UITextContentType? = nil

    // Focus coordination. Pass the @FocusState binding and the enum value
    // that identifies THIS field.
    var focus: FocusState<Field?>.Binding? = nil
    var focusValue: Field? = nil

    @Binding var text: String

    // Called when the user presses the submit/return key.
    var onSubmit: (() -> Void)? = nil

    @State private var isRevealed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.atmosmLabel)
                .foregroundStyle(labelColor)

            ZStack(alignment: .trailing) {
                inputField
                    .textInputAutocapitalization(capitalization)
                    .autocorrectionDisabled(!autocorrect)
                    .keyboardType(keyboardType)
                    .submitLabel(submitLabel)
                    .textContentType(textContentType)
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
                    .tint(AppColor.primaryNavy)
                    .padding(.horizontal, 12)
                    .padding(.trailing, isSecure ? 44 : 12)
                    .frame(height: 52)
                    .background(AppColor.fieldBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(AppColor.fieldBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .onSubmit { onSubmit?() }
                    .modifier(FocusApplier(focus: focus, value: focusValue))

                if isSecure {
                    Button(action: { isRevealed.toggle() }) {
                        Image(systemName: isRevealed ? "eye" : "eye.slash")
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(.trailing, 14)
                }
            }
        }
    }

    @ViewBuilder
    private var inputField: some View {
        if isSecure && !isRevealed {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }
}

// Applies `.focused($focus, equals: value)` only if both are provided.
// Avoids forcing every caller to supply focus coordination.
private struct FocusApplier<Field: Hashable>: ViewModifier {
    let focus: FocusState<Field?>.Binding?
    let value: Field?

    func body(content: Content) -> some View {
        if let focus, let value {
            content.focused(focus, equals: value)
        } else {
            content
        }
    }
}

// Convenience: non-focus-coordinated variant — keeps simple callers terse.
extension AtmosmTextField where Field == Never {
    init(
        label: String,
        placeholder: String = "",
        isSecure: Bool = false,
        labelColor: Color = AppColor.textPrimary,
        capitalization: TextInputAutocapitalization = .never,
        autocorrect: Bool = false,
        keyboardType: UIKeyboardType = .default,
        submitLabel: SubmitLabel = .done,
        textContentType: UITextContentType? = nil,
        text: Binding<String>,
        onSubmit: (() -> Void)? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.labelColor = labelColor
        self.capitalization = capitalization
        self.autocorrect = autocorrect
        self.keyboardType = keyboardType
        self.submitLabel = submitLabel
        self.textContentType = textContentType
        self.focus = nil
        self.focusValue = nil
        self.onSubmit = onSubmit
        self._text = text
    }
}

#Preview {
    @Previewable @State var name = ""
    @Previewable @State var pwd = ""
    return VStack(spacing: 20) {
        AtmosmTextField(label: "First Name", capitalization: .words, text: $name)
        AtmosmTextField(label: "Password", isSecure: true, text: $pwd)
    }
    .padding()
    .background(AppColor.creamBackground)
}
