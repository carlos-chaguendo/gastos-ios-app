//
//  ToolbarInputAccessory.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/06/21.
//


#if canImport(UIKit)
import UIKit

@available(tvOS, unavailable)
public class ToolbarInputAccessory: UIToolbar {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         prepare()
    }
    
    private func prepare() {
        setItems([.flexibleSpace(),  UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(toolbarActionDone))], animated: false)
    }
    
     /// Finaliza el estado de edicion de la vista, generando el cierre del teclado
    @objc final func toolbarActionDone() {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
    }
}
#endif
