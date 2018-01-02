//
//  MockURLSession.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

// This class is a Swift 3 rewrite of https://github.com/announce/MockURLSession/blob/master/MockURLSession/MockURLSession.swift

/**
 
 MIT License
 
 Copyright (c) 2016
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

public class MockURLSession: URLSession {
    private static let sharedInstance = MockURLSession()
    
    public typealias CompletionBlock = (Data?, URLResponse?, Error?) -> Void
    typealias Response = (data: Data?, response: URLResponse?, error: Error?)
    
    private var responses: [URL: Response] = [:]
    
    public override class var shared: URLSession {
        get {
            return MockURLSession.sharedInstance
        }
    }
    
    public override func dataTask(with url: URL, completionHandler: @escaping CompletionBlock) -> URLSessionDataTask {
        
        let response = responses[url] ?? (data: nil, response: nil, error: NSError(domain: "MockURLSession", code: 1, userInfo: [NSLocalizedDescriptionKey : "No response registered for (\(url.absoluteString))"]))
        
        return MockURLSessionDataTask(responseParameters: response, completionBlock: completionHandler)
    }
    
    public override func dataTask(with urlRequest: URLRequest, completionHandler: @escaping CompletionBlock) -> URLSessionDataTask {
        
        if let url = urlRequest.url {
            let response = responses[url] ?? (data: nil, response: nil, error: NSError(domain: "MockURLSession", code: 1, userInfo: [NSLocalizedDescriptionKey : "No response registered for (\(url.absoluteString))"]))
            
            return MockURLSessionDataTask(responseParameters: response, completionBlock: completionHandler)
        } else {
            let response: Response = (data: nil, response: nil, error: NSError(domain: "MockURLSession", code: 1, userInfo: [NSLocalizedDescriptionKey : "No response registered for \(urlRequest)"]))
            return MockURLSessionDataTask(responseParameters: response, completionBlock: completionHandler)
        }
    }
    
    public func registerMockResponse(url: URL, data: Data?, statusCode: Int = 200, headerFields: [String: String]? = nil, error: Error? = nil) {
        
        responses[url] = (data: data, response: HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields), error: error)
    }
    
    class MockURLSessionDataTask: URLSessionDataTask {
        let responseParameters: Response
        let completionBlock: CompletionBlock
        
        init(responseParameters: Response, completionBlock: @escaping CompletionBlock) {
            self.responseParameters = responseParameters
            self.completionBlock = completionBlock
        }
        
        override func resume() {
            print("Mock \(responseParameters.response?.url?.absoluteString ?? "")")
            completionBlock(responseParameters.data, responseParameters.response, responseParameters.error)
        }
    }
}
