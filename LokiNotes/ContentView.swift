//
//  ContentView.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Some Note Here")
                .font(.title)
            HStack {
                Text("You're great");
                Spacer();
                Text("And very capable")
            }
                
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
