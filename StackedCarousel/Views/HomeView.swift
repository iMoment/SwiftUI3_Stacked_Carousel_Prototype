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
                let size = proxy.size
                let trailingCards: CGFloat = 2
                let trailingSpacePerCard: CGFloat = 20
                
                ZStack {
                    
                    ForEach(cards) { card in
                        InfiniteStackedCardView(cards: $cards, card: card, trailingCards: trailingCards, trailingSpacePerCard: trailingSpacePerCard)
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, (trailingCards * trailingSpacePerCard))
                .frame(height: size.height / 1.6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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

struct InfiniteStackedCardView: View {
    @Binding var cards: [Card]
    var card: Card
    var trailingCards: CGFloat
    var trailingSpacePerCard: CGFloat
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            Text(card.date)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(card.title)
                .font(.title.bold())
                .padding(.top)
            
            Spacer()
            
            Label {
                Image(systemName: "arrow.right")
            } icon: {
                Text("Read More")
            }
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .padding(.vertical, 10)
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(card.cardColor)
        )
    }
    
    
}
