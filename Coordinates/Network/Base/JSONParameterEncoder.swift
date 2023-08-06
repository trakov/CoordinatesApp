import Foundation

public struct JSONParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: Any) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw EncodeError.encodingFailed
        }
    }
}
