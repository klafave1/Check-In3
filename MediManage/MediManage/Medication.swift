import Foundation

struct Medication: Codable, Equatable {
   var name: String
   var dosage: String
   var timeOfDay: Date?
   
   static func ==(lhs: Medication, rhs: Medication) -> Bool {
       return lhs.name == rhs.name && lhs.dosage == rhs.dosage
   }
}
