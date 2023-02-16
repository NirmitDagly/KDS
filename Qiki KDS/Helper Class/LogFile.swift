//
//  LogFile.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 6/4/21.
//

import Foundation

struct TextLog: TextOutputStream {
    
    func checkIfFileExists(fileName: String) -> Bool {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:false)
            var fileURL = documentDirectory.appendingPathComponent("")
            fileURL = documentDirectory.appendingPathComponent(fileName + ".txt")
            
            if fileManager.fileExists(atPath: fileURL.path) {
                print("File already there")
                return true
            }
            else {
                return false
            }
        }
    }
    
    func createFile(fileName: String) {
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("File Path: \(fileURL.path)")
    }
    
    /// Appends the given string to the stream.
    mutating func write(_ string: String) {
        let data = string.components(separatedBy: "+")
        if data[0] == LogFileNames.logs.rawValue {
            writeIntoLogFile(string: data[1])
        }
    }
    
    func writeIntoLogFile(string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent(LogFileNames.logs.rawValue + ".txt")
        
        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteFile() {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(LogFileNames.logs.rawValue + ".txt")
            do {
                try fileManager.removeItem(atPath: fileURL.path)
            }
            catch let error as NSError {
                print(error)
            }
        }
    }
}
