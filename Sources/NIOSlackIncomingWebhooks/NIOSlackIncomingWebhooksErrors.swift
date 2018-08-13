import NIOHTTP1
import struct Foundation.Data

public enum NIOSlackIncomingWebhooksErrors: Error {
    case webhookURLInvalid

    case sendPayloadFailed(HTTPResponseStatus, HTTPHeaders, Data?)
}
