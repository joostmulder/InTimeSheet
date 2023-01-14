

import Foundation
import UIKit

public struct TimeSheetSet {
  public let name: String
  public let timeSheet: [TimeSheet]
  
  init(name: String, timeSheet: [TimeSheet]) {
    self.name = name
    self.timeSheet = timeSheet
  }
  
  init?(name: String, nameAndFileMap: [String: String]) {
    let bundle = Bundle(for: TimeSheetService.self)
    let url = bundle.bundleURL.appendingPathComponent("TimeSheets", isDirectory: true)
    guard FileManager.default.fileExists(atPath: url.path) else {
      return nil
    }
    
    let timeSheet = nameAndFileMap.map { (name, fileName) -> TimeSheet in
      let imageUrl = url.appendingPathComponent(fileName)
      let imageData = try! Data(contentsOf: imageUrl)
      let image = UIImage(data: imageData)!
      let timeSheet = TimeSheet(name: name, image: image)
      return timeSheet
    }
    
    self.name = name
    self.timeSheet = timeSheet
  }
  
  func setLimitedToOneTimeSheet() -> TimeSheetSet {
    if let firstTimeSheet = timeSheet.first {
      return TimeSheetSet(name: name, timeSheet: [firstTimeSheet])
    } else {
      return self
    }
  }
}
