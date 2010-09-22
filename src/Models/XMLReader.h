//
//  XMLReader.h
//  Ile sans fil
//
//  Created by Oli on 24/05/09.
//  Copyright 2009 Kolt Production.License Apache2.
//

#import <Foundation/Foundation.h>

@class Hotspot;

// Delegate
@protocol XMLReaderDelegate <NSObject> 
- (void)XMLReaderDidFinishParsing;
- (void)XMLReaderDidFailParsing;
@end

@interface XMLReader : NSObject {
	id<XMLReaderDelegate> delegate;

@private 
	NSMutableData			*receivedData;
	NSMutableDictionary	*contentOfCurrentHotspot;
	NSMutableDictionary	*contentOfCurrentNode;
	NSMutableArray			*nodesForCurrentHotspot;
	NSMutableString		*contentOfCurrentLocationProperty;
	
	NSMutableArray			*hotspotsList;
}

@property (nonatomic, retain) id delegate;

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;
- (void)startParsing;

@end
