import struct Foundation.URL
import class Foundation.JSONEncoder
import HTTP

fileprivate let onDemandSharedEventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

public struct NIOSlackIncomingWebhooks {
    let eventLoopGroup: EventLoopGroup

    public init(eventLoopGroup: EventLoopGroup? = nil) throws {
        self.eventLoopGroup = eventLoopGroup
            ?? MultiThreadedEventLoopGroup.currentEventLoop
            ?? onDemandSharedEventLoopGroup
    }

    public func send<T>(
        _ payload: T,
        to webhookURL: URL,
        connectTimeout: TimeAmount = TimeAmount.seconds(10), // no support
        timeout: TimeAmount = TimeAmount.seconds(5)
    ) throws -> EventLoopFuture<Void> where T: SlackIncomingWebhooksPayload {
        guard let scheme = webhookURL.scheme, scheme == "https" else {
            throw NIOSlackIncomingWebhooksErrors.webhookURLInvalid
        }
        guard let _ = webhookURL.host else {
            throw NIOSlackIncomingWebhooksErrors.webhookURLInvalid
        }

        guard let hostname = webhookURL.host else {
            throw NIOSlackIncomingWebhooksErrors.webhookURLInvalid
        }

        return HTTPClient.connect(scheme: .https, hostname: hostname, on: eventLoopGroup) { error in
            Swift.print("SlackIncomingWebhooks httpClient handler error happened, error: \(error)")
        }.flatMap(to: Void.self) { httpClient in
            let httpClientCloseScheduleTask = self.eventLoopGroup.eventLoop.scheduleTask(in: timeout) { [weak httpClient] in
                httpClient?.close()
            }

            let jsonEncoder = JSONEncoder()
            // jsonEncoder.outputFormatting = .prettyPrinted
            let requestBodyData = try jsonEncoder.encode(payload)

            var request = HTTPRequest(method: .POST, url: webhookURL, body: HTTPBody(data: requestBodyData))
            request.headers.replaceOrAdd(name: .host, value: hostname)
            request.headers.replaceOrAdd(name: .contentType, value: "application/json")
            request.headers.replaceOrAdd(name: .userAgent, value: "vapor/http")

            return httpClient.send(request).flatMap(to: Void.self) { httpResponse in
                httpClientCloseScheduleTask.cancel()

                guard httpResponse.status == .ok else {
                    throw NIOSlackIncomingWebhooksErrors.sendPayloadFailed(httpResponse.status, httpResponse.headers, httpResponse.body.data)
                }
                return self.eventLoopGroup.future()
            }.always {
                httpClient.close().do { _ in
                }.catch{ error in
                    Swift.print("SlackIncomingWebhooks httpClient close failed, error: \(error)")
                }
            }
        }
    }
}
