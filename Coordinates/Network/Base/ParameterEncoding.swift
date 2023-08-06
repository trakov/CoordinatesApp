import Foundation

public typealias Parameters = [String: Any]

public enum ParameterEncoding {
    
    case url(parameters: Parameters)
    case json(parameters: Any)
    case formData(parameters: Parameters)
    case urlAndJson(urlParameters: Parameters, bodyParameters: Any)
    
    public func encode(urlRequest: inout URLRequest) throws {
        do {
            switch self {
            case .url(parameters: let parameters):
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: parameters)
            case .json(parameters: let parameters):
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: parameters)
            case .formData(parameters: let parameters):
                try FormDataParameterEncoder().encode(urlRequest: &urlRequest, with: parameters)
            case .urlAndJson(urlParameters: let urlParameters, bodyParameters: let bodyParameters):
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
            }
        } catch {
            throw error
        }
    }
}

public enum EncodeError : String, Error {
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
