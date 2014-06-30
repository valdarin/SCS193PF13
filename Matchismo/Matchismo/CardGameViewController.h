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

@property (nonatomic) NSUInteger cardCount;
@property (nonatomic) NSUInteger cardsToMatch;

@property (strong, nonatomic) Grid *grid;

-(UIView*)viewWithCard:(Card*)card inFrame:(CGRect)frame;

@end
