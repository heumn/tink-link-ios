import UIKit
/// A custom appearance provider.
///
/// If you set a custom appearance provider, all TinkLinkUI SDK views will use
/// this provider to retreive colors and fonts.

/// You can change the appearance of Tink Link UI to match the rest of your app.

/// To change colors or fonts, update the `Appearance.provider` before initializing the `TinkLinkViewController`.
/// ```swift
/// Appearance.provider.colors.accent = <#UIColor#>
/// ```
/// ### Colors
/// These are the colors that can be changed:
/// |`Color`|Description|
/// |--------|-------------|
/// |`background`|Color for the main background of the interface.|
/// |`secondaryBackground`|Color for content layered on top of the main background.|
/// |`groupedBackground`|Color for the main background of grouped interface components.|
/// |`secondaryGroupedBackground`|Color for content layered on top of the main background of grouped interface components.|
/// |`label`|Primary text color.|
/// |`secondaryLabel`|Secondary text color.|
/// |`separator`|Color for separators.|
/// |`accent`|Colors for buttons, indicators and other similar elements.|
/// |`warning`|Color representing a warning.|
/// |`critical`|Color representing a critical warning or error.|
public enum Appearance {
    public static var provider: AppearanceProviding = AppearanceProvider() {
        didSet {
            customColorProvider = provider.colors
            customFontProvider = provider.fonts
        }
    }

    static var defaultProvider: AppearanceProviding = AppearanceProvider()

    /// A custom color provider.
    ///
    /// If you set a custom color provider, all Tink PFM SDK views will use
    /// this provider to retreive colors.
    static var colorProvider: ColorProviding! {
        get {
            customColorProvider ?? defaultProvider.colors
        }
        set {
            if let newProvider = newValue {
                customColorProvider = newProvider
            } else {
                customColorProvider = nil
            }
        }
    }

    private static var customColorProvider: ColorProviding?

    /// A custom font provider.
    ///
    /// If you set a custom font provider, all Tink PFM SDK views will use
    /// this provider to retreive fonts.
    static var fontProvider: FontProviding! {
        get {
            customFontProvider ?? defaultProvider.fonts
        }
        set {
            if let newProvider = newValue {
                customFontProvider = newProvider
            } else {
                customFontProvider = nil
            }
        }
    }

    private static var customFontProvider: FontProviding?
}
