//
//  FeesInquiryView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 29/09/2026.
//

import SwiftUI

struct FeesInquiryView: View {

    let service: Service

    @State var viewModel = FeesInquiryViewModel()
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            
            providerCard
            

            VStack(alignment: .leading, spacing: 10) {
                Text("Subscriber number")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.inkMuted)

                subscriberField

                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                    Text("10 digits, printed at the top of your bill")
                        .font(.system(size: 14))
                }
                .foregroundStyle(Color.inkMuted)
            }

            Spacer()

            PrimaryButton("Check My Bill") {

            }
            .disabled(!viewModel.isComplete)
            .opacity(viewModel.isComplete ? 1 : 0.5)

            
        }
        .navigationTitle("Fees Inquiry")
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Fees Inquiry")
                    .font(.headline)
                    .foregroundStyle(Color.ink)
            }
        }
        .tint(Color.ink) 
        .containerBackground(Color.ground, for: .navigation)
    }


    private var providerCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "bolt")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 56, height: 56)
                .background(Color.appPrimary.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))

            Text(service.nameEn)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.ink)

            Spacer()
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.ink.opacity(0.1)))
    }


    private var subscriberField: some View {
        TextField("", text: $viewModel.displayText)
            .keyboardType(.numberPad)
            .focused($isFocused)
            .font(.plexMono(28, weight: .medium))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 18)
            .frame(height: 64)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18).stroke(Color.ink.opacity(0.5), lineWidth: 1.5))
            .onChange(of: viewModel.displayText) {
                viewModel.formatSubscriberNumber()
            }
    }
    
}


//#Preview {
//    FeesInquiryView(service: Service(id: 1, name: "Cairo Electricity", available: true))
//}
