//
//  NetworkReachability.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 7/4/21.
//

import Foundation
import Alamofire

class NetworkReachability {
    static let shared = NetworkReachability()
    private let reachability = NetworkReachabilityManager(host: "www.qiki.com.au")!
    typealias NetworkReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus

    private init() {}
    
    /// Start observing reachability changes
    func startListening() {
        reachability.startListening { [weak self] status in
            switch status {
            case .notReachable:
                self?.updateReachabilityStatus(.notReachable)
            case .reachable(let connection):
                self?.updateReachabilityStatus(.reachable(connection))
            case .unknown:
                break
            }
        }
    }
    
    /// Stop observing reachability changes
    func stopListening() {
        reachability.stopListening()
    }
    
    /// Updated ReachabilityStatus status based on connectivity status
    ///
    /// - Parameter status: `NetworkReachabilityStatus` enum containing reachability status
    private func updateReachabilityStatus(_ status: NetworkReachabilityStatus) {
        switch status {
        case .notReachable:
            print("Internet not available...")
        case .reachable(.ethernetOrWiFi), .reachable(.cellular):
            print("Internet available...")
        case .unknown:
            print("Internet reachability status unknown...")
            break
        }
    }

    /// returns current reachability status
    var isReachable: Bool {
        return reachability.isReachable
    }

    /// returns if connected via cellular
    var isConnectedViaCellular: Bool {
        return reachability.isReachableOnCellular
    }

    /// returns if connected via cellular
    var isConnectedViaWiFi: Bool {
        return reachability.isReachableOnEthernetOrWiFi
    }

    deinit {
        stopListening()
    }
}
