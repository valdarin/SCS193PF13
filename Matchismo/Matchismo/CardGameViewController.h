//
//  CardGameViewController.h
//  Matchismo
//
//  Created by Scott Moen on 6/10/14.
//  Copyright (c) 2014 Scott Moen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardMatchingGame.h"
#import "Grid.h"

@interface CardGameViewController : UIViewController

@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) Deck *deck;

@property (nonatomic) NSUInteger cardsToMatch;
@property (nonatomic) NSUInteger cardsToDeal;
@property (nonatomic) BOOL removeMatched;

@property (strong, nonatomic) Grid *grid;

-(UIView*)cardViewWithCard:(Card*)card;
-(BOOL)doesView:(UIView*)view representCard:(Card*)card;
-(void)updateView:(UIView*)view withCard:(Card*)card;

@end
