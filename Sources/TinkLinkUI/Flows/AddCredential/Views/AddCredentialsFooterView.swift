import UIKit
import TinkLink

protocol AddCredentialsFooterViewDelegate: AnyObject {
    func addCredentialFooterViewDidTapLink(_ addCredentialFooterView: AddCredentialsFooterView, url: URL)
}

final class AddCredentialsFooterView: UIView {
    weak var delegate: AddCredentialsFooterViewDelegate?

    private lazy var descriptionTextView: UITextView = {
        let descriptionTextView = UnselectableTextView()
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.isEditable = false
        descriptionTextView.clipsToBounds = false
        descriptionTextView.backgroundColor = Color.background
        descriptionTextView.setLineHeight(lineHeight: 20)
        descriptionTextView.linkTextAttributes = [
            .foregroundColor: Color.secondaryLabel,
            .font: Font.regular(.micro),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.textContainerInset = .zero
        let text = NSLocalizedString("AddCredentials.Consent.ServiceAgreement", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "By using the service, you agree to Tink’s Terms and Conditions and Privacy Policy", comment: "Text explaining that when using the service, the user agrees to Tink's Terms and Conditions and Privacy Policy.")
        let attributeText = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: Color.secondaryLabel, .font: Font.regular(.micro)])
        let languageCode = Locale.current.languageCode ?? ""
        let privacyPolicyUrl = URL(string: "https://link.tink.com/privacy-policy/\(languageCode)")!
        let privacyPolicyText = NSLocalizedString("AddCredentials.Consent.PrivacyPolicy", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Privacy Policy", comment: "Title of the Privacy Policy link. This has to match the mention of the Privacy Policy in the `AddCredentials.Consent.ServiceAgreement` string.")
        let privacyPolicyRange = attributeText.mutableString.range(of: privacyPolicyText)
        self.privacyPolicyRange = privacyPolicyRange
        attributeText.addAttributes([.link: privacyPolicyUrl,], range: privacyPolicyRange)
        let termsAndConditionsText = NSLocalizedString("AddCredentials.Consent.TermsAndConditions", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Terms and Conditions", comment: "Title of the Privacy Policy link. This has to match the mention of the Terms and Conditions in the `AddCredentials.Consent.ServiceAgreement` string.")
        let termsAndConditionsUrl = URL(string: "https://link.tink.com/terms-and-conditions/\(languageCode)")!
        let termsAndConditionsRange = attributeText.mutableString.range(of: termsAndConditionsText)
        self.termsAndConditionsRange = termsAndConditionsRange
        attributeText.addAttributes([.link: termsAndConditionsUrl], range: termsAndConditionsRange)
        descriptionTextView.attributedText = attributeText
        descriptionTextView.adjustsFontForContentSizeCategory = true
        descriptionTextView.setLineHeight(lineHeight: 20)
        return descriptionTextView
    }()

    private var privacyPolicyRange: NSRange?
    private var termsAndConditionsRange: NSRange?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setup() {
        addSubview(descriptionTextView)

        layoutMargins = .init(top: 12, left: 0, bottom: 12, right: 0)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
}

extension AddCredentialsFooterView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            if characterRange == termsAndConditionsRange || characterRange == privacyPolicyRange {
                delegate?.addCredentialFooterViewDidTapLink(self, url: URL)
                return false
            } else {
                return true
            }
        default:
            return true
        }
    }
}
