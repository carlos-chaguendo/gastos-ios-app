//
//  TabBar.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 12/03/21.
//

import SwiftUI

struct TabBar: View {

    @Binding public var selectedIndex: Int
    @State private var removal: Edge = .leading
    @State private var insertion: Edge = .trailing
    @State private var tabIndex = 0

    private var pages: [TabBar.Page] = []
    public var background: Color = .white
    public var selectedColor: Color = .blue
    public var unselectedColor: Color = .gray

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabView(selection: $tabIndex) {
                    ForEach(0..<pages.count) { i in
                        pages[i]
                            .content
                            .tabItem { Text("\(i)")}
                    }
                }
                VStack {
                    Spacer()
                    ZStack {
                        HStack(spacing: 0) {
                            ForEach(0..<pages.count) { i in
                                pages[i].tab
                                    .padding(.horizontal, 4)
                                    .frame(width: geometry.size.width/CGFloat(pages.count), height: 40)
                                    .onTapGesture {
                                        self.removal = i > selectedIndex ? .leading : .trailing
                                        self.insertion = i > selectedIndex ? .trailing : .leading
                                        self.selectedIndex = i
                                        self.tabIndex = i
                                    }.foregroundColor(selectedIndex == i ? selectedColor : unselectedColor)
                            }
                        }
                        .frame(width: geometry.size.width, height: 54 + UIApplication.shared.windows.first { $0.isKeyWindow }!.safeAreaInsets.bottom)
                        .background(self.background.shadow(radius: 2))
                    }
                }
            }.edgesIgnoringSafeArea(.bottom)
        }
    }

    init(@ArrayBuilder<TabBar.Page> make: () -> [TabBar.Page]) {
        self._selectedIndex = .constant(0)
        self.pages = make()
    }

    func selectedIndex(_ selected: Binding<Int>) -> Self {
        self.set(\._selectedIndex, selected)
    }

}

// MARK: - Tab Bar Content
extension TabBar {

    /// Reprecenta una pagina de un TabBar, con su contenido y el item que actyiva el contenido
    struct Page: View {

        var content: AnyView?
        var tab: AnyView?

        var body: some View {
            EmptyView()
        }

        init<Content: View, Tab: View>(@ViewBuilder buildContent: () -> Content, @ViewBuilder tabItem buildTab: () -> Tab) {
            self.content =  AnyView(buildContent())
            self.tab =  AnyView(buildTab())
        }

        /// contructor para vistas
        ///
        ///     TabBar.Item(content: self) {
        ///         Button("Tab 1")
        ///     }
        /// - Parameters:
        ///   - content: Contenido
        ///   - buildTab: botton
        init<Content: View, Tab: View>(body: Content, @ViewBuilder tabItem buildTab: () -> Tab) {
            self.content =  AnyView(body)
            self.tab =  AnyView(buildTab())
        }

    }

}

// MARK: - Tab Bar Content Item
extension TabBar.Page {

    struct Item: View {

        let width: CGFloat = 24
        let height: CGFloat = 24
        let systemIconName: String
        let tabName: LocalizedStringKey

        var body: some View {
            VStack {
                Image(systemName: systemIconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .padding(.top, 10)
                Text(tabName)
                    .font(.caption2)
                Spacer()
            }
        }
    }

}

extension View {

    func tabBarItem<TabBarButton: View>( @ViewBuilder menuItems: () -> TabBarButton) -> TabBar.Page {
        TabBar.Page(body: self, tabItem: menuItems)
    }
}

struct FlexibleTabView_Previews: PreviewProvider {

    static var previews: some View {
        TabBar {

            VStack {
                Text("Capija")
                List {
                    Text("!").listRowBackground(Color.clear)
                    Text("!").listRowBackground(Color.clear)
                    Text("!").listRowBackground(Color.clear)
                }
            }.tabBarItem {
                    VStack {
                        Image(systemName: "waveform")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 53, height: 18)
                            .padding(.top, 10)
                        Text("Home")
                            .font(.footnote)
                        Spacer()
                    }
                }

            Text("Contenido2")
                .tabBarItem {
                    Text("s")
                }

            Text("Contenido2")
                .tabBarItem {
                    Text("btn")
                }

        }
        .set(\.background, Color(Colors.background))
        .set(\.selectedColor, Color(Colors.primary))
        .accentColor(.red)
        .foregroundColor(.red)
        .preferredColorScheme(.dark)
        .background(Colors.background)
    }
}
