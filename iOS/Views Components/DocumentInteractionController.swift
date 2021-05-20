//
//  DocumentInteractionController.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 27/04/21.
//

import UIKit
import SwiftUI
import CoreServices
import QuickLook

struct DocumentInteractionController: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = QLPreviewController

    var url: URL
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(url: self.url)
    }
    
    func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType {
        let ql = QLPreviewController()
        ql.dataSource = context.coordinator
        ql.delegate = context.coordinator
        return ql
    }

    func updateUIViewController(_ uiViewController: Self.UIViewControllerType, context: Self.Context) {
        
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        
        var url: URL
        
        init(url: URL) {
            self.url = url
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
           1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            self.url as QLPreviewItem
        }
        
        func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
            .updateContents
        }

    }

}
