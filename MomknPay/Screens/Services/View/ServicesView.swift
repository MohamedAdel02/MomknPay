//
//  ServicesView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 30/09/2026.
//

import SwiftUI
import Kingfisher

struct ServicesView: View {

    @State var viewModel: ServicesViewModel
    @FocusState private var isSearchFocused: Bool
    @Environment(\.showToast) private var showToast


    var body: some View {

        VStack(spacing: 12) {

            header
            SearchBar(text: $viewModel.query, isFocused: $isSearchFocused)

            if viewModel.isStale, let syncedAt = viewModel.syncedAt {
                OfflineBanner(syncedAt: syncedAt)
            }

            content
        }
        .containerBackground(Color.ground, for: .navigation)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .contentShape(Rectangle())
        .onTapGesture { isSearchFocused = false }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Service.self) { service in
            FeesInquiryView(viewModel: FeesInquiryViewModel(service: service))
        }
        .task { await viewModel.loadIfNeeded() }
        .onDisappear {
            viewModel.query = ""
        }
        .onChange(of: viewModel.refreshError) { _, error in
            guard let error else { return }
            showToast(.error(LocalizedStringKey(error.errorDescription ?? "")))
            viewModel.refreshError = nil
        }
    }


    @ViewBuilder
    private var content: some View {
        switch viewModel.state {

        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let error):
            MessageStateView(
                systemImage: error.symbolName,
                title: error.title,
                message: error.errorDescription ?? "",
                actionTitle: String(localized: "Try again"),
                action: { Task { await viewModel.load() } }
            )

        case .loaded:
            if viewModel.sections.isEmpty {
                emptyState
            } else {
                list
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.isSearching {
            MessageStateView(
                systemImage: "magnifyingglass",
                title: String(localized: "No results"),
                message: String(localized: "No services match \"\(viewModel.query)\".")
            )
        } else {
            MessageStateView(
                systemImage: "tray",
                title: String(localized: "No services yet"),
                message: String(localized: "There are no services available right now."),
                actionTitle: String(localized: "Refresh"),
                action: { Task { await viewModel.load() } }
            )
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: 12) {

                        Text(section.title)
                            .font(.footnote.weight(.bold))
                            .tracking(1.5)
                            .textCase(.uppercase)
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
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.immediately)
        .refreshable { await viewModel.load() }
        .onTapGesture { isSearchFocused = false }
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
