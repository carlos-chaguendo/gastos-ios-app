//
//  ActivityViewController.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/06/21.
//
import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {
    
    class Model: ObservableObject {
        @Published var isPresented: Bool = false
        var url: URL?
    }
    
    let url: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: [])
        return activity
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
    
}
