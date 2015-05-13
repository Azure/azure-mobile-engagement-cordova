// ================================================================================================
//  AE_TBXML.h
//  Fast processing of XML files
//
// ================================================================================================
//  Created by Tom Bradley on 21/10/2009.
//  Version 1.4
//  
//  Copyright (c) 2009 Tom Bradley
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// ================================================================================================

#import <Foundation/Foundation.h>

// ================================================================================================
//  Defines
// ================================================================================================
#define MAX_ELEMENTS 100
#define MAX_ATTRIBUTES 100

#define AE_TBXML_ATTRIBUTE_NAME_START 0
#define AE_TBXML_ATTRIBUTE_NAME_END 1
#define AE_TBXML_ATTRIBUTE_VALUE_START 2
#define AE_TBXML_ATTRIBUTE_VALUE_END 3
#define AE_TBXML_ATTRIBUTE_CDATA_END 4

// ================================================================================================
//  Structures
// ================================================================================================
typedef struct _AE_TBXMLAttribute {
    char * name;
    char * value;
    struct _AE_TBXMLAttribute * next;
} AE_TBXMLAttribute;

typedef struct _AE_TBXMLElt {
    char * name;
    char * text;
    
    AE_TBXMLAttribute * firstAttribute;
    
    struct _AE_TBXMLElt * parentElement;
    
    struct _AE_TBXMLElt * firstChild;
    struct _AE_TBXMLElt * currentChild;
    
    struct _AE_TBXMLElt * nextSibling;
    struct _AE_TBXMLElt * previousSibling;
    
} AE_TBXMLElt;

typedef struct _AE_TBXMLEltBuffer {
    AE_TBXMLElt * elements;
    struct _AE_TBXMLEltBuffer * next;
    struct _AE_TBXMLEltBuffer * previous;
} AE_TBXMLEltBuffer;

typedef struct _AE_TBXMLAttributeBuffer {
    AE_TBXMLAttribute * attributes;
    struct _AE_TBXMLAttributeBuffer * next;
    struct _AE_TBXMLAttributeBuffer * previous;
} AE_TBXMLAttributeBuffer;

// ================================================================================================
//  AE_TBXML Public Interface
// ================================================================================================
@interface AE_TBXML : NSObject {
    
@private
    AE_TBXMLElt * rootXMLElement;
    
    AE_TBXMLEltBuffer * currentElementBuffer;
    AE_TBXMLAttributeBuffer * currentAttributeBuffer;
    
    long currentElement;
    long currentAttribute;
    
    char * bytes;
    long bytesLength;
}

@property (nonatomic, readonly) AE_TBXMLElt * rootXMLElement;

+ (id)tbxmlWithURL:(NSURL*)aURL;
+ (id)tbxmlWithXMLString:(NSString*)aXMLString;
+ (id)tbxmlWithXMLData:(NSData*)aData;

- (id)initWithURL:(NSURL*)aURL;
- (id)initWithXMLString:(NSString*)aXMLString;
- (id)initWithXMLData:(NSData*)aData;

@end

// ================================================================================================
//  AE_TBXML Static Functions Interface
// ================================================================================================

@interface AE_TBXML (StaticFunctions)

+ (NSString*) elementName:(AE_TBXMLElt*)aXMLElement;
+ (NSString*) textForElement:(AE_TBXMLElt*)aXMLElement;
+ (NSString*) valueOfAttributeNamed:(NSString *)aName forElement:(AE_TBXMLElt*)aXMLElement;

+ (NSString*) attributeName:(AE_TBXMLAttribute*)aXMLAttribute;
+ (NSString*) attributeValue:(AE_TBXMLAttribute*)aXMLAttribute;

+ (AE_TBXMLElt*) nextSiblingNamed:(NSString*)aName searchFromElement:(AE_TBXMLElt*)aXMLElement;
+ (AE_TBXMLElt*) childElementNamed:(NSString*)aName parentElement:(AE_TBXMLElt*)aParentXMLElement;

+ (NSString*) unescapeXML:(NSString*)source;

@end
