//
//  GroupPercentGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/04/21.
//

import SwiftUI
import Combine

struct GroupPercentGraphView<Group: Entity & ExpensePropertyWithValue>: View {

    @ObservedObject var datasource: DataSource
    
    @State public var cancellables = Set<AnyCancellable>()
    
    public var title: LocalizedStringKey?
    public var showTotal = true
    public var showNavigation = true
    
    init(groupBy: KeyPath<ExpenseItem, Group>, title: LocalizedStringKey?, showTotal: Bool = true, showNavigation: Bool = true) {
        self.datasource = DataSource(group: groupBy)
        self.title = title
        self.showTotal = showTotal
        self.showNavigation = showNavigation
    }
    
    init(datasource: DataSource, title: LocalizedStringKey?, showTotal: Bool = true, showNavigation: Bool = true) {
        self.datasource = datasource
        self.title = title
        self.showTotal = showTotal
        self.showNavigation = showNavigation
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if showTotal {
                Text(NumberFormatter.currency.string(from: NSNumber(value: datasource.total)) ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.title)
     
            }
            
            if let title = title {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(Colors.subtitle)
                    .padding(.bottom, -3)
            }
            
            HStack {
                StackChart<Group>(
                    total: datasource.total,
                    categories: datasource.categories
                )

                if showNavigation {
                    NavigationLink(destination: CategoriesReportView()) {
                        Image(systemName: "chevron.right.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.quaternaryLabel)
                    }
                }
            }

            
    
            FlexibleView(data: datasource.categories) { category in
                HStack(alignment: .center, spacing: 0) {
                    Text("•")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundColor(UIColor.from(hex: UInt32(category.color)))
                        
                    
                    Text(category.name)
                        .font(.caption2)
                        .padding(.trailing, 2)
                        .foregroundColor(Colors.subtitle)
                        
                        
                }
            }//.padding(.top, -8)
         
        }
        
        //.cardView()
        //.animation(.none)
        .onReceive(Publishers.didAddNewTransaction) { item in
            self.fectDataSource(refresh: true)
        }.onReceive(Publishers.didEditTransaction) { item in
            self.fectDataSource(refresh: true)
        }.onAppear {
            self.fectDataSource()
        }
    }
    
    func fectDataSource(refresh: Bool = false, file: String = #file, line: Int = #line) {
        
        Logger.info("Fetch Datasource \(title)", file: file, line: line)
        
        if refresh {
            datasource.categories.removeAll()
        }
        
        guard datasource.categories.isEmpty else {
            return
        }
        
        datasource.getValuesGrouped()
    }
    

}


extension GroupPercentGraphView {
    
    class DataSource: ObservableObject, PropertyBuilder {
        
        public let groupBy: KeyPath<ExpenseItem, Group>
        
        @Published var mode = "M"
        @Published var date = Date()
        @Published var interval = DateInterval()
        @Published var total: Double = 0.0
        @Published var categories: [Group] = []
        @Published var cancellables = Set<AnyCancellable>()
        
        init(group: KeyPath<ExpenseItem, Group>) {
            self.groupBy = group
        }
        
        
        var calendarComponent: Calendar.Component { mode == "M" ? .month:   mode == "Y" ? .year : .weekOfMonth }
        
        private func getInterval(mode: String, date: Date = Date()) -> DateInterval {
            let componet = calendarComponent
            let start = date.withStart(of: componet)
            let end = date.withEnd(of: componet)
            return DateInterval(start: start, end: end)
        }
        
        func getValuesGrouped() {
            Deferred {
                Future<[Group], Never> { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let result = Service.expenses(by: self.groupBy, in: self.calendarComponent, of: self.date)
                        promise(.success(result))
                    }
                }
            }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { values in
                
                Logger.info("Obteneiendo resultados \(self.mode)", self.groupBy)
                
                self.interval = self.getInterval(mode: self.mode, date: self.date)
                self.categories = values
                self.total = values.map { $0.value }.reduce(0, +)
//                self.categories.forEach {
//                    $0.color = Int32(Color.random.uicolor.toHexInt())
//                }

            }.store(in: &cancellables)
        }
        
        func previousPage() {
            date = Calendar.gregorian.date(byAdding: calendarComponent, value: -1, to: date) ?? date
            self.getValuesGrouped()
        }
        
        func nextPage() {
            date = Calendar.gregorian.date(byAdding: calendarComponent, value: 1, to: date) ?? date
            self.getValuesGrouped()
        }
        
    }
    
}

struct GroupPercentGraphView_Previews: PreviewProvider {

    static let datasource = GroupPercentGraphView<Wallet>.DataSource(group: \.wallet)
    .set(\.total, 1)
    .set(\.categories, [
        Wallet {
            $0.name = "One"
            $0.value = 0.25
        },
        Wallet {
            $0.id = "2"
            $0.name = "Comida"
            $0.value = 0.75
        }
    ])
    

    static var previews: some View {
        Group {
            

            GroupPercentGraphView(datasource: datasource, title: "Category")
                .previewLayout(PreviewLayout.fixed(width: 350 , height: 100))
                .padding()
            
            GroupPercentGraphView(datasource: datasource, title: nil)
                .previewLayout(PreviewLayout.fixed(width: 350 , height: 100))
                .padding()

//
//            GroupPercentGraphView(groupBy: \.category, title: "Wallet")
//                .previewLayout(PreviewLayout.fixed(width: 350 , height: 100))
//                .preferredColorScheme(.dark)
        }
    }
}
