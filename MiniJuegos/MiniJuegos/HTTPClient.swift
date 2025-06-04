
import Foundation
import Alamofire
// Define APIError
struct APIError {
    let message: String
}
typealias APIHeaders = HTTPHeaders
typealias APIParameters = [String: Any]
enum APIMethod {
    case get
    case post
    case delete
    case put
    fileprivate var value: HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .delete: return .delete
        case .put: return .put
        }
    }
}
enum APIEncoding {
    case json
    case url
    fileprivate var value: ParameterEncoding {
        switch self {
        case .json: return JSONEncoding.default
        default: return URLEncoding.default
        }
    }
}
class HTTPClient {
    class func request<T: Codable>(
        endpoint: String,
        method: APIMethod = .get,
        encoding: APIEncoding = .url,
        parameters: APIParameters? = nil,
        headers: APIHeaders? = nil,
        onSuccess: @escaping (T) -> Void,
        onFailure: ((APIError) -> Void)? = nil
    ) {
        AF.request(
            endpoint,
            method: method.value,
            parameters: parameters,
            encoding: encoding.value,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let decodedObject):
                onSuccess(decodedObject)
            case .failure(let error):
                onFailure?(APIError(message: "Error: \(error.localizedDescription)"))
            }
        }
    }
}
