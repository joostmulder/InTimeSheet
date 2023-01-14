

private let itcAccountSecret = "81550cb79c4c40b9a66570ce4cbd82d0"

import Foundation
import UIKit

public enum Result<T> {
  case failure(TimeSheetServiceError)
  case success(T)
}

public typealias LoadTimeSheetCompletion = (_ TimeSheets: Result<[TimeSheetSet]>) -> Void
public typealias UploadReceiptCompletion = (_ result: Result<(sessionId: String, currentSubscription: PaidSubscription?)>) -> Void

public typealias SessionId = String

public enum TimeSheetServiceError: Error {
  case missingAccountSecret
  case invalidSession
  case noActiveSubscription
  case other(Error)
}

public class TimeSheetService {
  
  //static let mockTimeSheetData = [TimeSheets1, TimeSheets2, TimeSheets3, TimeSheets4, TimeSheets5, TimeSheets6]
  
  public static let shared = TimeSheetService()
  let simulatedStartDate: Date
  
  private var sessions = [SessionId: Session]()
  
  init() {
    let persistedDateKey = "RWSSimulatedStartDate"
    if let persistedDate = UserDefaults.standard.object(forKey: persistedDateKey) as? Date {
      simulatedStartDate = persistedDate
    } else {
      let date = Date().addingTimeInterval(-30) // 30 second difference to account for server/client drift.
      UserDefaults.standard.set(date, forKey: "RWSSimulatedStartDate")
      
      simulatedStartDate = date
    }
  }
  
  /// Trade receipt for session id
  public func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion) {
    let body = [
      "receipt-data": data.base64EncodedString(),
      "password": itcAccountSecret
    ]
    let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
    
    let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = bodyData
    
    let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
      if let error = error {
        completion(.failure(.other(error)))
      } else if let responseData = responseData {
        let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
        print(json)
        let session = Session(receiptData: data, parsedReceipt: json)
        self.sessions[session.id] = session
        let result = (sessionId: session.id, currentSubscription: session.currentSubscription)
        completion(.success(result))
      }
    }
    
    task.resume()
  }
  
  /// Use sessionId to get TimeSheets
//  public func TimeSheets(for sessionId: SessionId, completion: LoadTimeSheetCompletion?) {
//    guard itcAccountSecret != "YOUR_ACCOUNT_SECRET" else {
//      completion?(.failure(.missingAccountSecret))
//      return
//    }
//
//    guard let _ = sessions[sessionId] else {
//      completion?(.failure(.invalidSession))
//      return
//    }
//
//    let paidSubscriptions = paidSubcriptions(since: simulatedStartDate, for: sessionId)
//    guard paidSubscriptions.count > 0 else {
//      completion?(.failure(.noActiveSubscription))
//      return
//    }
//
//    var sets = [TimeSheetSet]()
//    for (index, subscription) in paidSubscriptions.enumerated() {
//      guard let set = timeSheetSets(number: index) else { continue }
//      switch subscription.level {
//      case .one:
//        sets.append(set.setLimitedToOneTimeSheet())
//      case .all:
//        sets.append(set)
//      }
//    }
//
//    completion?(.success(sets))
//  }
  
  private func paidSubcriptions(since date: Date, for sessionId: SessionId) -> [PaidSubscription] {
    if let session = sessions[sessionId] {
      let subscriptions = session.paidSubscriptions.filter { $0.purchaseDate >= date }
      return subscriptions.sorted { $0.purchaseDate < $1.purchaseDate }
    } else {
      return []
    }
  }
  
//
//  public func timeSheetSets(number setNumber: Int) -> TimeSheetSet? {
//    guard setNumber < TimeSheetService.mockTimeSheetData.count else {
//      return nil
//    }
//
//    let bundle = Bundle(for: type(of: self))
//    let url = bundle.bundleURL.appendingPathComponent("TimeSheets", isDirectory: true)
//    guard FileManager.default.fileExists(atPath: url.path) else {
//      return nil
//    }
//
//    let TimeSheetNames = TimeSheetService.mockTimeSheetData[setNumber]
//    let timeSheet = TimeSheetNames.map { (name, fileName) -> TimeSheet in
//      let imageUrl = url.appendingPathComponent(fileName)
//      let imageData = try! Data(contentsOf: imageUrl)
//      let image = UIImage(data: imageData)!
//      let timeSheet = TimeSheet(name: name, image: image)
//      return timeSheet
//    }
//
//    return TimeSheetSet(name: "Set \(setNumber + 1)", timeSheet: timeSheet)
//  }
  
}
//
//private let TimeSheets1 = [
//  "Aaron Douglas":    "AaronDouglas-Stabby.jpg",
//  "Adam Rush":        "AdamRush-NewYork.jpg",
//  "Andy Obusek":      "AndyObusek.jpg"
//]
//
//private let TimeSheets2 = [
//  "Chris Wagner":     "ChrisWagner-RWPoster.jpg",
//  "David Worsham":    "DavidWorsham-Tree.jpg",
//  "Evan Dekhayser":   "EvanDekhayser-AirPods.jpg",
//  "Greg Heo":         "GregHeo-Sunny.jpg",
//  "Janie Clayton":    "JanieClayton-Peace.jpg",
//  "Jessy and Catie":  "JessyAndCatie-Xmas.jpg",
//  "Joshua and Ray":   "JoshAndRay.jpg"
//]
//
//private let TimeSheets3 = [
//  "Chris Wagner":     "ChrisWagner-SanDiego.jpg",
//  "Fuad Kamal":       "FuadKamal-Filtered.jpg",
//  "Janie Clayton":    "JanieClayton-Dinos.jpg",
//  "Jessy and Catie":  "JessyAndCatie-Dog.jpg",
//  "Kelvin Lau":       "KelvinLau-Panda.jpg",
//  "Mike Gazdich":     "MikeGazdich-Bunny.jpg",
//  "Richard Turton":   "RichardTurton-Book.jpg"
//]
//
//private let TimeSheets4 = [
//  "Jessy and Catie":    "JessyAndCatie-DogeOne.jpg",
//  "Kelvin Lau":         "KelvinLau-Eyes.jpg",
//  "Richard Turton":     "RichardTurton-Bourbon.jpg",
//  "Tammy Coron":        "TammyCoron-TreeHat.jpg",
//  "Tim Mitra":          "TimMitra-GregHeo.jpg",
//  "Joshua and Family":  "JoshAndFamily.jpg"
//]
//
//private let TimeSheets5 = [
//  "Chris Language":   "ChrisLanguage-Driving.jpg",
//  "Chris Wagner":     "ChrisWagner-Tesla.jpg",
//  "Mike Gazdich":     "MikeGazdich-XmasSweater.jpg",
//  "Richard Turton":   "RichardTurton-HelloKitty.jpg",
//  "Tim Mitra":        "TimMitra-Scream.jpg"
//]
//
//private let TimeSheets6 = [
//  "Chris Wagner":     "ChrisWagner-Doge.jpg",
//  "David Worsham":    "DavidWorsham-Tie.jpg",
//  "Tim Mitra":        "TimMitra-CoolHouses.jpg",
//  "Ray & Vicki":      "RayAndVicki.jpg",
//  "Cesare Rocchi":    "CesareRocchi-Beer.jpg"
//]
