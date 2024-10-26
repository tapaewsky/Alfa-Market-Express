//
//  CacheManager.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 17.10.2024.
//

//import Foundation
//import SwiftData
//
//final class CacheManager {
//    static let shared = CacheManager()
//    
//    private let defaults = UserDefaults.standard
//
//    // Универсальный метод для сохранения данных в кэш
//    func cacheData<T: Encodable>(key: String, data: T) {
//        do {
//            let encodedData = try JSONEncoder().encode(data)
//            defaults.set(encodedData, forKey: key)
//            print("Данные кэшированы для ключа: \(key)")
//        } catch {
//            print("Ошибка при кэшировании данных: \(error.localizedDescription)")
//        }
//    }
//
//    // Универсальный метод для загрузки данных из кэша
//    func loadData<T: Decodable>(key: String, type: T.Type) -> T? {
//        guard let cachedData = defaults.data(forKey: key) else {
//            print("Нет данных в кэше для ключа: \(key)")
//            return nil
//        }
//        do {
//            let decodedData = try JSONDecoder().decode(T.self, from: cachedData)
//            return decodedData
//        } catch {
//            print("Ошибка при загрузке данных из кэша: \(error.localizedDescription)")
//            return nil
//        }
//    }
//}
