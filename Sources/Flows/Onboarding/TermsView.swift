import SwiftUI

struct TermsView: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    Spacer()
                    AtmosmLogoImage()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColor.primaryNavy, lineWidth: 1))
                    Spacer()
                    Spacer().frame(width: 20) // balance the chevron
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Text("Terms & Conditions")
                    .font(.atmosmTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(Self.lorem1)
                        Text(Self.lorem2)
                    }
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }

                PrimaryButton(title: "Go Back", style: .navy) {
                    onBack()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private static let lorem1 = """
    Lorem Ipsum Is Simply Dummy Text Of The Printing And Typesetting Industry. Lorem Ipsum Has Been The Industry's Standard Dummy Text Ever Since The 1500s, When An Unknown Printer Took A Galley Of Type And Scrambled It To Make A Type Specimen Book. It Has Survived Not Only Five Centuries, But Also The Leap Into Electronic Typesetting, Remaining Essentially Unchanged. It Was Popularised In The 1960s With The Release Of Letraset Sheets Containing Lorem Ipsum Passages, And More Recently With Desktop Publishing Software Like Aldus PageMaker Including Versions Of Lorem Ipsum.
    """

    private static let lorem2 = """
    It Is A Long Established Fact That A Reader Will Be Distracted By The Readable Content Of A Page When Looking At Its Layout. The Point Of Using Lorem Ipsum Is That It Has A More-Or-Less Normal Distribution Of Letters, As Opposed To Using 'Content Here, Content Here', Making It Look Like Readable English. Many Desktop Publishing Packages And Web Page Editors Now Use Lorem Ipsum As Their Default Model Text, And A Search For 'lorem Ipsum' Will Uncover Many Web Sites Still In Their Infancy. Various Versions Have Evolved Over The Years, Sometimes By Accident, Sometimes On Purpose (Injected Humour And The Like).
    """
}

#Preview {
    NavigationStack {
        TermsView(onBack: {})
    }
}
