//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by scott.moen on 6/13/14.
//  Copyright (c) 2014 Scott Moen. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame()
@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic) NSUInteger cardCount;
@property (nonatomic, strong) NSMutableArray *cards; // of Card
@property (nonatomic, strong) Deck* deck;
@end

@implementation CardMatchingGame

-(NSMutableArray*)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

-(NSMutableArray*)statusHistory
{
    if (!_statusHistory) _statusHistory = [[NSMutableArray alloc] init];
    return _statusHistory;
}

-(instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
{
    self = [super init];
    
    self.deck = deck;
    
    if (self) {
        self.removeMatched = NO;
        self.cardCount = count;
        [self drawCardsToCount];
    }
    
    return self;
}

-(void)drawCardsToCount
{
    while ([self.cards count] < self.cardCount) {
        Card *card = [self.deck drawRandomCard];
        if (card) {
            [self.cards addObject:card];
        }
        else {
            NSLog(@"XXX OUT OF CARDS");
            break;
        }
    }
}

-(Card*)cardAtIndex:(NSUInteger)index
{
    return index<[self.cards count] ? self.cards[index] : nil;
}

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

-(void)choseCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    NSMutableDictionary* history = [[NSMutableDictionary alloc] init];
    int scoreChange = 0;
    
    if (!card.isMatched) {
        if (card.isChosen) {
            card.chosen = NO;
        }
        else {
            [history setObject:[NSMutableArray arrayWithObject:card] forKey:@"cards"];
            NSMutableArray *chosenCards = [[NSMutableArray alloc] init];
            for (Card *otherCard in self.cards) {
                if (otherCard.isChosen && !otherCard.isMatched) {
                    [chosenCards addObject:otherCard];
                    [history[@"cards"] addObject:otherCard];
                    if ([chosenCards count] == self.cardsToMatch) {
                        int matchScore = [card match:chosenCards];
                        if (matchScore) {
                            scoreChange += matchScore * MATCH_BONUS;
                            if (self.removeMatched) {
                                [self.cards removeObject:card];
                                for (Card *otherCard in chosenCards) {
                                    [self.cards removeObject:otherCard];
                                }
                                [self drawCardsToCount];
                            }
                            else {
                                card.matched = YES;
                                for (Card *otherCard in chosenCards) {
                                    otherCard.matched = YES;
                                }
                            }
                        }
                        else {
                            scoreChange -= MISMATCH_PENALTY;
                            for (Card *otherCard in chosenCards) {
                                otherCard.chosen = NO;
                            }
                        }
                        break;
                    }
                }
            }
            scoreChange -= COST_TO_CHOOSE;
            card.chosen = YES;
        }
    }
    self.score += scoreChange;
    [history setObject:[NSNumber numberWithInt:scoreChange] forKey:@"score"];
    [self.statusHistory addObject:history];
}

-(void)drawMoreCards:(NSUInteger)count
{
    self.cardCount += count;
    [self drawCardsToCount];
}

-(NSUInteger)cardsInPlay
{
    return [self.cards count];
}

@end
