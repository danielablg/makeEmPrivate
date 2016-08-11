//
//  SourceEditorCommand.swift
//  MakeEmPrivate
//
//  Created by Daniela Bulgaru on 10/08/2016.
//  Copyright © 2016 testProject. All rights reserved.
//

import Foundation
import XcodeKit

enum Commands: String {
  case IBOutletCmd = "test.ExtensionHostApp.MakeEmPrivate.IBOutlet"
  case IBActionCmd = "test.ExtensionHostApp.MakeEmPrivate.IBAction"
  case SelectionCmd = "test.ExtensionHostApp.MakeEmPrivate.Selection"
  case NoSelectionCmd = "test.ExtensionHostApp.MakeEmPrivate.NoSelection"
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
  

  struct SourceCodeLine {
    var newLine: String
    var lineIndex: Int
  }
  
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (Error?) -> Void) {
    
    let lines: NSMutableArray = invocation.buffer.lines

    switch invocation.commandIdentifier {
    case "test.ExtensionHostApp.MakeEmPrivate.IBOutlet":
      privateOutlets(lines: lines, buffer: invocation.buffer)
      
    case "test.ExtensionHostApp.MakeEmPrivate.IBAction":
      privateActions(lines: lines, buffer: invocation.buffer)
      
    case"test.ExtensionHostApp.MakeEmPrivate.Selection":

      guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
        completionHandler(NSError(domain: "MakeEmPrivate", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Selection"]))
        return
      }
      
      for lineIndex in selection.start.line ... selection.end.line {
        guard let line = invocation.buffer.lines[lineIndex] as? NSString else {
          continue
        }
        
        let i: Int, j: Int
        
        if lineIndex == selection.start.line {
          i = selection.start.column
          j = line.length - 1
        } else if lineIndex == selection.end.line {
          i = 0
          j = selection.end.column
        } else {
          i = 0
          j = line.length - 1
        }

        
        let range = NSRange(location: i, length: j - i)
        let lineToChange = line.substring(with: range)
        
        privatizeBoth(in: [lineToChange], buffer: invocation.buffer, lineIndex: lineIndex)
      }
      
    default:
      break
    }
    
    completionHandler(nil)
  }
  
  private func privatize(property: String, in lines: NSMutableArray) -> [SourceCodeLine] {
    var newLines: [SourceCodeLine] = []
    
    for (lineIndex, line) in lines.enumerated() {
      let stringLine = line as! String
      if stringLine.range(of: property) != nil  &&  stringLine.range(of: "private") == nil {
        print(line)
        newLines.append(SourceCodeLine(newLine: stringLine.replacingOccurrences(of: property, with: "\(property) private"), lineIndex: lineIndex))
      }
    }
    return newLines
  }
  
  private func privateOutlets(lines: NSMutableArray, buffer: XCSourceTextBuffer, lineIndex: Int? = nil) {
    privatize(property: "@IBOutlet", in: lines).forEach { line in
      buffer.lines.replaceObject(at: lineIndex ?? line.lineIndex, with: line.newLine)
    }
  }
  
  private func privateActions(lines: NSMutableArray, buffer: XCSourceTextBuffer, lineIndex: Int? = nil) {
    privatize(property: "@IBAction", in: lines).forEach { line in
      buffer.lines.replaceObject(at: lineIndex ?? line.lineIndex, with: line.newLine)
    }
  }
  
  private func privatizeBoth(in lines: NSMutableArray, buffer: XCSourceTextBuffer, lineIndex: Int) {
    privateOutlets(lines: lines, buffer: buffer, lineIndex: lineIndex)
    privateActions(lines: lines, buffer: buffer, lineIndex: lineIndex)
  }
}

