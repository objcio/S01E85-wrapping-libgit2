//
//  AppDelegate.swift
//  LibGitWrapper
//
//  Created by Chris Eidhof on 23.01.18.
//  Copyright © 2018 objc.io. All rights reserved.
//

// -------- NOTE --------
// In order to compile this project you need to clone and integrate libgit2 into this Xcode project. Please see [Swift Talk 85](https://talk.objc.io/episodes/S01E85-wrapping-libgit2) for the details on how to do this.

import Cocoa

struct GitError: Error {
    let message: String
}

func wrap(_ fn: () -> Int32) throws {
    let result = fn()
    guard result == 0 else {
        let err = giterr_last()
        let message = String(cString: err!.pointee.message) // todo
        throw GitError(message: message)
    }
}

final class Repository {
    var pointer: OpaquePointer? = nil
    
    init(open path: String) throws {
        try wrap { git_repository_open(&pointer, path) }
    }
    
    deinit {
        git_repository_free(pointer)
    }
}

final class Reference {
    var pointer: OpaquePointer? = nil
    
    init(repository: Repository, dwim: String) throws {
        try wrap { git_reference_dwim(&pointer, repository.pointer, dwim) }
    }
    
    deinit {
        git_reference_free(pointer)
    }
    
    var name: String {
        return String(cString: git_reference_name(pointer))
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        git_libgit2_init()
        
        let path = "/Users/chris/Downloads/libgit/testrepo"
        do {
            let repo = try Repository(open: path)
            let reference = try Reference(repository: repo, dwim: "master")
            print(reference.name)
        } catch {
            print(error)
        }
    }

}

