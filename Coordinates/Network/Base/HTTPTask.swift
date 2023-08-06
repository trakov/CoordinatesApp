public typealias HTTPHeaders = [String:String]

public enum HTTPTask {
    case request
    
    case requestParameters(bodyEncoding: ParameterEncoding)
    
    case requestParametersAndHeaders(bodyEncoding: ParameterEncoding, additionHeaders: HTTPHeaders?)
}
