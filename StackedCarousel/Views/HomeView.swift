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
    
    @GestureState var isDragging: Bool = false
    @State var offset: CGFloat = .zero
    
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
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(card.cardColor)
        )
        .padding(.trailing, -getPadding())
        .padding(.vertical, getPadding())
        .zIndex(Double(CGFloat(cards.count) - getIndex()))
        .rotationEffect(.init(degrees: getRotation(angle: 10)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .offset(x: offset)
        .gesture(
            DragGesture()
                .updating($isDragging, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    var translation = value.translation.width
                    translation = cards.first?.id == card.id ? translation : 0
                    translation = isDragging ? translation : 0
                    // MARK: Stopping right swipe
                    translation = (translation < 0 ? translation : 0)
                    offset = translation
                })
                .onEnded({ value in
                    // MARK: Check card offset relative to width
                    let width = UIScreen.main.bounds.width
                    let cardPassed = -offset > (width / 2)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if cardPassed {
                            offset = -width
                            removeAndInsertAtBack()
                        } else {
                            offset = .zero
                        }
                    }
                })
        )
    }
    // MARK: Removing front card and relocating to back for infinite stacked carousel
    func removeAndInsertAtBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var updatedCard = card
            updatedCard.id = UUID().uuidString
            
            cards.append(updatedCard)
            
            withAnimation {
                cards.removeFirst()
            }
        }
    }
    
    // MARK: Card rotation during drag
    func getRotation(angle: Double) -> Double {
        let width = UIScreen.main.bounds.width - 50
        let progress = offset / width
        
        return Double(progress) * angle
    }
    
    // MARK: Retrieve padding for each card
    func getPadding() -> CGFloat {
        let maxPadding = trailingCards * trailingSpacePerCard
        let cardPadding = getIndex() * trailingSpacePerCard
        
        return (getIndex() <= trailingCards ? cardPadding : maxPadding)
    }
    
    // MARK: Index for card to show
    func getIndex() -> CGFloat {
        let index = cards.firstIndex { card in
            return self.card.id == card.id
        } ?? 0
        
        return CGFloat(index)
    }
}
