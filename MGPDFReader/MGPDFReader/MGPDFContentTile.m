//
//  MGPDFContentTile.m
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/8/24.
//  Copyright © 2017年 mige. All rights reserved.
//

#import "MGPDFContentTile.h"

#define LEVELS_OF_DETAIL 16

@implementation MGPDFContentTile


+ (CFTimeInterval)fadeDuration
{
    return CGFLOAT_MIN;
}

- (instancetype)init
{
    if ((self = [super init])) // Initialize superclass
    {
        self.levelsOfDetail = LEVELS_OF_DETAIL; // Zoom levels
        
        self.levelsOfDetailBias = (LEVELS_OF_DETAIL - 1); // Bias
        
        UIScreen *mainScreen = [UIScreen mainScreen]; // Main screen
        
        CGFloat screenScale = [mainScreen scale]; // Main screen scale
        
        CGRect screenBounds = [mainScreen bounds]; // Main screen bounds
        
        CGFloat w_pixels = (screenBounds.size.width * screenScale);
        
        CGFloat h_pixels = (screenBounds.size.height * screenScale);
        
        CGFloat max = ((w_pixels < h_pixels) ? h_pixels : w_pixels);
        
        CGFloat sizeOfTiles = ((max < 512.0f) ? 512.0f : 1024.0f);
        
        self.tileSize = CGSizeMake(sizeOfTiles, sizeOfTiles);
    }
    
    return self;
}


@end
