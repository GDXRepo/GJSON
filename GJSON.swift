import UIKit

enum GJSONTypes {
    case number
    case string
    case bool
    case array
    case object
}

class GJSON {
    
    let json: Any
    
    init?(_ json: Any) {
        let asArray = json as? [Any]
        let asDict = json as? [String: Any]
        
        if asArray == nil && asDict == nil {
            return nil
        }
        self.json = json
    }
    
    func valueAt(_ path: String, of type: GJSONTypes) throws -> Any {
        let object = GJSON.path(path, json: json)
        
        switch type {
        case .number:
            return object as! NSNumber
        case .string:
            return object as! String
        case .bool:
            return object as! Bool
        case .array:
            return object as! [Any]
        case .object:
            return object as! [String: Any]
        }
    }
    
    func number(_ path: String) -> NSNumber? {
        return any(path) as? NSNumber
    }
    
    func string(_ path: String) -> String? {
        return any(path) as? String
    }
    
    func bool(_ path: String) -> Bool? {
        return any(path) as? Bool
    }
    
    func array(_ path: String) -> [Any]? {
        return any(path) as? [Any]
    }
    
    func object(_ path: String) -> [String: Any]? {
        return any(path) as? [String: Any]
    }
    
    func any(_ path: String) -> Any? {
        return GJSON.path(path, json: json)
    }
    
    static func path(_ path: String?, json: Any) -> Any? {
        let comps = path?.trimmingCharacters(in: CharacterSet(charactersIn: "/")).components(separatedBy: "/")
        var current: Any? = json
        // check for root path (empty or nil string)
        if path == nil || path?.characters.count == 0 {
            return current
        }
        for (i, comp) in comps!.enumerated() {
            // check special syntax
            if comp.hasPrefix(":") {
                // get array item index
                let indexRequest = comp.substring(from: comp.index(after: comp.startIndex))
                
                if let arrayIndex = Int(indexRequest) { // try to read element as array
                    if let asArray = current as? [Any] { // it's an array?
                        if arrayIndex < asArray.count { // we are inside its bounds?
                            current = asArray[arrayIndex] // then proceed
                        }
                        else { // outside of bounds?
                            print("invalid item index \"\(arrayIndex)\" in \(current!)")
                            return nil
                        }
                    }
                    else { // not an array?
                        print("item is not an array \"\(comp)\" in \(current!)")
                        return nil
                    }
                }
                else { // not a numeric index?
                    print("invalid item index \"\(indexRequest)\" in \(current!)")
                    return nil
                }
            }
            else if i < comps!.count { // we're still inside our components?
                if let unwrapped = current as? [String: Any] { // we can proceed for dictionary?
                    current = unwrapped[comp] // unwrap current item and repeat
                }
                else { // can't read a dictionary?
                    print("item is not a dictionary \"\(comp)\" in \(current!)")
                    return nil
                }
            }
        }
        return current
    }
    
}
