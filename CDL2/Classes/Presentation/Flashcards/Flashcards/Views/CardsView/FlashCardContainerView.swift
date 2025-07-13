//
//  FlashCardContainerView.swift
//  CDL
//
//  Created by Vitaliy Zagorodnov on 12.06.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class FlashCardContainerView: UIView {
    private lazy var didSelectAnswer = PublishRelay<(id: Int, answer: Bool)>()
    private lazy var emptyCardsRelay = PublishRelay<Void>()
    private lazy var didMovedCardTrigger = PublishRelay<Void>()
    
    private lazy var inset = UIEdgeInsets.zero
    
    private lazy var bufferSize: Int = 2 {
        didSet {
            bufferSize = bufferSize > 3 ? 3 : bufferSize
        }
    }
    
    private var index = 0
    private var separator: CGFloat = 13.scale
    
    private var allCards: [FlashCardModel] = []
    private var loaded: [FlashCardView] = []
}

// MARK: Public
extension FlashCardContainerView {
    func showCards(for elements: [FlashCardModel]) {
        guard !elements.isEmpty else { return }
        
        allCards.append(contentsOf: elements)
        
        elements.enumerated().forEach { index, element in
            if loaded.count < bufferSize {
                let cardView = createCard(for: element, index: index)
                if loaded.isEmpty {
                    addSubview(cardView)
                } else {
                    insertSubview(cardView, belowSubview: loaded.last!)
                }
                
                loaded.append(cardView)
            }
        }
        loaded.first?.moveToThis()
        
        swipeAnimation()
    }
    
    var selectedAnswer: Signal<(id: Int, answer: Bool)> {
        didSelectAnswer.asSignal()
    }
    
    var finish: Signal<Void> {
        emptyCardsRelay.asSignal()
    }
    
    var didMovedCard: Signal<Void> {
        didMovedCardTrigger.asSignal()
    }
}

// MARK: FlashCardDelegate
extension FlashCardContainerView: FlashCardDelegate {
    func moving(index: Int, distance: CGFloat) {
        if let nextIndex = loaded.firstIndex(where: { $0.index == index }), loaded.count >= nextIndex + 2 {
            let nextCard = loaded[nextIndex + 1]
            let animateDistance = (frame.height - nextCard.center.y) / 2
            let minScale = max(1 - CGFloat(nextIndex + 1) / 10, 0)
            let minAlpha: CGFloat = 0.5
            
            let alpha = max(abs((1 - minAlpha) / animateDistance * distance) + minAlpha, minAlpha)
            let scale = min(max(abs((1 - minScale) / animateDistance * distance) + minScale, minScale), 1)
            
            nextCard.alpha = alpha
            nextCard.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func moved() {
        removeAndAddNewCard()
        
        didMovedCardTrigger.accept(Void())
    }
    
    func cardReturned() {
        swipeAnimation()
    }
    
    func tapAction(id: Int, isKnew: Bool) {
        didSelectAnswer.accept((id, isKnew))
    }
}

// MARK: Private
private extension FlashCardContainerView {
    func createCard(for element: FlashCardModel, index: Int) -> FlashCardView {
        let origin = CGPoint(x: inset.left, y: inset.top)
        let size = CGSize(width: bounds.width - inset.left - inset.right, height: bounds.height - inset.top - inset.bottom)
        
        let card = FlashCardView(frame: CGRect(origin: origin, size: size))
        card.index = index
        card.delegate = self
        card.setup(element: element)
        return card
    }
    
    func removeAndAddNewCard() {
        index += 1
        loaded.remove(at: 0)
        
        if (index + loaded.count) < allCards.count {
            let card = createCard(for: allCards[index + loaded.count], index: index + loaded.count)
            insertSubview(card, belowSubview: loaded.last!)
            loaded.append(card)
        } else if loaded.isEmpty {
            emptyCardsRelay.accept(())
        }
        
        loaded.first?.moveToThis()
        
        swipeAnimation()
    }
    
    func swipeAnimation() {
        guard !loaded.isEmpty else { return }
        
        loaded.enumerated().forEach { index, card in
            card.isUserInteractionEnabled = index == 0 ? true : false
            
            let scale = max(1 - CGFloat(index) / 10, 0)
            let alpha: CGFloat = index == 0 ? 1 : 0.5
            let translationX = card.frame.height * max((1 - scale), 0) / 2 + self.separator * CGFloat(index)
            let translation = CGAffineTransform(translationX: 0, y: translationX)
            card.transform = translation.concatenating(CGAffineTransform(scaleX: scale, y: scale))
            card.alpha = alpha
        }
    }
}
