import Foundation
import Network
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class NetworkService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var locationManager: CLLocationManager

    @Published var connectedSSID: String = "N/A"
    @Published var connectedIP: String = "N/A"

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self

        // Request location access
        locationManager.requestWhenInUseAuthorization()
        
        // Start monitoring network changes
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.updateWifiInfo()
            } else {
                DispatchQueue.main.async {
                    self.connectedSSID = "No connection"
                    self.connectedIP = "N/A"
                }
            }
        }
        monitor.start(queue: queue)
    }

    // Called when the user grants or denies location permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // Update WiFi info when location access is granted
            updateWifiInfo()
        } else if status == .denied {
            DispatchQueue.main.async {
                self.connectedSSID = "Permission denied"
                self.connectedIP = "N/A"
            }
        }
    }

    private func updateWifiInfo() {
        DispatchQueue.main.async {
            if let ssid = self.getSSID() {
                self.connectedSSID = ssid
            }
            if let ip = self.getWiFiAddress() {
                self.connectedIP = ip
            }
        }
    }

    private func getSSID() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as? [String],
           let interface = interfaces.first,
           let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: AnyObject] {
            ssid = interfaceInfo["SSID"] as? String
        } else {
            ssid = "N/A"
        }
        return ssid
    }

    private func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee

                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    if flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK) == (IFF_UP|IFF_RUNNING) {
                        let name = String(cString: ptr!.pointee.ifa_name)
                        if name == "en0" { // en0 is the WiFi interface
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            if getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                           nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                                address = String(cString: hostname)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }

        return address
    }
}
