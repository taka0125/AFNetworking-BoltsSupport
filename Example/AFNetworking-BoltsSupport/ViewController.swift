//
//  ViewController.swift
//  AFNetworking-BoltsSupport
//
//  Created by Takahiro Ooishi on 09/27/2015.
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//

import UIKit
import AFNetworking
import Bolts
import AFNetworking_BoltsSupport

extension ABS.Error {
  static func parse(error: NSError?) -> ABS.ErrorResult? {
    return parse(ABS.ErrorResult.self, error)
  }
}

class ViewController: UIViewController {
  private lazy var manager: AFHTTPSessionManager = {
    let manager = AFHTTPSessionManager()
    manager.responseSerializer = AFJSONResponseSerializer()
    return manager
  }()
  
  @IBAction func successSample() {
    manager.abs_GET("https://private-7306c5-bfsample.apiary-proxy.com/items").continueWithBlock { (task) -> AnyObject! in
      if let result = task.result as? ABS.SuccessResult {
        print("statusCode = \(result.statusCode)")
        print("task = \(result.task)")
        print("response = \(result.response)")
      }
      return task
    }
  }
  
  @IBAction func errorSample() {
    manager.abs_GET("https://private-7306c5-bfsample.apiary-proxy.com/error_items").continueWithBlock { (task) -> AnyObject! in
      if let error = ABS.Error.parse(task.error) {
        print("statusCode = \(error.statusCode)")
        print("task = \(error.task)")
        print("response = \(error.response)")
        print("error = \(error.error)")
      }
      return task
    }
  }
}
