import SwiftUI

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
    
    @ViewBuilder
    func makeAccentable() -> some View  {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.widgetAccentable(true)
        } else {
            return self
        }
    }
}

