import CocoaLumberjack



extension FileManager {

   var applicationSupportDirectory: URL {
      let paths = self.urls(for: .applicationSupportDirectory, in: .userDomainMask)
      return paths.first!
   }


   var documentsDirectory: URL {
      let paths = self.urls(for: .documentDirectory, in: .userDomainMask)
      return paths.first!
   }


   var cachesDirectory: URL {
      let paths = self.urls(for: .cachesDirectory, in: .userDomainMask)
      return paths.first!
   }


   var tmpDirectory: URL {
      let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
      return tempDirectoryURL
   }


   var preferencesDirectory: URL {
      let paths = self.urls(for: .libraryDirectory, in: .userDomainMask)
      let preferences = paths.first!.appendingPathComponent("Preferences")
      return preferences
   }


   // https://gist.github.com/brennanMKE/a0a2ee6aa5a2e2e66297c580c4df0d66
   func directoryExistsAtPath(_ path: URL) -> Bool {
      var isDirectory = ObjCBool(true)
      let exists = self.fileExists(atPath: path.path, isDirectory: &isDirectory)
      return exists && isDirectory.boolValue
   }


   func createDirectory(_ filePath: URL) -> URL? {
      if !directoryExistsAtPath(filePath) {
         do {
            try self.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
         } catch {
            print(error.localizedDescription)
            return nil
         }
      }

      return filePath
   }


   func removeDirectory(_ filePath: URL) {
      removeFileAt(filePath)
   }


   func removeFileAt(_ filePath: URL) {
      do {
         try self.removeItem(atPath: filePath.path)
      } catch {
         print(error.localizedDescription)
      }
   }


   func fileCountIn(_ filePath: URL) -> Int {
      do {
         let fileURLs = try self.contentsOfDirectory(at: filePath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
         return fileURLs.count
      } catch {
         DDLogError("Error while enumerating files \(filePath.path): \(error.localizedDescription)")
         return -1
      }
   }


   func getAllFilesIn(_ filePath: URL) -> [URL]? {
      var fileURLs: [URL] = []
      var sortedFileURLs: [URL] = []

      do {
         let keys = [URLResourceKey.contentModificationDateKey,
                     URLResourceKey.creationDateKey]
         fileURLs = try self.contentsOfDirectory(at: filePath, includingPropertiesForKeys: keys, options: .skipsHiddenFiles)
      } catch {
         DDLogError("Error while enumerating files \(filePath.path): \(error.localizedDescription)")
         return nil
      }

      let orderedFullPaths = fileURLs.sorted(by: { (url1: URL, url2: URL) -> Bool in
         do {
            let values1 = try url1.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
            let values2 = try url2.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])

            if let date1 = values1.creationDate, let date2 = values2.creationDate {
               return date1.compare(date2) == ComparisonResult.orderedDescending
            }
         } catch {
            DDLogError("Error comparing : \(error.localizedDescription)")
            return false
         }
         return true
      })

      for fileName in orderedFullPaths {
         do {
            let values = try fileName.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
            if values.creationDate != nil {
               sortedFileURLs.append(fileName)
            }
         } catch {
            DDLogError("Error sorting file URL's. : \(error.localizedDescription)")
            return nil
         }
      }

      return sortedFileURLs
   }


   func getAllDirectoriesIn(_ filePath: URL) -> [URL]? {
      var directoryURLs: [URL] = []

      do {
         let keys = [URLResourceKey.isDirectoryKey]
         directoryURLs = try self.contentsOfDirectory(at: filePath, includingPropertiesForKeys: keys, options: .skipsHiddenFiles)
      } catch {
         DDLogError("Error while enumerating directories \(filePath.path): \(error.localizedDescription)")
         return nil
      }

      return directoryURLs
   }


   func getMostRecentFileIn(_ filePath: URL) -> URL? {
      return getAllFilesIn(filePath)?.first
   }


   func addSkipBackupAttributeToItemAtURL(url: NSURL) throws {
      try url.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
   }

}


extension FileManager {

   func clearTmpDirectory() {
      if let allDirectories = getAllDirectoriesIn(temporaryDirectory), !allDirectories.isEmpty {
         for dir in allDirectories {
            removeDirectory(dir)
         }
      }
   }

}
