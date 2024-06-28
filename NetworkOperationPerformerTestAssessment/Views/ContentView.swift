//
//  ContentView.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 18.06.2024.
//

import SwiftUI

struct ContentView: View {
    @State var taskId: CancelID? = CancelID()
    @State private var navigationPath = NavigationPath()
    @StateObject var viewModel = ImageLoaderViewModel()
    
    struct CancelID: Equatable {}

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                switch viewModel.state {
                case .loading(let networkMessage):
                    ProgressView()
                    if let networkMessage {
                        Text(networkMessage)
                            .foregroundStyle(.red)
                            .bold()
                    }
                    Spacer()
                    Button("Cancel") {
                        taskId = nil
                    }
                case .success, .failed:
                    EmptyView()
                }
            }
            .onChange(of: viewModel.state.isTerminated) { _, isTerminated in
                if isTerminated {
                    navigationPath.append("ResultView")
                }
            }
            .navigationTitle("Loading screen")
            .navigationDestination(for: String.self) { destination in
                if destination == "ResultView" {
                    ResultView(viewModel: viewModel)
                }
            }
            .padding()
            .onAppear {
                taskId = CancelID()
            }
            .task {
                print("Check internet connetion")
                viewModel.monitorInternetConnection()
            }
            .task(id: taskId) {
                guard taskId != nil else {
                    print("Task not started")
                    return
                }
                print("Task started")
                await viewModel.loadImage()
            }
            .background(Color(.systemBackground))
        }
    }

}

#Preview {
    ContentView()
}
