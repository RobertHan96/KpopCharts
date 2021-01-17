import Firebase
import FirebaseFirestore
import Toast_Swift
import Network

let checkNetworkConetion = NWPathMonitor()
let networkQueue = DispatchQueue.global(qos: .background)

struct Song {
    let title : String
    let artist : String
    let url : String
    let rank : Int
    let from : String
    
}

struct IsUploading {
    let isUploading : Bool

}
