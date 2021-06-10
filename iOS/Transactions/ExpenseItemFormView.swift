//
//  ExpenseItemFormView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI
import Combine

struct ExpenseItemFormView: View {
    
    @Environment(\.presentationMode) private var presentation
    
    public let textChangePublisher = PassthroughSubject<String, Never>()
    
    private let backcolor = Colors.groupedBackground
    private let systemBackground = Colors.background
    
    @ObservedObject private var viewModel: ExpenseItemFormViewModel
    
    @State var categories = [Catagory]()
    
    init() {
        viewModel = .init()
    }
    
    init(_ item: ExpenseItem) {
        viewModel = .init(item)
        Logger.info("Formularo", item.value)
    }
    
    func setup( block: (Self) -> Self ) -> Self {
        return  block(self)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    CurrencyTextField(NSLocalizedString("Transaction Value", comment: ":"), value: $viewModel.amount, foregroundColor: Colors.Form.value, accentColor: Colors.Form.value)
                        .font(.title)
                        .frame(height: 50)
                    
                    TextField("Description", text: $viewModel.note)
                        .font(.body)
                        .frame(height: 50)
                        .accentColor(Colors.Form.value)
                        .foregroundColor(Colors.Form.value)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    /// Date picker
                    HStack {
                        Button("Today") {
                            self.viewModel.date = Date()
                        }
                        .padding()
                        .frame(height: 34)
                        .background(Colors.Tags.background3)
                        .accentColor(Color(Colors.subtitle))
                        .foregroundColor(Colors.primary)
                        .cornerRadius(3.0)
                        
                        Button("Yesterday") {
                            self.viewModel.date = Date().adding(.day, value: -1)!
                        }
                        .padding()
                        .frame(height: 34)
                        .background(Colors.Tags.background3)
                        .foregroundColor(Colors.primary)
                        .accentColor(Color(Colors.subtitle))
                        .cornerRadius(3.0)
                        
                        DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                            .labelsHidden()
                            .accentColor(Color(Colors.subtitle))
                            .background(.secondarySystemBackground)
                            .foregroundColor(.red)
                            .cornerRadius(3.0)
                        Spacer()
                    }.frame(height: 60)
                    
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.caption)
                            .padding(.bottom, 1)
                            .foregroundColor(Colors.Form.label)
                        
                        FlexibleView(data: categories) { category in
                            Button {
                                self.viewModel.category = category
                            } label: {
                                Text(verbatim: category.name)
                                    .font(.callout)
                                    .padding(6)
                                    .foregroundColor(category.id == self.viewModel.category?.id ? Colors.primary :  Colors.Form.label)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(Colors.Tags.background3))
                                    ).padding(2)
                                
                            }
                            
                        }
                    }.padding(.vertical)
                    
                    /// Wallet picker
                    PresentLinkView(destination: WalletsSelectionView(selection: $viewModel.wallets)) {
                        row(icon: "wallet.pass.fill", withArrow: true) {
                            ListLabel(items: $viewModel.wallets, empty: "Wallet")
                        }
                    }
                    
                    /// Tags picker
                    PresentLinkView(destination: TagSelectionView(selection: $viewModel.tags)) {
                        row(icon: "tag.fill", withArrow: true) {
                            TagsLabel(items: $viewModel.tags, empty: "Tags")
                        }
                    }
                    
                    Spacer()
                    
                }
                
            }
            .padding([.leading, .top, .trailing])
            .background(Colors.background)
          
            .navigationBarTitle("Expense", displayMode: .inline)
            .ignoresSafeArea(edges: [.bottom])
            .navigationBarItems(
                leading: Button {
                    self.presentation.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
                .frame(width: 30, height: 30)
                .foregroundColor(Colors.primary)
                .offset(x: -8, y: 0),
                
                trailing: Button(viewModel.item == nil ? "Create" : "Edit") {
                    self.saveAction()
                }.foregroundColor(Colors.primary)
                
            ).onReceive(Publishers.textFieldBeginEditing) { field in
                Logger.info("Field \( field.tag)", field)
            
                field.returnKeyType = .continue
                field.inputAccessoryView = ToolbarInputAccessory(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 44)))
                    .set(\.backgroundColor, Colors.background)
                    .set(\.tintColor, Colors.primary)
            }.onAppear {
                self.categories = Service.getAll(Catagory.self)
                    .sorted { $0.name < $1.name }
                    .filter { !$0.isHidden }
            }
        }
        
    }
    
    private func saveAction() {
        let selection = viewModel.getValues()
        
        Service.addItem(selection)
        self.presentation.wrappedValue.dismiss()
    }
    
    public func onTextChange( action: @escaping (String) -> Void) -> SubscriptionView<AnyPublisher<String, Never>, Self> {
        self.onReceive(textChangePublisher.eraseToAnyPublisher(), perform: action) as! SubscriptionView<AnyPublisher<String, Never>, ExpenseItemFormView>
    }
    
    @ViewBuilder
    func ListLabel<Value: Entity & EntityWithName>(items: Binding<Set<Value>>, empty: LocalizedStringKey) -> some View {
        if items.wrappedValue.isEmpty {
            Text(empty)
                .padding(.vertical)
                .foregroundColor(Colors.Form.label)
                .frame(minHeight: 60)
        } else {
            VStack(alignment: .leading) {
                Text(empty)
                    .font(.caption)
                    .padding(.bottom, 1)
                    .foregroundColor(Colors.Form.label)
                
                ForEach(Array(items.wrappedValue), id: \.self) {
                    Text($0.name)
                        .foregroundColor(Colors.Form.value)
                }
                
            }.padding(.vertical)
        }
    }
    
    @ViewBuilder
    func TagsLabel<Value: Entity & EntityWithName>(items: Binding<Set<Value>>, empty: LocalizedStringKey) -> some View {
        if items.wrappedValue.isEmpty {
            Text(empty)
                .padding(.vertical)
                .foregroundColor(Colors.Form.label)
        } else {
            VStack(alignment: .leading) {
                Text(empty)
                    .font(.caption)
                    .padding(.bottom, 1)
                    .foregroundColor(Colors.Form.label)
                
                FlexibleView(data: items.wrappedValue) { item in
                    Text(verbatim: item.name)
                        .font(.callout)
                        // .fontWeight(.medium)
                        .padding(3)
                        .foregroundColor(Colors.Form.value)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(Colors.Tags.background3))
                        )
                }
            }.padding(.vertical)
            
        }
    }
    
    @ViewBuilder
    func row<Content: View>(icon: String, withArrow: Bool = false, @ViewBuilder buildContent: () -> Content) -> some View {
        HStack {
            // Image(systemName: icon)
            buildContent()
            if withArrow {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.secondary)
                    .imageScale(.small)
            }
        }
    }
    
}

struct ExpenseItemFormView_Previews: PreviewProvider {
    
    @State private static var showingDetail = false
    
    static var previews: some View {
        Group {
            ExpenseItemFormView()
                .preferredColorScheme(.dark)
            
            ExpenseItemFormView()
                .preferredColorScheme(.light)
                .environment(\.locale, Locale(identifier: "es_Co"))
        }
    }
}
