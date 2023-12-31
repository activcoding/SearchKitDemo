//
//  SearchIndexer.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 02.11.23.
//

import Foundation

/// Ensures that critical sections of code only run on one thread at a time
public class Synchronised {
    private static let queue = DispatchQueue(label: "com.activcoding.SearchKitDemo")
    
    public class func withLock<T>(_ closure: () -> T) -> T {
        var result: T!
        queue.sync {
            result = closure()
        }
        return result
    }
}

/// Indexer using SKIndex
public class SearchIndexer {
    let queue = DispatchQueue(label: "com.activcoding.SearchKitDemo")
    
    public enum IndexType: UInt32 {
        /// Unknown index type (kSKIndexUnknown)
        case unknown = 0
        /// Inverted index, mapping terms to documents (kSKIndexInverted)
        case inverted = 1
        /// Vector index, mapping documents to terms (kSKIndexVector)
        case vector = 2
        /// Index type with all the capabilities of an inverted and a vector index (kSKIndexInvertedVector)
        case invertedVector = 3
    }
    
    public class CreateProperties {
        /// The type of the index to be created
        private(set) var indexType: SKIndexType = kSKIndexInverted
        /// Whether the index should use proximity indexing
        private(set) var proximityIndexing: Bool = false
        /// The stop words for the index
        private(set) var stopWords: Set<String> = Set<String>()
        /// The minimum size of word to add to the index
        private(set) var minTermLength: UInt = 1
        
        /// Create a properties object with the specified creation parameters
        ///
        /// - Parameters:
        ///   - indexType: The type of index
        ///   - proximityIndexing: A Boolean flag indicating whether or not Search Kit should use proximity indexing
        ///   - stopWords: A set of stopwords — words not to index
        ///   - minTermLength: The minimum term length to index (defaults to 1)
        public init(
            indexType: SearchIndexer.IndexType = .inverted,
            proximityIndexing: Bool = false,
            stopWords: Set<String> = [],
            minTermLengh: UInt = 1
        ) {
            self.indexType = SKIndexType(indexType.rawValue)
            self.proximityIndexing = proximityIndexing
            self.stopWords = stopWords
            self.minTermLength = minTermLengh
        }
        
        /// Returns a CFDictionary object to use for the call to SKIndexCreate
         func properties() -> CFDictionary {
            let properties: [CFString: Any] = [
                kSKProximityIndexing: self.proximityIndexing,
                kSKStopWords: self.stopWords,
                kSKMinTermLength: self.minTermLength,
            ]
            return properties as CFDictionary
        }
    }
    
    var index: SKIndex?
    
    /// Call  once at application launch to tell Search Kit to use the Spotlight metadata importers.
    lazy var dataExtractorLoaded: Bool = {
        SKLoadDefaultExtractorPlugIns()
        return true
    }()
    
    /// Stop words for the index, these are common words which should be ignored because they are not useful for searching
    private(set) lazy var stopWords: Set<String> = {
        var stopWords: Set<String> = []
        if let index = self.index,
           let properties = SKIndexGetAnalysisProperties(self.index),
           let sp = properties.takeRetainedValue() as? [String: Any] {
            stopWords = sp[kSKStopWords as String] as! Set<String>
        }
        return stopWords
    }()
    
    /// Close the index
    public func close() {
        if let index = self.index {
            SKIndexClose(index)
            self.index = nil
        }
    }
    
    init(index: SKIndex) {
        self.index = index
    }
    
    deinit {
        self.close()
    }
}

