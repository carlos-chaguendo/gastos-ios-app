//
//  CategoriesReportView.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/04/21.
//

import SwiftUI


struct CategoriesReportView: View {
    
    @ObservedObject var datasource = GroupPercentGraphView<Catagory>.DataSource(group: \.category)
    
    @State var points: [CGPoint] = []
    
    
    var body: some View {
        GeometryReader { reader in
            
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    
                    Picker("", selection: $datasource.mode) {
                        ForEach(["W", "M","Y"], id:\.self) { mode in
                            Text(mode)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        Button(action: datasource.previousPage) {
                            Image(systemName: "chevron.left.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.quaternaryLabel)
                        }
                        
                        Spacer()
                        Text(DateIntervalFormatter.duration(range: datasource.interval))
                            .foregroundColor(Color.primary)
                        Spacer()
                        
                        Button(action: datasource.nextPage) {
                            Image(systemName: "chevron.right.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.quaternaryLabel)
                        }
                        
                    }.padding()
                    
                    GroupPercentGraphView(datasource: self.datasource, title: nil, showNavigation: false)
                    
                    ForEach(datasource.categories, id: \.self) { category in
                        
                        let percent = (category.value * 100)/datasource.total
                        NavigationLink(destination: TransactionsByCategoryView(for: category, in: datasource.calendarComponent, of: datasource.date)) {
                            HStack(alignment: VerticalAlignment.firstTextBaseline) {
                                Text(category.name)
                                    .font(.system(size: 15))
                                    //.fontWeight(.medium)
                                    .foregroundColor(Colors.title)
                                
                                Text("\(percent.rounded(toPlaces: 2).cleanValue)%")
                                    .font(.caption2)
                                    //.fontWeight(.semibold)
                                    .foregroundColor(Colors.subtitle)
                                
                                Spacer()
                                Text("\(NumberFormatter.currency.string(from: NSNumber(value: category.value)) ?? "")")
                                    .font(.system(size: 15))
                                    .foregroundColor(Colors.title)
                                
                                
                                Image(systemName: "chevron.right")
                                    .imageScale(.medium)
                                    .foregroundColor(.quaternaryLabel)
                            }
                        }.padding(.vertical, 10)
                        
                    }
                    
                    
                }.padding(.horizontal)
                
            }
            .padding(.vertical)
            .background(Colors.background)
            
        }.onAppear {
            
            guard datasource.categories.isEmpty else {
                return
            }
            datasource.getValuesGrouped()
            
            
        }
        .onChange(of: datasource.mode) { mode in
            
            Logger.info("Cambio el modo a ", mode)
            datasource.getValuesGrouped()
            
        }
        .navigationBarTitle("Categories", displayMode: .inline)
    }
    
    
}


//
//struct CategoriesReportView_Previews: PreviewProvider {
//
//
//    static var previews: some View {
//        NavigationView {
//            CategoriesReportView(
//                total: 10000,
//                catagories: [
//                    Catagory {
//                        $0.id = "1"
//                        $0.name = "Comida"
//                        $0.value = 5000
//                    },
//
//                    Catagory {
//                        $0.name = "Trago"
//                        $0.value = 2500
//                    },
//                ],
//                colorsByCategory: [
//                    "1": Color(Colors.primary)
//                ]
//            ).navigationTitle("Categories")
//            //.preferredColorScheme(.dark)
//
//        }
//
//    }
//}

