//
//  DocumentService.swift
//  Avecare
//
//  Created by stephen on 2020-05-26.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import Foundation
import CocoaLumberjack


struct DocumentService {

    let directory = userAppDirectory


    func savePDF(_ remoteFileURL: URL, name: String = newUUID) throws -> URL {
        DDLogVerbose("Loading file from: \(remoteFileURL)")

        let data = try Data(contentsOf: remoteFileURL)
        let localFileURL = userAppDirectory.appendingPathComponent(name).appendingPathExtension("pdf")
        try data.write(to: localFileURL)

        DDLogVerbose("Did save image to: \(localFileURL)")
        return localFileURL
    }


    func removePDF(at url: URL) throws {
        DDLogVerbose("")

        guard FileManager.default.fileExists(atPath: url.path) else {
            DDLogError("⚠️ Missing pdf file.")
            throw NSError(domain: "⚠️ Missing pdf file", code: -1)
        }

        FileManager.default.removeFileAt(url)
    }


    func PDFURL(name: String) -> URL? {
        let fileURL = directory.appendingPathComponent(name).appendingPathExtension("pdf")
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }
}
