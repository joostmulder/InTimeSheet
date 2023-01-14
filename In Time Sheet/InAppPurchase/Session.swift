/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

public struct Session {
  public let id: SessionId
  public var paidSubscriptions: [PaidSubscription]
  
  public var currentSubscription: PaidSubscription? {
    let activeSubscriptions = paidSubscriptions.filter { $0.isActive && $0.purchaseDate >= TimeSheetService.shared.simulatedStartDate }
    let sortedByMostRecentPurchase = activeSubscriptions.sorted { $0.purchaseDate > $1.purchaseDate }
    
    return sortedByMostRecentPurchase.first
  }
  
  public var receiptData: Data
  public var parsedReceipt: [String: Any]
  
  init(receiptData: Data, parsedReceipt: [String: Any]) {
    id = UUID().uuidString
    self.receiptData = receiptData
    self.parsedReceipt = parsedReceipt
    
    if let receipt = parsedReceipt["receipt"] as? [String: Any], let purchases = receipt["in_app"] as? Array<[String: Any]> {
      var subscriptions = [PaidSubscription]()
      for purchase in purchases {
        if let paidSubscription = PaidSubscription(json: purchase) {
          subscriptions.append(paidSubscription)
        }
      }
      
      paidSubscriptions = subscriptions
    } else {
      paidSubscriptions = []
    }
  }
  
}

// MARK: - Equatable

extension Session: Equatable {
  public static func ==(lhs: Session, rhs: Session) -> Bool {
    return lhs.id == rhs.id
  }
}
