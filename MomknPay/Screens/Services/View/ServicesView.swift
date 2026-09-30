//
//  ServicesView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 30/09/2026.
//

import SwiftUI

struct ServicesView: View {
    
    @State private var viewModel = ServicesViewModel()
    @FocusState private var isSearchFocused: Bool
    
     var body: some View {
        
        VStack {
            
            header
            SearchBar(text: $viewModel.query, isFocused: $isSearchFocused)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    ForEach(viewModel.sections, id: \.title) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title)
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(Color.inkMuted)

                            ForEach(section.items) { service in
                                if service.available {
                                    NavigationLink(value: service) {
                                        ServiceRow(service: service)
                                    }
                                    .buttonStyle(.plain)
                                    .simultaneousGesture(
                                        TapGesture().onEnded { isSearchFocused = false }
                                    )
                                } else {
                                    ServiceRow(service: service)
                                }
                            }
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture { isSearchFocused = false }
            .padding(.top, 8)
        }
        .containerBackground(Color.ground, for: .navigation)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .contentShape(Rectangle())
        .onTapGesture { isSearchFocused = false }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Service.self) { service in
            FeesInquiryView(service: service)
        }
        .onDisappear {
            viewModel.query = ""
        }
    }
 
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting)
                    .font(.subheadline)
                    .foregroundStyle(Color.inkMuted)
                Text("Guest")
                    .font(.title2.bold())
                    .foregroundStyle(Color.ink)
            }
            Spacer()
        }
    }
}
 


struct SearchBar: View {
    
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
 
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.inkMuted)
            TextField(
                "Search services",
                text: $text,
                prompt: Text("Search services").foregroundColor(Color.inkMuted).bold()
            )
            .foregroundStyle(Color.ink)
            .bold()
            .focused(isFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.inkMuted.opacity(0.1)))
    }
}


struct ServiceRow: View {
    
    let service: Service

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }

    var body: some View {
        HStack(spacing: 8) {
            icon

            Text(service.name)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.ink)

            Spacer()

            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white, in: shape)
        .overlay(shape.stroke(Color.inkMuted.opacity(0.15)))
        .opacity(service.available ? 1 : 0.6)
    }

    private var icon: some View {
        Image(systemName: "square.grid.2x2")
            .font(.title3)
            .foregroundStyle(service.available ? Color.ink : Color.inkMuted)
            .frame(width: 54, height: 54)
            .background(
                Color.inkMuted.opacity(0.12),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
    }

    @ViewBuilder
    private var trailing: some View {
        if service.available {
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.inkMuted.opacity(0.6))
        } else {
            Text("UNAVAILABLE")
                .font(.footnote.bold())
                .foregroundStyle(Color.warning)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.warning.opacity(0.15), in: Capsule())
        }
    }
}

#Preview {
    ServicesView()
}
 
