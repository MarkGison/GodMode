import SwiftUI

enum DesignTokens {
    enum Color {
        static let canvas = SwiftUI.Color(red: 0.035, green: 0.043, blue: 0.067)
        static let surface = SwiftUI.Color(red: 0.075, green: 0.086, blue: 0.122)
        static let textPrimary = SwiftUI.Color(red: 0.96, green: 0.97, blue: 1)
        static let textSecondary = SwiftUI.Color(red: 0.68, green: 0.72, blue: 0.81)
        static let energy = SwiftUI.Color(red: 0.72, green: 0.61, blue: 1)
        static let onEnergy = canvas
        static let information = SwiftUI.Color(red: 0.43, green: 0.76, blue: 1)
        static let gold = SwiftUI.Color(red: 0.94, green: 0.77, blue: 0.40)
        static let success = SwiftUI.Color(red: 0.43, green: 0.86, blue: 0.66)
        static let warning = gold
        static let error = SwiftUI.Color(red: 1, green: 0.56, blue: 0.59)
        static let disabled = textSecondary
        static let border = SwiftUI.Color(red: 0.20, green: 0.22, blue: 0.29)
    }
    enum Rarity {
        static let common = Color.textSecondary
        static let uncommon = Color.success
        static let rare = Color.information
        static let epic = Color.energy
        static let legendary = Color.gold
        static let mythic = Color.error
    }
    enum Space {
        static let inline: CGFloat = 8
        static let content: CGFloat = 16
        static let section: CGFloat = 24
        static let page: CGFloat = 20
    }
    enum TypeStyle {
        static let hero = Font.largeTitle.bold()
        static let title = Font.title2.bold()
        static let section = Font.headline
        static let body = Font.body
        static let caption = Font.subheadline
    }
    enum Radius { static let card: CGFloat = 20; static let control: CGFloat = 12 }
    enum Line { static let border: CGFloat = 1 }
    enum Size {
        static let minimumTarget: CGFloat = 44
        static let icon: CGFloat = 24
        static let contentMaximum: CGFloat = 640
    }
    enum Motion { static let feedback = 0.16; static let transition = 0.28 }
    enum Opacity { static let subtle = 0.15 }
    enum Shadow { static let card: CGFloat = 12 }
    enum Material { static let panel = SwiftUI.Material.regular }
    enum Haptics { case setComplete, countdown, workoutComplete, personalRecord, loot, levelUp, rankUp }
}
