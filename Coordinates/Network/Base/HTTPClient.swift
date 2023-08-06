import Foundation

protocol HTTPClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type,
        completion: @escaping (Result<T, RequestError>) -> Void
    )
    
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type,
        responseQueue: DispatchQueue,
        completion: @escaping (Result<T, RequestError>) -> Void
    )
}

extension HTTPClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type,
        completion: @escaping (Result<T, RequestError>) -> Void
    ) {
        sendRequest(
            endpoint: endpoint,
            responseModel: responseModel,
            responseQueue: .main,
            completion: completion
        )
    }
    
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type,
        responseQueue: DispatchQueue,
        completion: @escaping (Result<T, RequestError>) -> Void
    ) {
        do {
            let request = try buildRequest(from: endpoint)
            URLSession.shared.dataTask(with: request) { data, response, error in
                let result = handle(responseModel: responseModel, data: data, response: response, error: error)
                responseQueue.async {
                    switch result {
                    case .success(let model):
                        completion(.success(model))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }.resume()
        } catch let error as RequestError {
            return completion(.failure(error))
        } catch {
            return completion(.failure(.unknown))
        }
    }
}

private extension HTTPClient {
    func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
        guard let url = endpoint.url else {
            throw RequestError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        do {
            switch endpoint.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyEncoding):
                try bodyEncoding.encode(urlRequest: &request)
            case .requestParametersAndHeaders(let bodyEncoding, let additionalHeaders):
                addAdditionalHeaders(additionalHeaders, request: &request)
                try bodyEncoding.encode(urlRequest: &request)
            }
            return request
        } catch {
            throw error
        }
    }

    func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    func handle<T: Decodable>(responseModel: T.Type, data: Data?, response: URLResponse?, error: Error?) -> Result<T, RequestError> {
        guard let response = response as? HTTPURLResponse else {
            return .failure(.noResponse)
        }
        switch response.statusCode {
        case 204:
            guard (data?.isEmpty ?? true), responseModel is EmptyModel.Type else {
                return .failure(.noDataToDecode)
            }
            return .success(EmptyModel() as! T)
        case 200...299:
            guard let data = data else {
                return .failure(.noDataToDecode)
            }
            do {
                let decodedResponse = try JSONDecoder().decode(responseModel, from: data)
                return .success(decodedResponse)
            } catch {
                return .failure(.decode(error as? DecodingError))
            }
        case 401:
            return .failure(.unauthorized)
        default:
            return .failure(.unexpectedStatusCode(response.statusCode))
        }
    }
}
