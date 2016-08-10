//
//  SourceEditorCommand.swift
//  MakeEmPrivate
//
//  Created by Daniela Bulgaru on 10/08/2016.
//  Copyright © 2016 testProject. All rights reserved.
//

import Foundation
import XcodeKit


class SourceEditorCommand: NSObject, XCSourceEditorCommand {
  
  struct Line {
    var modifiedLine: String
    var lineNumber: Int
  }
  
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (Error?) -> Void) {
    
    let lines: NSMutableArray = invocation.buffer.lines
    
    privatize(property: "@IBOutlet", in: lines).forEach { line in
      invocation.buffer.lines.replaceObject(at: line.lineNumber, with: line.modifiedLine)
    }
    
    privatize(property: "@IBAction", in: lines).forEach { line in
      invocation.buffer.lines.replaceObject(at: line.lineNumber, with: line.modifiedLine)
    }
    
    completionHandler(nil)
    
  }
  
  private func privatize(property: String, in lines: NSMutableArray) -> [Line] {
    var modifiedLines: [Line] = []
    
    for (lineNumber, line) in lines.enumerated() {
      let stringLine = line as! String
      if stringLine.range(of: property) != nil  &&  stringLine.range(of: "private") == nil {
        print(line)
        modifiedLines.append(Line(modifiedLine: stringLine.replacingOccurrences(of: property, with: "\(property) private"), lineNumber: lineNumber))
      }
    }
    return modifiedLines
  }
}

