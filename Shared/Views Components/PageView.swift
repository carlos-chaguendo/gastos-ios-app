//
//  PageView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 7/04/21.
//

import SwiftUI

extension Collection where Index == Int {

    /// nil si el indice es menor a 0 o mayor a tamanio del array
    public subscript(safe index: Int, default defaultVlue: Element? = nil) -> Element? {
        return index >= 0 && index < count ? self[index] : defaultVlue
    }
}

/**
 Una vista scrollable que tiene la opcion de cambiar de pagina
 El usuario puede decidir sobre que tipo de elementos se va a vanzar y retroceder

     @state var page = 0
     @state var date = Date()
    
     VStack {
         /// Paginador de numeros
         PageView(steps: 1, currentPage: $page) { i  in
            Text("Page \(i)")
         }
 
         /// Paginador de dias
         PageView(currentPage: $date) { i  in
            Text("Day \(i)")
         } next: {
            $0.addingTimeInterval(3600)
         } prev : {
            $0.addingTimeInterval(-3600)
         }
     }
 - Agregar la funcionalidad de selecionar la dicecion del sxrol
 - agregar el valor minuimo y maximo
 - pasar esta configuracion al modelo
 */
struct PageView<SelectionValue : Hashable, Content: View>: View  {
    
    public var continuePage: Bool = true
    @Binding public var currentPage: SelectionValue
    @State private var isAnimatingPageChanged = false
    @State private var offset: CGFloat = 0
   
    
    @State private var prevOffset: CGFloat = 0

    
    public let content: (SelectionValue) -> Content
    
    public let next: (SelectionValue) -> SelectionValue
    public let prev: (SelectionValue) -> SelectionValue

    @State private var pages: Stack<Content> = []
    @State private var index: Stack<SelectionValue> = []

    
    @State private var availableWidth: CGFloat = 0
    
    //@ViewBuilder
    func getpage(at index: Int) -> some View {
        pages[index]
    }
    
    var body: some View {
        GeometryReader { reader in
 
            let width = reader.size.width
            let tolerance = width * 1/5
            
            if pages.isEmpty {
                Text("loasing")
                    .frame(width: width)
                    .onAppear {
                        generatePages()
                    }
            } else {
        
             
                if continuePage {
                    getpage(at: 0)
                        .if(isAnimatingPageChanged) {
                            $0.offset(x: -width + prevOffset + offset, y: 0)
                        }.if(!isAnimatingPageChanged) {
                            $0.offset(x: -width + prevOffset, y: 0)
                        }.frame(width: width)
                }
                   // .background(.systemBlue)
                    
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    Group {
                        getpage(at: continuePage ? 1 : 0)
                            .frame(width: width)
                            .offset(x: self.offset, y: 0)
                    }.readOffset(named: "scrollViewCoordinateSpaceID") { y in
                        
                        prevOffset = y.origin.x
                   
                        if y.maxX < width - tolerance {
                            pageChangeAnimation(screenWidth: -width)
                        }
                        
                        if y.minX > tolerance {
                            pageChangeAnimation(screenWidth: width)
                        }
                    }
                    
                }
                .coordinateSpace(name: "scrollViewCoordinateSpaceID")
              
                
                if continuePage {
                    getpage(at: 2)
                        .if(isAnimatingPageChanged) {
                            $0.offset(x: width + prevOffset + offset, y: 0)
                        }.if(!isAnimatingPageChanged) {
                            $0.offset(x: width + prevOffset, y: 0)
                        }.frame(width: width)
                }
                
                
            }
            
        }.clipped()
    }
    
    func generatePages() {
        if continuePage {
            index = [prev(currentPage), currentPage, next(currentPage) ]
            pages = [content(index[0]), content(currentPage), content(index[2])]
        } else {
            index = [currentPage]
            pages = [content(currentPage)]
        }
    }
    
    
    /// Ejecuta la animacion de cambiar pagina
    /// - Parameter size: tancho de la pantalla
    /// - Parameter updateSelected: un boleano que indica si tien que actualizar la fecha selecionada actualmente al cambiar de pagina
    func pageChangeAnimation(screenWidth size: CGFloat, updateSelected: Bool = true) {
        guard !isAnimatingPageChanged else { return }
        

        //isScrollEnabled = false
        
        isAnimatingPageChanged = true
        withAnimation(.easeInOut)  {
            self.offset = size
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            
            self.offset = -size
            
            if updateSelected {
                let sign = size < 0 ? 1 : -1
                print("Update select", sign)
                
                if sign > 0 {
                    /// =====>
     
                    let rightIndex = index.last
                    let newRight = next(rightIndex)
                    
                    index.right(newRight)
                    pages.right(content(newRight))
                    print("indices", index)
                    
                    
                    currentPage = rightIndex
                    
                    
                } else {
                    /// <=====
        
                    let leftIndex = index.first
                    let newleft = prev(leftIndex)
                    
                    index.left(newleft)
                    pages.left(content(newleft))
                    print("indices", index)
                    
                    currentPage = leftIndex
                }

            }
            
            if continuePage {
                self.offset = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isAnimatingPageChanged = false
                }
            } else {
                withAnimation(.easeInOut) {
                    self.offset = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isAnimatingPageChanged = false
                    }
                }
            }
            
      
        }
    }
}

extension PageView where SelectionValue: Numeric {
    
    init(continuePage: Bool = true, steps: SelectionValue, currentPage: Binding<SelectionValue>, content: @escaping (SelectionValue) -> Content) {
        self.init(continuePage: continuePage, currentPage: currentPage, content: content, next:  { current in
            return current + steps
        }, prev: {
            $0 - steps
        })

    }
    
    
}

struct PageView_Previews: PreviewProvider {
    @State static var selected: Int = 0
    
    static var previews: some View {
        VStack{
            PageView(continuePage: false, currentPage: $selected) { i -> Text in
                print("generando contenido", i)
                return Text("Esto son las fechas de\(i)")
            } next:  {
                $0 + 1
            } prev: {
                $0 - 1
            }.background(.blue)

            Text("Aqui termina")
            Spacer()
        }

    }
}
