enum RequestError: Error {
    case noDataToDecode
    case decode(DecodingError?)
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode(Int)
    case unknown
    
    var customMessage: String {
        switch self {
        case .noDataToDecode, .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        default:
            return "Unknown error"
        }
    }
}
