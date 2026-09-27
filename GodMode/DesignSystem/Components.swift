import SwiftUI

struct Page<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Space.section) { content }
                .frame(maxWidth: DesignTokens.Size.contentMaximum, alignment: .leading)
                .padding(DesignTokens.Space.page)
                .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(DesignTokens.Color.canvas)
        .foregroundStyle(DesignTokens.Color.textPrimary)
    }
}

struct Panel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Space.content) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Space.content)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(DesignTokens.Color.border, lineWidth: DesignTokens.Line.border)
            }
    }
}

struct FutureFeatureView: View {
    let title: LocalizedStringKey
    let symbol: String
    let description: LocalizedStringKey

    var body: some View {
        Page {
            Panel {
                Label(title, systemImage: symbol).font(DesignTokens.TypeStyle.title)
                Text(description).foregroundStyle(DesignTokens.Color.textSecondary)
            }
        }
        .navigationTitle(title)
    }
}
