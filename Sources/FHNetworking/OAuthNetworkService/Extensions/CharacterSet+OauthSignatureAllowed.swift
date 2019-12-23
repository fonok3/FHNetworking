//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

extension CharacterSet {
    /// Returns a character set containing uppercase letters, lowercase letters and digits.
    static let oauthSignatureAllowed: CharacterSet = CharacterSet(charactersIn: "-_.~")
        .union(.uppercaseLetters)
        .union(.lowercaseLetters)
        .union(.decimalDigits)
}
