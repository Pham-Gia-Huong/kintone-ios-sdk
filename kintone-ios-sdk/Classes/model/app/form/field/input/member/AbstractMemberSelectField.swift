//
//  AbstractMemberSelectField.swift
//  kintone-ios-sdk
//
//  Created by Pham Anh Quoc Phien on 9/19/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

public class AbstractMemberSelectField: AbstractInputField {
    internal var defaultValue: [MemberSelectEntity]
    internal var entities: [MemberSelectEntity]
    
    
    enum AbstractMemberSelectCodingKeys: CodingKey {
        case defaultValue
        case entities
    }
    
    public override init() {
        self.defaultValue = [MemberSelectEntity]()
        self.entities = [MemberSelectEntity]()
        super.init()
      
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AbstractMemberSelectCodingKeys.self)
        self.defaultValue = try container.decode([MemberSelectEntity].self, forKey: AbstractMemberSelectCodingKeys.defaultValue)
        self.entities = try container.decode([MemberSelectEntity].self, forKey: AbstractMemberSelectCodingKeys.entities)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AbstractMemberSelectCodingKeys.self)
        if(self.defaultValue.count > 0){
            try container.encode(self.defaultValue, forKey: AbstractMemberSelectCodingKeys.defaultValue)
        }
        if(self.entities.count > 0){
            try container.encode(self.entities, forKey: AbstractMemberSelectCodingKeys.entities)
        }
        try super.encode(to: encoder)
    }

    /**
     * @return the defaultValue
     */
    public func getDefaultValue() -> [MemberSelectEntity] {
        return self.defaultValue;
    }
    
    /**
     * @param defaultValue
     * the defaultValue to set
     */
    public func setDefaultValue(_ defaultValue: [MemberSelectEntity]) {
        self.defaultValue = defaultValue;
    }
    
    /**
     * @return the entites
     */
    public func getEntites() -> [MemberSelectEntity] {
        return self.entities
    }
    
    /**
     * @param entites
     * the entites to set
     */
    public func setEntites(_ entities: [MemberSelectEntity]) {
        self.entities = entities;
    }
}
