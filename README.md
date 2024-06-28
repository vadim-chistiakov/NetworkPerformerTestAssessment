# Test assessment

## Existing problems

- The original code relied on `NotificationCenter` for network status changes, which can be unreliable and is not thread-safe. And of couse outdated. Modern Swift code should leverage async/await, actors, and structured concurrency.
- The use of `NotificationCenter` and `Timer` makes the original code difficult to test in a controlled manner. For more info check https://developer.apple.com/videos/play/wwdc2018/417/ it helps to understand the problem deeply
- Avoiding dependency injection in a project can lead to several issues related to maintainability, testability, and scalability.
- The original code is leading to potential race conditions and undefined behavior.
- Timers often capture `self` strongly in their closures, leading to retain cycles. To avoid this, use `[weak self]`
- Using protocols for services in Swift is highly recommended for dependency injection and testing. Protocols help define clear contracts for your services, enabling you to decouple components, easily replace implementations, and facilitate unit testing by using mock or stub objects.

## Documentation for public method
```swift
protocol NetworkOperationPerformer {
    /// Executes a given asynchronous network operation and ensures it completes within a specified time limit.
    ///
    /// This method runs the provided network operation in a new task, allowing it to be canceled if needed.
    ///
    /// - Parameters:
    ///   - closure: An asynchronous closure representing the network operation to be performed.
    ///   - withinSeconds: A `TimeInterval` specifying the time limit in seconds within which the operation should complete.
    func performNetworkOperation(
        using closure: @escaping @Sendable () async -> Void,
        withinSeconds timeoutDuration: TimeInterval
    ) async throws
}
```
