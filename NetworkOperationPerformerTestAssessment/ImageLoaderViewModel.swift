//
//  ImageLoaderViewModel.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 19.06.2024.
//

import SwiftUI
import Combine

let urlExample = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/London_Big_Ben_Phone_box.jpg/800px-London_Big_Ben_Phone_box.jpg")

enum NetworkError: Error {
    case urlIsInvalid
    case cantConvertImage
    case requestWasCancelled
    case somethingWentWrong
    case requestFailed
    case timeoutError
    
    var message: String {
        switch self {
        case .urlIsInvalid, .cantConvertImage, .somethingWentWrong, .requestFailed, .timeoutError:
            return "Something went wrong"
        case .requestWasCancelled:
            return "Request was cancelled"
        }
    }
}

@MainActor
final class ImageLoaderViewModel: ObservableObject {
    
    enum State {
        case loading(alertText: String?)
        case success(Image)
        case failed(String)
        
        var isTerminated: Bool {
            switch self {
            case .loading:
                return false
            case .success, .failed:
                return true
            }
        }
    }
    
    @Published var state: State = .loading(alertText: nil)

    private let networkPerformer: NetworkOperationPerformer
    private let networkMonitor: NetworkMonitor
    private let networkService: NetworkService
    
    private var internalState: State = .loading(alertText: nil)
    
    init(
        networkPerformer: NetworkOperationPerformer = NetworkOperationPerformerImpl(),
        networkMonitor: NetworkMonitor = .init(),
        networkService: NetworkService = NetworkServiceImpl()
    ) {
        self.networkPerformer = networkPerformer
        self.networkMonitor = networkMonitor
        self.networkService = networkService
    }
    
    func monitorInternetConnection(with delay: TimeInterval = 0.5) {
        Task {
            do {
                try await Task.sleep(seconds: delay)
                for await isConnected in await networkMonitor.addNetworkStatusChangeObserver() {
                    state = .loading(alertText: !isConnected ? "No internet connection" : nil)
                }
            } catch {
                print(error)
            }
        }
    }

    func loadImage(durationSeconds: TimeInterval = 5) async {
        state = .loading(alertText: nil)
        do {
            try await networkPerformer.performNetworkOperation(using: {
                do {
                    try await self.updateDownloadedImage()
                } catch {
                    await self.showErrorState(.somethingWentWrong)
                }
            }, withinSeconds: durationSeconds)

            try await Task.sleep(seconds: durationSeconds)
            showResult()
        } catch {
            print(error)
            showErrorState(
                error is CancellationError ? .requestWasCancelled : .somethingWentWrong
            )
        }
    }
    
    // MARK: - Private methods

    private func updateDownloadedImage() async throws {
        let image = try await downloadImage()
        internalState = .success(image)
    }

    private func downloadImage() async throws -> Image {
        guard let url = urlExample else {
            throw NetworkError.urlIsInvalid
        }
        return try await networkService.fetchImage(from: url)
    }

    private func showResult() {
        state = internalState
    }

    private func showErrorState(_ error: NetworkError) {
        let errorMessage = error.message
        internalState = .failed(errorMessage)
        state = internalState
    }
}
