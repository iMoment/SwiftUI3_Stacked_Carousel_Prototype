//
//  HomeView.swift
//  StackedCarousel
//
//  Created by Stanley Pan on 2022/02/20.
//

import SwiftUI

struct HomeView: View {
    @State var cards: [Card] = [
        Card(cardColor: Color("customBlue"), date: "Sunday 20th February", title: "Neurobics for your \nmind."),
        Card(cardColor: Color("customPurple"), date: "Monday 21st February", title: "Brush up on hygiene."),
        Card(cardColor: Color("customGreen"), date: "Tuesday 22nd February", title: "Don't skip breakfast."),
        Card(cardColor: Color("customPink"), date: "Wednesday 23rd February", title: "Eat an apple a day."),
        Card(cardColor: Color("customYellow"), date: "Thursday 24th February", title: "Light walking for 20 minutes."),
    ]
    
    var body: some View {
        
        VStack {
            // MARK: Title UI
            HStack(alignment: .bottom) {
                
                VStack(alignment: .leading) {
                    
                    Text("20th of FEB")
                        .font(.largeTitle.bold())
                    
                    Label {
                        Text("Seattle, USA")
                    } icon: {
                        Image(systemName: "location.circle")
                    }
                }
                
                Spacer()
                
                Text("Updated 2:32 PM")
                    .font(.caption2)
                    .fontWeight(.light)
            }
            
            GeometryReader { proxy in
                
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
