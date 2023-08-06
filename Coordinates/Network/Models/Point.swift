//import Charts

struct Point: Identifiable, Decodable {
    var id: Int {
        return Int(x + 100 * y)
    }
    var x: Double
    var y: Double
}

extension Point: Equatable {
    
}

//extension Point: Plottable {
//    init?(primitivePlottable: Double) {
//        <#code#>
//    }
//    
//    var primitivePlottable: Double {
//        return x
//    }
//    
//}
