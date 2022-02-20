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
    
    // MARK: Detail Hero Page
    @State var showDetailPage: Bool = false
    @State var currentCard: Card?
    
    @Namespace var animation
    @State var showDetailContent: Bool = false
    
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
                        InfiniteStackedCardView(
                            cards: $cards,
                            card: card,
                            trailingCards: trailingCards,
                            trailingSpacePerCard: trailingSpacePerCard,
                            animation: animation,
                            showDetailPage: $showDetailPage)
                        // MARK: Showing Detail Page on Tap
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    currentCard = card
                                    showDetailPage = true
                                }
                            }
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
        .overlay(
             DetailViewPage()
        )
    }
    // MARK: Detail View Page
    @ViewBuilder
    func DetailViewPage() -> some View {
        ZStack {
            if let currentCard = currentCard, showDetailPage {
                Rectangle()
                    .fill(currentCard.cardColor)
                    .matchedGeometryEffect(id: currentCard.id, in: animation)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    Button {
                        withAnimation {
                            showDetailContent = false
                            showDetailPage = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.black)
                            .padding(10)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(currentCard.date)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    Text(currentCard.title)
                        .font(.title.bold())
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(content)
                            .padding(.top)
                    }
                }
                .opacity(showDetailContent ? 1 : 0)
                .foregroundColor(Color.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation {
                            showDetailContent = true
                        }
                    }
                }
            }
        }
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
    
    // MARK: For Hero Animation
    var animation: Namespace.ID
    @Binding var showDetailPage: Bool
    
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
            ZStack {
                // Matched Geometry effect doesn't animate smoothly when hiding original content
                RoundedRectangle(cornerRadius: 25)
                    .fill(card.cardColor)
                    .matchedGeometryEffect(id: card.id, in: animation)
            }
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

let content = "Velit dignissim sodales ut eu. Et odio pellentesque diam volutpat commodo sed egestas. Justo donec enim diam vulputate ut. Tellus pellentesque eu tincidunt tortor aliquam nulla facilisi cras. Quam adipiscing vitae proin sagittis. Habitasse platea dictumst quisque sagittis purus sit amet. Eget egestas purus viverra accumsan in nisl nisi scelerisque eu. Suscipit adipiscing bibendum est ultricies. Ut diam quam nulla porttitor massa. Morbi enim nunc faucibus a. At urna condimentum mattis pellentesque id. Nibh mauris cursus mattis molestie a iaculis at. Eu turpis egestas pretium aenean. Maecenas volutpat blandit aliquam etiam. Scelerisque purus semper eget duis at tellus. Cras fermentum odio eu feugiat pretium nibh. Urna id volutpat lacus laoreet non. Aliquet porttitor lacus luctus accumsan. Interdum consectetur libero id faucibus nisl tincidunt eget. Phasellus faucibus scelerisque eleifend donec pretium."
