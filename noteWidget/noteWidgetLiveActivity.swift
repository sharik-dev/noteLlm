//
//  noteWidgetLiveActivity.swift
//  noteWidget
//
//  Created by Sharik Mohamed on 17/04/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct noteWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct noteWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: noteWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension noteWidgetAttributes {
    fileprivate static var preview: noteWidgetAttributes {
        noteWidgetAttributes(name: "World")
    }
}

extension noteWidgetAttributes.ContentState {
    fileprivate static var smiley: noteWidgetAttributes.ContentState {
        noteWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: noteWidgetAttributes.ContentState {
         noteWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: noteWidgetAttributes.preview) {
   noteWidgetLiveActivity()
} contentStates: {
    noteWidgetAttributes.ContentState.smiley
    noteWidgetAttributes.ContentState.starEyes
}
