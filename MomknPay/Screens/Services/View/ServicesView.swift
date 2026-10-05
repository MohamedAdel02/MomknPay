//
//  ServicesView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 30/09/2026.
//

import SwiftUI
import Kingfisher

struct ServicesView: View {

    @State private var viewModel: ServicesViewModel
    @FocusState private var isSearchFocused: Bool
    @Environment(\.showToast) private var showToast

    init(viewModel: ServicesViewModel = ServicesViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

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
            FeesInquiryView(service: service)
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
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }

    var body: some View {
        HStack(spacing: 14) {
            icon

            VStack(alignment: .leading, spacing: 2) {
                Text(service.nameEn)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(service.available ? Color.ink : Color.inkMuted)

                if !service.nameAr.isEmpty {
                    Text(service.nameAr)
                        .font(.subheadline)
                        .foregroundStyle(Color.inkMuted)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.85)

            Spacer(minLength: 2)

            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white, in: shape)
        .overlay(shape.stroke(Color.inkMuted.opacity(0.15)))
        .opacity(service.available ? 1 : 0.6)
        .accessibilityElement(children: .combine)
    }

    private var icon: some View {
        Group {
            if let urlString = service.iconUrl, let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder { placeholderIcon }
                    .fade(duration: 0.2)
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
            } else {
                placeholderIcon
            }
        }
        .frame(width: 56, height: 56)
        .background(
            Color.inkMuted.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var placeholderIcon: some View {
        Image(systemName: "square.grid.2x2")
            .font(.title2)
            .foregroundStyle(service.available ? Color.ink : Color.inkMuted)
    }

    @ViewBuilder
    private var trailing: some View {
        if service.available {
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.inkMuted.opacity(0.6))
        } else {
            Text("UNAVAILABLE")
                .font(.caption.bold())
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(Color.warning)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.warning.opacity(0.15), in: Capsule())
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        ServicesView(viewModel: ServicesViewModel(repository: MockServiceRepository()))
    }
}

#Preview("Offline, saved list") {
    NavigationStack {
        ServicesView(viewModel: ServicesViewModel(repository: MockServiceRepository(stale: true)))
    }
}

#Preview("Offline, nothing saved") {
    NavigationStack {
        ServicesView(viewModel: ServicesViewModel(
            repository: MockServiceRepository(result: .failure(.noConnectivity))
        ))
    }
}

#Preview("Service unavailable") {
    NavigationStack {
        ServicesView(viewModel: ServicesViewModel(
            repository: MockServiceRepository(
                result: .failure(.api(code: .serviceUnavailable, message: nil, field: nil))
            )
        ))
    }
}
 
