//
//  IndexingAndSearchingTests.swift
//  SearchKitDemoTests
//
//  Created by Tommy Ludwig on 03.11.23.
//

@testable import SearchKitDemo
import XCTest

final class IndexingAndSearchingTests: XCTestCase {
    fileprivate func bundleResourceURL(forResource name: String, withExtension ext: String) -> URL {
        let thisSourceFile = URL(fileURLWithPath: #file)
        var thisDirectory = thisSourceFile.deletingLastPathComponent()
        thisDirectory = thisDirectory.appendingPathComponent("Resources")
        thisDirectory = thisDirectory.appendingPathComponent(name + "." + ext)
        return thisDirectory
    }
    fileprivate func bundleResourceFolderURL() -> URL {
        let thisSourceFile = URL(fileURLWithPath: #file)
        var thisDirectory = thisSourceFile.deletingLastPathComponent()
        thisDirectory = thisDirectory.appendingPathComponent("Resources")
        return thisDirectory
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func indexAndSearchFiles() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let filePath = bundleResourceURL(forResource: "APACHE_LICENSE", withExtension: "pdf")
        let textFilePath = bundleResourceURL(forResource: "the_school_short_story", withExtension: "txt")
        
        let iResult = indexer.add(fileURL: filePath, canReplace: false)
        XCTAssertEqual(iResult, true)
        
        indexer.flush()
        
        let searchResults = indexer.search("apache")
        print(searchResults)
        XCTAssertEqual(1, searchResults.count)
        XCTAssertEqual(filePath, searchResults[0].url)
    }
    
    func indexAndSearchFolder() {
        
    }

}
