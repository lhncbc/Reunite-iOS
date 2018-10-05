/*
 SoapRequest.m
 Implementation of the request object used to manage asynchronous requests.
 Author:	Jason Kichline, andCulture - Harrisburg, Pennsylvania USA
 */

#import "SoapRequest.h"
#import "SoapArray.h"
#import "SoapFault.h"
#import "Soap.h"
#import <objc/message.h>
#import "PersonObject.h"
#import "WSCommon.h"
#import "ReportController.h"
#import "AppDelegate.h"

NSString* const SoapRequestDidStartNotification = @"SoapRequestDidStartNotification";
NSString* const SoapRequestDidUpdateProgressNotification = @"SoapRequestDidUpdateProgressNotification";
NSString* const SoapRequestDidFinishNotification = @"SoapRequestDidFinishNotification";
NSString* const SoapRequestDidFailNotification = @"SoapRequestDidFailNotification";
NSString* const SoapRequestProgressKey = @"progress";

@implementation SoapRequest

@synthesize handler, url, soapAction, postData, receivedData, username, password, deserializeTo, action, logging, defaultHandler,HelpreceivedData;

// Creates a request to submit from discrete values.
+ (SoapRequest*) create: (SoapHandler*) handler urlString: (NSString*) urlString soapAction: (NSString*) soapAction postData: (NSString*) postData deserializeTo: (id) deserializeTo {
	return [SoapRequest create: handler action: nil urlString: urlString soapAction: soapAction postData: postData deserializeTo: deserializeTo];
}

+ (SoapRequest*) create: (SoapHandler*) handler action: (SEL) action urlString: (NSString*) urlString soapAction: (NSString*) soapAction postData: (NSString*) postData deserializeTo: (id) deserializeTo {
	SoapRequest* request = [[SoapRequest alloc] init];
	request.url = [NSURL URLWithString: urlString];
	//request.soapAction = soapAction;
    
    request.postData=postData;
   
   // NSLog(@"Your JSON String is %@", jsonString);

    
	request.handler = handler;
	request.deserializeTo = deserializeTo;
	request.action = action;
	request.defaultHandler = nil;
	return request;
}

+ (SoapRequest*) create: (SoapHandler*) handler action: (SEL) action service: (SoapService*) service soapAction: (NSString*) soapAction postData: (NSString*) postData deserializeTo: (id) deserializeTo {
	SoapRequest* request = [SoapRequest create: handler action: action urlString: service.serviceUrl soapAction: soapAction postData:postData deserializeTo:deserializeTo];
	request.defaultHandler = service.defaultHandler;
	request.logging = service.logging;
	request.username = service.username;
	request.password = service.password;
	return request;
}

// Sends the request via HTTP.
- (void) send {
	
 
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // If we don't have a handler, create a default one
        if(handler == nil) {
            handler = [[SoapHandler alloc] init];
        }
        
      
    

        /*
        // Make sure the network is available
        //if([SoapReachability connectedToNetwork] == NO) {
        if (NO){//![CommonFunctions canConnectTo:@"https://www.google.com"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError* error = [NSError errorWithDomain:@"SudzC" code:400 userInfo:[NSDictionary dictionaryWithObject:@"The network is not available" forKey:NSLocalizedDescriptionKey]];
                [self handleError: error];
            });
            return;
        }
        
        // Make sure we can reach the host
        //if([SoapReachability hostAvailable:url.host] == NO) {
        if (![CommonFunctions canConnectTo:url.description]) {
            dispatch_async(dispatch_get_main_queue(), ^{
            NSError* error = [NSError errorWithDomain:@"SudzC" code:410 userInfo:[NSDictionary dictionaryWithObject:@"The host is not available" forKey:NSLocalizedDescriptionKey]];
                [self handleError: error];
            });
            return;
        }*/
        
        // Output the URL if logging is enabled
        if(logging) {
            DLog(@"Loading: %@", url.absoluteString);
        }
        
        // Create the request
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: url];
//        if(soapAction != nil) {
//            [request addValue: soapAction forHTTPHeaderField: @"SOAPAction"];
//        }
        if(postData != nil) {
            [request setHTTPMethod: @"POST"];
           // [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
            [request addValue: @"application/json; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
            [request setHTTPBody: [postData dataUsingEncoding: NSUTF8StringEncoding]];
            [request setTimeoutInterval:30];
            if(self.logging) {
                DLog(@"%@postDatapostDatapostDatapostData", postData);
            }
        }
        
        // Create the connection
        dispatch_async(dispatch_get_main_queue(), ^{
            conn = [[NSURLConnection alloc] initWithRequest: request delegate: self];
            if(conn) {
                receivedData = [NSMutableData data];
            } else {
                // We will want to call the onerror method selector here...
                if(self.handler != nil) {
                    NSError* error = [NSError errorWithDomain:@"SoapRequest" code:404 userInfo: [NSDictionary dictionaryWithObjectsAndKeys: @"Could not create connection", NSLocalizedDescriptionKey,nil]];
                    [self handleError: error];
                }
            }
        });
    });
}

-(void)handleError:(NSError*)error{
	SEL onerror = @selector(onerror:);
	if(self.action != nil) { onerror = self.action; }
	if([self.handler respondsToSelector: onerror]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.handler performSelector:onerror withObject:error];
#pragma clang diagnostic pop	
    } else {
		if(self.defaultHandler != nil && [self.defaultHandler respondsToSelector:onerror]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.defaultHandler performSelector:onerror withObject:error];
#pragma clang diagnostic pop			
        }
	}
	if(self.logging) {
		DLog(@"Error: %@", error.localizedDescription);
	}
}

-(void)handleFault:(SoapFault*)fault{
	if([self.handler respondsToSelector:@selector(onfault:)]) {
		[self.handler onfault: fault];
	} else if(self.defaultHandler != nil && [self.defaultHandler respondsToSelector:@selector(onfault:)]) {
		[self.defaultHandler onfault:fault];
	}
	if(self.logging) {
		DLog(@"Fault: %@", fault);
	}
}

// Called when the HTTP socket gets a response.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
	if([response isKindOfClass:[NSHTTPURLResponse class]]) {
		expectedContentLength = [(NSHTTPURLResponse*)response expectedContentLength];
	} else {
		expectedContentLength = 0;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:SoapRequestDidStartNotification object:self userInfo:nil];
	if(expectedContentLength > 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:SoapRequestDidUpdateProgressNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0], SoapRequestProgressKey, nil]];
	}
}

// Called when the HTTP socket received data.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)value {
    [self.receivedData appendData:value];
	if(expectedContentLength > 0) {
		float progress = ((float)expectedContentLength / (float)self.receivedData.length);
		[[NSNotificationCenter defaultCenter] postNotificationName:SoapRequestDidUpdateProgressNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:progress], SoapRequestProgressKey, nil]];
	}
}

// Called when the HTTP request fails.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	conn = nil;
	[self handleError:error];
	[[NSNotificationCenter defaultCenter] postNotificationName:SoapRequestDidFailNotification object:self];
}

// Called when the connection has finished loading.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	// Send notifications that we are done
	[[NSNotificationCenter defaultCenter] postNotificationName:SoapRequestDidUpdateProgressNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1], SoapRequestProgressKey, nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:SoapRequestDidFinishNotification object:self userInfo:nil];
	
	NSError* error;
	if(self.logging == YES) {
		DLog(@"%@", [[NSString alloc] initWithData: self.receivedData encoding: NSUTF8StringEncoding]);
	}
    [[NSUserDefaults standardUserDefaults] setObject:self.receivedData forKey:@"receivedData"];
    
   // WSCommon *common=[[WSCommon alloc]init];
    //[common setWasreceivedData:self.receivedData];
   // common.wasreceivedData=self.receivedData;
    //[common addDownloadRequest:self.receivedData];
    //receivedData=self.receivedData;
   // common.wasreceivedData=self.receivedData;
    
    //NSLog(@"%@ receivedDataNSUserDefaultsNSUserDefaults", common.wasreceivedData);

   // WSCommon *common=[WSCommon  stringWithData:self.receivedData];
    //DLog(@"SOAP Fault: %@", common);
	CXMLDocument* doc = [[CXMLDocument alloc] initWithData: self.receivedData options: 0 error: &error];
	if(doc == nil) {
		[self handleError:error];
		return;
	}
    
	id output = nil;
	SoapFault* fault = [SoapFault faultWithXMLDocument: doc];
	
	if([fault hasFault]) {
		if(self.action == nil) {
			[self handleFault: fault];
		} else {
			if(self.handler != nil && [self.handler respondsToSelector: self.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.handler performSelector:self.action withObject:fault];
#pragma clang diagnostic pop			
            } else {
				DLog(@"SOAP Fault: %@", fault);
			}
		}
	} else {
		CXMLNode* element = [[Soap getNode: [doc rootElement] withName: @"Body"] childAtIndex:0];
		if(deserializeTo == nil) {
			output = [Soap deserialize:element];
		} else {
			if([deserializeTo respondsToSelector: @selector(initWithNode:)]) {
				//element = [element childAtIndex:0];
				output = [deserializeTo initWithNode: element];
			} else {
				NSString* value = [[[element childAtIndex:0] childAtIndex:0] stringValue];
				output = [Soap convert: value toType: deserializeTo];
			}
		}
		
		if(self.action == nil) { self.action = @selector(onload:); }
		if(self.handler != nil && [self.handler respondsToSelector: self.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.handler performSelector:self.action withObject:output];
#pragma clang diagnostic pop
		} else if(self.defaultHandler != nil && [self.defaultHandler respondsToSelector:@selector(onload:)]) {
			[self.defaultHandler onload:output];
		}
	}
	conn = nil;
}

// Called if the HTTP request receives an authentication challenge.
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if([challenge previousFailureCount] == 0) {
		NSURLCredential *newCredential;
        newCredential=[NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
		NSError* error = [NSError errorWithDomain:@"SoapRequest" code:403 userInfo: [NSDictionary dictionaryWithObjectsAndKeys: @"Could not authenticate this request", NSLocalizedDescriptionKey,nil]];
		[self handleError:error];
    }
}

// Cancels the HTTP request.
- (BOOL) cancel {
	if(conn == nil) { return NO; }
	[conn cancel];
	conn = nil;
	return YES;
}

@end
