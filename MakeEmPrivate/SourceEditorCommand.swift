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
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        completionHandler(nil)
    }
    
}
