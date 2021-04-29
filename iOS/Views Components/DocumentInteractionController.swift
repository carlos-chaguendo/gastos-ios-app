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

    var url: URL
//    var callback: (URL) -> Void

//    func makeCoordinator() -> Coordinator {
//        return Coordinator(documentController: self)
//    }

    func updateUIViewController(
        _ uiViewController: UIDocumentInteractionController,
        context: UIViewControllerRepresentableContext<DocumentPickerViewController>) {
    }

    func makeUIViewController(context: Context) -> UIDocumentInteractionController {
        let controller = UIDocumentInteractionController(url: url)
       // context.coordinator.
//        controller.delegate = context.coordinator
        return controller
    }

    class Coordinator: NSObject, UIDocumentInteractionControllerDelegate {
        var documentController: DocumentPickerViewController
        

        init(documentController: DocumentPickerViewController) {
            self.documentController = documentController
        }
        
//        public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//            return documentController
//        }


    }



}
