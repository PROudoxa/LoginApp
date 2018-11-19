//
//  UserCoreDataModel+CoreDataProperties.swift
//  
//
//  Created by Alex Voronov on 19.11.18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension UserCoreDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCoreDataModel> {
        return NSFetchRequest<UserCoreDataModel>(entityName: "UserCoreDataModel");
    }

    @NSManaged public var avatarLink: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int32
    @NSManaged public var lastName: String?

}
