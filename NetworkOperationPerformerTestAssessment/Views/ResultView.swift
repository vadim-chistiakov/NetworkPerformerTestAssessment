//
//  ResultView.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 21.06.2024.
//

import SwiftUI

struct ResultView: View {
    
    @ObservedObject var viewModel: ImageLoaderViewModel

    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                EmptyView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .transition(.opacity)
            case .failed(let errorMessage):
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Result screen")
    }
    
}

#Preview {
    ResultView(viewModel: ImageLoaderViewModel())
}
