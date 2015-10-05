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

public protocol SuccessResultProtocol: class {
  var statusCode: Int { get }
  var task: NSURLSessionDataTask? { get }
  var response: AnyObject? { get }
  
  init(task: NSURLSessionDataTask?, response: AnyObject?)
  func inspect() -> String
}

public protocol ErrorResultProtocol: class {
  var statusCode: Int { get }
  var task: NSURLSessionDataTask? { get }
  var response: AnyObject? { get }
  var error: NSError? { get }
  
  init(task: NSURLSessionDataTask?, response: AnyObject?, error: NSError?)
  func inspect() -> String
}

public extension SuccessResultProtocol {
  func inspect() -> String {
    return "statusCode: \(statusCode)\ntask: \(task)\nresponse: \(response)"
  }
}

public extension ErrorResultProtocol {
  func inspect() -> String {
    return "statusCode: \(statusCode)\ntask: \(task)\nresponse: \(response)\nerror: \(error)"
  }
}

public struct ABS {
  public class SuccessResult: SuccessResultProtocol {
    public let statusCode: Int
    public let task: NSURLSessionDataTask?
    public let response: AnyObject?
    
    public required init(task: NSURLSessionDataTask?, response: AnyObject?) {
      self.statusCode = (task?.response as? NSHTTPURLResponse)?.statusCode ?? -1
      self.task = task
      self.response = response
    }
  }
  
  public class ErrorResult: ErrorResultProtocol {
    public let statusCode: Int
    public let task: NSURLSessionDataTask?
    public let response: AnyObject?
    public let error: NSError?
    
    public required init(task: NSURLSessionDataTask?, response: AnyObject?, error: NSError?) {
      self.statusCode = (task?.response as? NSHTTPURLResponse)?.statusCode ?? -1
      self.task = task
      self.response = response
      self.error = error
    }
  }
  
  public final class Error {
    private struct Domain {
      static let Value = "net.heartofsword.AFNetworkingBoltsSupport"
    }
    
    private struct UserInfoKey {
      static let Result = "AFNetworking/BoltsSupport/Result"
    }
    
    public class func create<T: ErrorResultProtocol>(klass: T.Type, _ task: NSURLSessionDataTask?, _ error: NSError?) -> NSError {
      var response: AnyObject? = nil
      
      if let data = error?.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? NSData, body: AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
        response = body
      }
      
      let result = klass.init(task: task, response: response, error: error)
      let userInfo = [
        Error.UserInfoKey.Result: result,
      ]  as [NSObject : AnyObject]
      
      return NSError(domain: Domain.Value, code: result.statusCode, userInfo: userInfo)
    }
    
    public class func parse<T: ErrorResultProtocol>(klass: T.Type, _ error: NSError?) -> T? {
      guard let error = error else { return nil }
      
      if error.domain != Error.Domain.Value { return nil }
      return error.userInfo[Error.UserInfoKey.Result] as? T
    }
  }
}

// MARK: - Bolts Support

public extension AFHTTPSessionManager {
  // MARK: - GET
  
  public func abs_GET(path: String) -> BFTask {
    return abs_GET(ABS.SuccessResult.self, ABS.ErrorResult.self, path, nil)
  }
  
  public func abs_GET(path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    return abs_GET(ABS.SuccessResult.self, ABS.ErrorResult.self, path, parameters)
  }
  
  public func abs_GET<T: SuccessResultProtocol, U: ErrorResultProtocol>(successClass: T.Type, _ errorClass: U.Type, _ path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    GET(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(successClass.init(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(errorClass, task, error))
      }
    )
    
    return completionSource.task
  }
  
  // MARK: - HEAD
  
  public func abs_HEAD(path: String) -> BFTask {
    return abs_HEAD(ABS.SuccessResult.self, ABS.ErrorResult.self, path, nil)
  }
  
  public func abs_HEAD(path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    return abs_HEAD(ABS.SuccessResult.self, ABS.ErrorResult.self, path, parameters)
  }
  
  public func abs_HEAD<T: SuccessResultProtocol, U: ErrorResultProtocol>(successClass: T.Type, _ errorClass: U.Type, _ path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    HEAD(path, parameters: parameters,
      success: { (task) -> Void in
        completionSource.setResult(successClass.init(task: task, response: nil))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(errorClass, task, error))
      }
    )

    return completionSource.task
  }
  
  // MARK: - POST
  
  public func abs_POST(path: String) -> BFTask {
    return abs_POST(ABS.SuccessResult.self, ABS.ErrorResult.self, path, nil)
  }
  
  public func abs_POST(path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    return abs_POST(ABS.SuccessResult.self, ABS.ErrorResult.self, path, parameters)
  }
  
  public func abs_POST<T: SuccessResultProtocol, U: ErrorResultProtocol>(successClass: T.Type, _ errorClass: U.Type, _ path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()

    POST(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(successClass.init(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(errorClass, task, error))
      }
    )
    
    return completionSource.task
  }

  
  public func abs_POST(path: String, _ parameters: [String: AnyObject]?, _ constructingBodyBlock: (AFMultipartFormData?) -> Void) -> BFTask {
    return abs_POST(ABS.SuccessResult.self, ABS.ErrorResult.self, path, parameters, constructingBodyBlock)
  }
  
  public func abs_POST<T: SuccessResultProtocol, U: ErrorResultProtocol>(successClass: T.Type, _ errorClass: U.Type, _ path: String, _ parameters: [String: AnyObject]?, _ constructingBodyBlock: (AFMultipartFormData?) -> Void) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    POST(path, parameters: parameters, constructingBodyWithBlock: constructingBodyBlock,
      success: { (task, response) -> Void in
        completionSource.setResult(successClass.init(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(errorClass, task, error))
      }
    )
    
    return completionSource.task
  }
  
  // MARK: - PUT
  
  public func abs_PUT(path: String) -> BFTask {
    return abs_PUT(ABS.SuccessResult.self, ABS.ErrorResult.self, path, nil)
  }
  
  public func abs_PUT(path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    return abs_PUT(ABS.SuccessResult.self, ABS.ErrorResult.self, path, parameters)
  }
  
  public func abs_PUT<T: SuccessResultProtocol, U: ErrorResultProtocol>(successClass: T.Type, _ errorClass: U.Type, _ path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    PUT(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(successClass.init(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(errorClass, task, error))
      }
    )
    
    return completionSource.task
  }

  
  // MARK: - PATCH
  
  public func abs_PATCH(path: String) -> BFTask {
    return abs_PATCH(ABS.SuccessResult.self, ABS.ErrorResult.self, path, nil)
  }
  
  public func abs_PATCH(path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    return abs_PATCH(ABS.SuccessResult.self, ABS.ErrorResult.self, path, parameters)
  }
  
  public func abs_PATCH<T: SuccessResultProtocol, U: ErrorResultProtocol>(successClass: T.Type, _ errorClass: U.Type, _ path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    PATCH(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(successClass.init(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(errorClass, task, error))
      }
    )
    
    return completionSource.task
  }
  
  // MARK: - DELETE
  
  public func abs_DELETE(path: String) -> BFTask {
    return abs_DELETE(ABS.SuccessResult.self, ABS.ErrorResult.self, path, nil)
  }
  
  public func abs_DELETE(path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    return abs_DELETE(ABS.SuccessResult.self, ABS.ErrorResult.self, path, parameters)
  }
  
  public func abs_DELETE<T: SuccessResultProtocol, U: ErrorResultProtocol>(successClass: T.Type, _ errorClass: U.Type, _ path: String, _ parameters: [String: AnyObject]?) -> BFTask {
    let completionSource = BFTaskCompletionSource()
    
    DELETE(path, parameters: parameters,
      success: { (task, response) -> Void in
        completionSource.setResult(successClass.init(task: task, response: response))
      },
      failure: { (task, error) -> Void in
        completionSource.setError(ABS.Error.create(errorClass, task, error))
      }
    )
    
    return completionSource.task
  }
}