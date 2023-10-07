import HTTPTypes

extension HTTPFields {
  var headerDictionary: [String: String] {
    var combinedFields = [HTTPField.Name: String](minimumCapacity: self.count)
    for field in self {
      if let existingValue = combinedFields[field.name] {
        let separator = field.name == .cookie ? "; " : ", "
        combinedFields[field.name] = "\(existingValue)\(separator)\(field.isoLatin1Value)"
      } else {
        combinedFields[field.name] = field.isoLatin1Value
      }
    }
    var headerFields = [String: String](minimumCapacity: combinedFields.count)
    for (name, value) in combinedFields {
      headerFields[name.rawName] = value
    }
    return headerFields
  }
}

extension HTTPField {
  var isoLatin1Value: String {
    if self.value.isASCII {
      return self.value
    } else {
      return self.withUnsafeBytesOfValue { buffer in
        let scalars = buffer.lazy.map { UnicodeScalar(UInt32($0))! }
        var string = ""
        string.unicodeScalars.append(contentsOf: scalars)
        return string
      }
    }
  }
}

extension String {
  var isASCII: Bool {
    self.utf8.allSatisfy { $0 & 0x80 == 0 }
  }
}

extension [String: String] {
  subscript(_ header: HTTPField.Name) -> String? {
    get { self[header.rawName] }
    set { self[header.rawName] = newValue }
  }

  var asHttpFields: HTTPFields {
    var fields = HTTPFields()
    fields.reserveCapacity(self.count)
    for (name, value) in self {
        if let name = HTTPField.Name(name) {
          fields.append(HTTPField(name: name, value: value))
        }
    }
    return fields
  }
}
