//
//  AlertViewController.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/02/22.
//

import SwiftUI
import Combine

class TestAlertViewModel: ObservableObject {
    
    @Published var alerts = AlertViewController()
    
    func showParalleAlertsAction() {
        alerts.show(title: "Capija", message: "Del sol") {
            AlertAction.cancel() {
                
            }
            AlertAction("Confirm") {
                
            }
        }
        
        alerts.show(title: "La siguiente", message: "Del sol") {
            AlertAction.cancel() {
                
            }
            AlertAction("Confirm") {
                
            }
        }
    }
    
    func cocateningAlerts() {
        Task {
            await alerts.show(title: "Are you sure?",message: "When selecet one tome") {
                AlertAction("primero") {
                    
                }
            }
            
            await alerts.show(title: "Suceeesfull",message: "The employee was remove succefull") {
                AlertAction("Segundo") {
                    
                }
            }
            
        }
    }
    
    func resultDependencyAlerts() {
        let alert = AlertInfo(title: "Are you sure?",message: "When selecet one tome") {
            AlertAction.cancel()
            AlertAction("Confirm", action: confirmElimination)
            AlertAction("Eliminar") {
                self.alerts.show(title: "Suceeesfull",message: "The employee was remove succefull") {
                    AlertAction("Segundo") {
                        
                    }
                }
            }
        }
        alerts.show(alert)
    }
    
    func confirmElimination() {
        alerts.show(title: "Suceeesfull",message: "The employee was remove succefull") {
            AlertAction("Segundo") {
                
            }
        }
    }
}









struct AlertView: View {
    
    @StateObject private var viewModel = TestAlertViewModel()
    
    var body: some View {
        VStack {
            let _ = print("Update ALer View")
            Button("Lanzar mutiples al tiempo ", action: viewModel.showParalleAlertsAction)
                .padding()
            Button("Cocatening Alert await ", action: viewModel.cocateningAlerts)
                .padding()
            Button("Confitional", action: viewModel.resultDependencyAlerts)
                .padding()
        }.alert(from: viewModel.alerts)
    }
    
}
