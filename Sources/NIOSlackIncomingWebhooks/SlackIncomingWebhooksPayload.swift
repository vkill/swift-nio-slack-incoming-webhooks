public protocol SlackIncomingWebhooksPayload: Encodable {
    var text: String { get }
}

public struct SlackIncomingWebhooksSimplePayload: SlackIncomingWebhooksPayload {
    public var text: String

    public init(text: String) {
        self.text = text
    }
}

public struct SlackIncomingWebhooksSimpleMarkdownPayload: SlackIncomingWebhooksPayload {
    public var text: String
    public let mrkdwn: Bool = true

    public init(text: String) {
        self.text = text
    }
}
