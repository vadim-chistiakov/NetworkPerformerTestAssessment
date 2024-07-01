//
//  NetworkMonitor.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 18.06.2024.
//

import Foundation
import Network

actor NetworkMonitor {
    
    private let monitor: NWPathMonitor
    private let accessQueue = DispatchQueue(label: "NetworkMonitorAccessQueue")

    private var isConnected = false
    private var isStarted = false

    init(monitor: NWPathMonitor = .init())  {
        self.monitor = monitor
    }
    
    func addNetworkStatusChangeObserver() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            monitor.pathUpdateHandler = { [weak self] path in
                guard let self else { return }
                let isConnected = path.status == .satisfied
                continuation.yield(isConnected)
                Task {
                    await self.updateStatus(isConnected)
                }
            }
            if !isStarted {
                monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
                isStarted = true
            }
        }
    }
    
    /// The method is nonisolated cause it only read `isConnected` property
    nonisolated func hasInternetConnection() -> Bool {
        var result = false
        accessQueue.sync {
            result = isConnected
        }
        return result
    }

    // MARK: - Private methods

    private func updateStatus(_ isConnected: Bool) {
        accessQueue.sync {
            self.isConnected = isConnected
        }
    }
    
}
