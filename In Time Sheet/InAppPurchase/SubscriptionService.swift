
import Foundation
import StoreKit

class SubscriptionService: NSObject {
  
  static let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
  static let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
  static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
  static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
  
  
  static let shared = SubscriptionService()
  
  var hasReceiptData: Bool {
    return loadReceipt() != nil
  }
  
  var currentSessionId: String? {
    didSet {
      NotificationCenter.default.post(name: SubscriptionService.sessionIdSetNotification, object: currentSessionId)
    }
  }
  
  var currentSubscription: PaidSubscription?
  
  var options: [Subscription]? {
    didSet {
      NotificationCenter.default.post(name: SubscriptionService.optionsLoadedNotification, object: options)
    }
  }
  
  func loadSubscriptionOptions() {
    
    let productIDPrefix = Bundle.main.bundleIdentifier! + ".sub."
    
    //let allAccess = productIDPrefix + "allaccess"
    //let oneAWeek  = productIDPrefix + "oneaweek"
    
    let allAccessMonthly = productIDPrefix + "allaccess.monthly1"
    //let oneAWeekMonthly  = productIDPrefix + "oneaweek.monthly"
    
    let productIDs = Set([allAccessMonthly])
    
    let request = SKProductsRequest(productIdentifiers: productIDs)
    request.delegate = self
    request.start()
  }
  
  func purchase(subscription: Subscription) {
    let payment = SKPayment(product: subscription.product)
    SKPaymentQueue.default().add(payment)
  }
  
  func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
    if let receiptData = loadReceipt() {
      TimeSheetService.shared.upload(receipt: receiptData) { [weak self] (result) in
        guard let strongSelf = self else { return }
        switch result {
        case .success(let result):
          strongSelf.currentSessionId = result.sessionId
          strongSelf.currentSubscription = result.currentSubscription
          completion?(true)
        case .failure(let error):
          print("🚫 Receipt Upload Failed: \(error)")
          completion?(false)
        }
      }
    }
  }
  
  private func loadReceipt() -> Data? {
    guard let url = Bundle.main.appStoreReceiptURL else {
      return nil
    }
    
    do {
      let data = try Data(contentsOf: url)
      return data
    } catch {
      print("Error loading receipt data: \(error.localizedDescription)")
      return nil
    }
  }
}

// MARK: - SKProductsRequestDelegate

extension SubscriptionService: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    options = response.products.map { Subscription(product: $0) }
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    if request is SKProductsRequest {
      print("Subscription Options Failed Loading: \(error.localizedDescription)")
    }
  }
}
