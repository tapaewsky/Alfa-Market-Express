//
//  ProductEntity.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.08.2024.
//

import Foundation
import CoreData
import Combine


@objc(ProductEntity)
public class ProductEntity: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var imageUrl: String?
    
    
}

extension ProductEntity {
    static func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
    }
}

extension ProductViewModel {
    func saveProductsToCoreData() {
        let context = PersistenceController.shared.container.viewContext
        for product in products {
            let entity = ProductEntity(context: context)
            entity.id = Int64(product.id)
            entity.name = product.name
            entity.imageUrl = product.imageUrl
            
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save products: \(error)")
        }
    }
    
    func loadProductsFromCoreData() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = ProductEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            self.products = entities.map { entity in
                return Product(id: Int(entity.id), name: entity.name ?? "", description: entity.imageUrl ?? "image", price: "", imageUrl: "image", category: 1)
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
}
