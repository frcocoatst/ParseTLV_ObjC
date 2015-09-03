//
//  TLVParser.h
//  TLVParser_ObjC
//
//  Created by Fritz on 03.09.15.
//  Copyleft (c) 2015 Fritz
//

#import <Foundation/Foundation.h>


@interface TLVParser : NSObject

#define ERROR_LENGTH_TOO_MANY_BYTES -1

@property NSMutableString *text;


- (int) parseTLVStream:(NSData *)data withLevel:(int)level;
- (NSString *) displayTLVStream;

- (int) calcDataLength:(NSData *)aBuf;
- (int) calcLengthBytesCount:(NSData *)aBuf;
- (BOOL)isConstructed:(NSData *) aBuf;
- (int )calcTagBytesCount:(NSData *)aBuf;

@end
