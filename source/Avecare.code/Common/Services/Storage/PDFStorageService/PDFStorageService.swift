//
//  PDFStorageService.swift
//  educator
//
//  Created by syed Abbas on 2020-06-05.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit
import CocoaLumberjack



struct PDFStorageService {

    let directory: URL

    init() {
        directory = userAppDirectory.appendingPathComponent("images")
        _ = FileManager.default.createDirectory(directory)
    }


    func savePDF(_ data: Data, name: String = newUUID) throws -> URL {
        DDLogVerbose("savePDF name: \(name)")
        let pdfURL = directory.appendingPathComponent(name).appendingPathExtension("jpg")
        try data.write(to: pdfURL)
        return pdfURL
    }


    func savePDF(_ remotePDFURL: URL, name: String = newUUID) throws -> URL {
        DDLogVerbose("Loading PDF from: \(remotePDFURL)")
        let data = try Data(contentsOf: remotePDFURL)
        let localPDFURL = directory.appendingPathComponent(name).appendingPathExtension("pdf")
        try data.write(to: localPDFURL)

        DDLogVerbose("Did save PDF to: \(localPDFURL)")
        return localPDFURL
    }


    func removePDF(at url: URL) throws {
        DDLogVerbose("")

        guard FileManager.default.fileExists(atPath: url.path) else {
            DDLogError("⚠️ Missing PDF file.")
            throw NSError(domain: "⚠️ Missing PDF file", code: -1)
        }
        FileManager.default.removeFileAt(url)
    }


    func pdfURL(name: String) -> URL? {
        let pdfURL = directory.appendingPathComponent(name).appendingPathExtension("pdf")
        guard FileManager.default.fileExists(atPath: pdfURL.path) else {
            return nil
        }
        return pdfURL
    }

}

