//
//  SearchIndexer+Add.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 02.11.23.
//

import Foundation

extension SearchIndexer {
    /// Add some text to the index for a given URL
    ///
    /// - Parameters:
    ///   - url: The identifying URL for the text
    ///   - text: The text to add
    ///   - canReplace: if true, can attempt to replace an existing document with the new one.
    /// - Returns: true if the text was successfully added to the index, false otherwise
    public func add(_ url: URL, text: String, canReplace: Bool = false) -> Bool {
        guard let index = self.index,
              let document = SKDocumentCreateWithURL(url as CFURL) else {
            return false
        }
        
        //TODO: Check if the same is achieved with the following code
//        return synchronised(self) {
//            SKIndexAddDocumentWithText(index, document.takeUnretainedValue(), text as CFString, canReplace)
//        }
//        return Synchronised.withLock {
//            SKIndexAddDocumentWithText(index, document.takeUnretainedValue(), text as CFString, canReplace)
//        }
        return queue.sync {
            SKIndexAddDocumentWithText(index, document.takeUnretainedValue(), text as CFString, canReplace)
        }
    }
    
    /// Adds text content to the indexer using a URL string.
    ///
    /// - Parameters:
    ///   - textURL: A string representing the URL of the text content.
    ///   - text: The text content to be added to the indexer.
    ///   - canReplace: If true, can attempt to replace an existing document with the new one. Defaults to `false`.
    ///
    /// - Returns: `true` if the text content is successfully added to the indexer; otherwise, returns `false`.
    public func add(textURL: String, text: String, canReplace: Bool = false) -> Bool {
        guard let url = URL(string: textURL) else {
            return false
        }
        return self.add(url, text: text, canReplace: canReplace)
    }
    
    /// Adds a file as a document to the index.
    ///
    /// - Parameters:
    ///   - fileURL: The file URL for the document, e.g., file:///User/Essay.txt.
    ///   - mimeType: An optional MIME type. If nil, the function attempts to determine the file type from the extension.
    ///   - canReplace: A flag indicating whether to attempt to replace an existing document with the new one. Defaults to `false`.
    ///
    /// - Returns: `true` if the command was successful. **Note:** Even if the document wasn't updated, it still returns `true`.
    ///
    /// - Important:
    ///   If the document wasn't updated, the function still returns `true`. Be cautious when relying solely on the return value to determine if the document was replaced.
    public func add(fileURL: URL, mimeType: String? = nil, canReplace: Bool = false) -> Bool {
        guard self.dataExtractorLoaded,
              let index = self.index,
              let document = SKDocumentCreateWithURL(fileURL as CFURL) else {
                return false
              }
        // Try to detect the mime type if it wasn't specified
        let mime = mimeType ?? self.detectMimeType(fileURL)
        
        return queue.sync {
            SKIndexAddDocument(index, document.takeUnretainedValue(), mime as CFString?, canReplace)
        }
    }
    
    /// Recursively adds the files contained within a folder to the search index.
    ///
    /// - Parameters:
    ///   - folderURL: The folder to be indexed.
    ///   - canReplace: A flag indicating whether existing documents within the index can be replaced. Defaults to `false`.
    ///
    /// - Returns: The URLs of documents added to the index. If `folderURL` isn't a folder, returns an empty array.
    public func addFolderContent(folderURL: URL, canReplace: Bool = false) -> [URL] {
        let fileManger = FileManager.default
        
        var isDir: ObjCBool = false
        guard fileManger.fileExists(atPath: folderURL.path, isDirectory: &isDir),
              isDir.boolValue == true else {
            return []
        }
        
        var addedUrls: [URL] = []
        let enumerator = fileManger.enumerator(at: folderURL, includingPropertiesForKeys: nil)
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileManger.fileExists(atPath: fileURL.path, isDirectory: &isDir),
               isDir.boolValue == false,
               self.add(fileURL: fileURL, canReplace: canReplace) {
                addedUrls.append(fileURL)
            }
        }
        
        return addedUrls
    }
    
    /// Removes a document from the index.
    ///
    /// - Parameter url: The identifying URL for the document.
    ///
    /// - Returns: `true` if the document was successfully removed, `false` otherwise. **Note:** If the document didn't exist, this also returns `true`.
    public func remove(url: URL) -> Bool {
        let document = SKDocumentCreateWithURL(url as CFURL).takeUnretainedValue()
        return self.remove(document: document)
    }
    
    /// Remove an array of documents from the index
    ///
    /// - Parameter urls: An array of URLs identifying the documents to be removed.
    public func remove(urls: [URL]) {
        urls.forEach { url in
            _ = self.remove(url: url)
        }
    }
    
    /// Retrieves the indexing state of a document at the specified URL.
    ///
    /// - Parameter url: The URL of the document.
    ///
    /// - Returns: The indexing state of the document. Returns `kSKDocumentStateNotIndexed` if the document is not indexed.
    public func documentState(_ url: URL) -> SKDocumentIndexState {
        if let index = self.index,
           let document = SKDocumentCreateWithURL(url as CFURL) {
            return SKIndexGetDocumentState(index, document.takeUnretainedValue())
        }
        return kSKDocumentStateNotIndexed
    }
    
    /// Checks if a document at the specified URL is indexed.
    ///
    /// - Parameter url: The URL of the document.
    ///
    /// - Returns: `true` if the document is indexed; otherwise, returns `false`.
    public func documentIndexed(_ url: URL) -> Bool {
        return self.documentState(url) == kSKDocumentStateIndexed
    }
}
