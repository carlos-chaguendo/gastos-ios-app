//
//  View++.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 18/03/21.
//

import SwiftUI

extension View {
    
    @discardableResult
    public func set<Value>(_ key: WritableKeyPath<Self, Value>, _ value: Value) -> Self {
        var this = self
        this[keyPath: key] = value
        return this
    }
    
    @discardableResult
    public func set<Value>(_ key: ReferenceWritableKeyPath<Self, Value>, _ value: Value) -> Self {
        self[keyPath: key] = value
        return self
    }
    
    
    
    @ViewBuilder
    public func `if`<V: View>(_ condition: Bool, perform: (Self) -> V , else other: ((Self) -> V)? = nil ) -> some View {
        if condition {
            perform(self)
        } else if let other = other {
            other(self)
        } else {
            self
        }
    }
    
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func readOffset(named name: String,onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: OffsetPreferenceKey.self, value: proxy.frame(in: .named(name)))
            }.frame(height: 0)
        )
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onChange)
    }
    
    func background(_ color: ColorSpace) -> some View {
        self.background(Color(color))
    }
    
    func foregroundColor(_ color: ColorSpace) -> some View {
        self.foregroundColor(Color(color))
    }
    
    func accentColor(_ color: ColorSpace) -> some View {
        self.accentColor(Color(color))
    }
    
}



private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

private struct OffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGRect = .zero
  static func reduce(value: inout CGRect, nextValue: () -> CGRect) { }
}
