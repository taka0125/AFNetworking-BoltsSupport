//
//  AFNetworking+BoltsSupport.swift
//  AFNetworking-BoltsSupport
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation
import AFNetworking
import Bolts

public struct ABS {
  public final class SuccessResult {
    public let statusCode: Int
    public let task: NSURLSessionDataTask?
    public let response: AnyObject?
    
    init(task: NSURLSessionDataTask?, response: AnyObject?) {
      self.statusCode = (task?.response as? NSHTTPURLResponse)?.statusCode ?? -1
      self.task = task
      self.response = response
    }
    
    public func inspect() -> String {
      return "statusCode: \(statusCode)\ntask: \(task)\nresponse: \(response)"
    }
  }
  
  public final class ErrorResult {
    public let statusCode: Int
    public let task: NSURLSessionDataTask?
    public let response: AnyObject?
    public let error: NSError?
    
    init(task: NSURLSessionDataTask?, response: AnyObject?, error: NSError?) {
      self.statusCode = (task?.response as? NSHTTPURLResponse)?.statusCode ?? -1
      self.task = task
      self.response = response
      self.error = error
    }
    
    public func inspect() -> String {
      return "statusCode: \(statusCode)\ntask: \(task)\nresponse: \(response)\nerror: \(error)"
    }
  }
  
  public final class Error {
    private struct Domain {
      static let Value = "net.heartofsword.AFNetworkingBoltsSupport"
    }
    
    private struct UserInfoKey {
      static let Result = "AFNetworking/BoltsSupport/Result"
    }
    
    public class func create(task: NSURLSessionDataTask?, error: NSError?) -> NSError {
      var response: AnyObject? = nil
            
      if let data = error?.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? NSData, body: AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
        response = body
      }
      
      let result = ABS.ErrorResult(task: task, response: response, error: error)
      return NSError(domain: Domain.Value, code: result.statusCode, userInfo: [Error.UserInfoKey.Result: result])
    }
    
    public class func parse(error: NSError?) -> ABS.ErrorResult? {
      guard let error = error else { return nil }
      
      if error.domain != Error.Domain.Value { return nil }
      return error.userInfo[Error.UserInfoKey.Result] as? ABS.ErrorResult
    }
  }
}

// MARK: - Bolts Support

public extension AFHTTPSessionManager {
  // MARK: - GET
  
  public func abs_GET(path: String) -> BFTask {
    return abs_GET(path, parameters: nil)
  }
  
  public func abs_GET(path: String, parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    GET(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(ABS.SuccessResult(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(task, error: error))
      }
    )
    
    return completionSource.task
  }
  
  // MARK: - HEAD
  
  public func abs_HEAD(path: String) -> BFTask {
    return abs_HEAD(path, parameters: nil)
  }
  
  public func abs_HEAD(path: String, parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    HEAD(path, parameters: parameters,
      success: { (task) -> Void in
        completionSource.setResult(ABS.SuccessResult(task: task, response: nil))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(task, error: error))
      }
    )
    
    return completionSource.task
  }
  
  // MARK: - POST
  
  public func abs_POST(path: String) -> BFTask {
    return abs_POST(path, parameters: nil)
  }
  
  public func abs_POST(path: String, parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    POST(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(ABS.SuccessResult(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(task, error: error))
      }
    )
    
    return completionSource.task
  }
  
  public func abs_POST(path: String, parameters: [String: AnyObject]?, constructingBodyBlock: (AFMultipartFormData?) -> Void) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    POST(path, parameters: parameters, constructingBodyWithBlock: constructingBodyBlock,
      success: { (task, response) -> Void in
        completionSource.setResult(ABS.SuccessResult(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(task, error: error))
      }
    )
    
    return completionSource.task
  }
  
  // MARK: - PUT
  
  public func abs_PUT(path: String) -> BFTask {
    return abs_PUT(path, parameters: nil)
  }
  
  public func abs_PUT(path: String, parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    PUT(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(ABS.SuccessResult(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(task, error: error))
      }
    )
    
    return completionSource.task
  }
  
  // MARK: - PATCH
  
  public func abs_PATCH(path: String) -> BFTask {
    return abs_PATCH(path, parameters: nil)
  }
  
  public func abs_PATCH(path: String, parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    PATCH(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(ABS.SuccessResult(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(task, error: error))
      }
    )
    
    return completionSource.task
  }
  
  // MARK: - DELETE
  
  public func abs_DELETE(path: String) -> BFTask {
    return abs_DELETE(path, parameters: nil)
  }
  
  public func abs_DELETE(path: String, parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    DELETE(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(ABS.SuccessResult(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(task, error: error))
      }
    )
    
    return completionSource.task
  }
}