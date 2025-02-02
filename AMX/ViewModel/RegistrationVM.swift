//
//  RegistrationVM.swift
//  AMX
//
//  Created by Said Tapaev on 02.02.2025.
//

import Foundation

class RegistrationVM: ObservableObject {
    @Published var registration: Registration
    @Published var isCodeSent: Bool = false
    @Published var isVerified: Bool = false
    @Published var accessToken: String? // Свойство для хранения access token
    
    init() {
        self.registration = Registration()
    }

    // Функция для отправки кода на сервер
    func sendCode(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://77d4-194-164-235-45.ngrok-free.app/api/send_code/") else {
            completion(false, "Неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["phone": phoneNumber]
        
        // Логируем тело запроса и заголовки
        logRequestHeaders(request)
        logRequestBody(body)
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Логируем ошибку
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            // Логируем ответ
            if let data = data {
                self.logResponseBody(data)
            }
            
            // Дополнительная обработка ответа от сервера
            DispatchQueue.main.async {
                self.isCodeSent = true
            }
            completion(true, "Код отправлен на ваш номер!")
        }.resume()
    }

    func verifyCode(phoneNumber: String, code: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://77d4-194-164-235-45.ngrok-free.app/api/verify_code/") else {
            completion(false, "Неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Логируем токен перед отправкой запроса
        if let token = accessToken {
            print("Токен передан в заголовке: \(token)")  // Логирование токена
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Добавляем токен в заголовок
        } else {
            print("Токен не найден в момент отправки запроса.")  // Логируем отсутствие токена
        }
        
        let body: [String: Any] = ["phone": phoneNumber, "code": code]
        
        // Логируем тело запроса как XML
        let bodyXml = convertDictionaryToXML(body)
        logRequestBody(bodyXml)
        logRequestHeaders(request)
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // Устанавливаем таймаут для запроса
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Логируем ошибку
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            
            // Обработка ответа от сервера
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    // Логируем ответ как XML
                    if let data = data {
                        let responseXml = self.convertDataToXML(data) // Явное использование self
                        self.logResponseBody(responseXml)
                    }
                    DispatchQueue.main.async {
                        self.isVerified = true
                    }
                    completion(true, "Код успешно подтвержден!")
                case 400...499:
                    completion(false, "Ошибка клиента. Код ошибки: \(httpResponse.statusCode)")
                case 500...599:
                    completion(false, "Ошибка сервера. Попробуйте позже.")
                default:
                    completion(false, "Неизвестная ошибка. Код ответа: \(httpResponse.statusCode)")
                }
            } else {
                completion(false, "Не удалось получить ответ от сервера.")
            }
        }.resume()
    }
    
    func checkUserExistence(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://77d4-194-164-235-45.ngrok-free.app/api/me") else {
            completion(false, "Неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Добавляем токен в заголовок запроса
        if let token = accessToken {
            print("Токен передан в заголовке: \(token)")  // Логирование токена
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Токен не найден в момент отправки запроса.")  // Логируем отсутствие токена
            completion(false, "Токен не найден")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            if let data = data {
                // Обработка ответа от сервера
                let userExists = self.parseUserExistence(data)
                if userExists {
                    completion(true, nil) // Пользователь существует
                } else {
                    completion(false, "Пользователь не найден") // Пользователь не найден
                }
            } else {
                completion(false, "Ошибка получения данных")
            }
        }.resume()
    }

    func parseUserExistence(_ data: Data) -> Bool {
        // Здесь можно добавить логику для парсинга ответа
        // Например, если сервер возвращает статус 200 и данные о пользователе, считаем, что данные существуют
        // В данном примере возвращаем true, но нужно адаптировать под реальный формат данных.
        
        // Пример парсинга:
        // let decoder = JSONDecoder()
        // do {
        //     let response = try decoder.decode(UserResponse.self, from: data)
        //     return response.exists // Или другое условие на основе ответа
        // } catch {
        //     print("Ошибка парсинга: \(error.localizedDescription)")
        //     return false
        // }
        
        return true // Возвращаем true или false в зависимости от ответа сервера
    }

    // Функция для преобразования словаря в XML
    func convertDictionaryToXML(_ dictionary: [String: Any]) -> String {
        var xmlString = "<request>"
        for (key, value) in dictionary {
            xmlString += "<\(key)>\(value)</\(key)>"
        }
        xmlString += "</request>"
        return xmlString
    }

    // Функция для преобразования данных в XML строку
    func convertDataToXML(_ data: Data) -> String {
        guard let xmlString = String(data: data, encoding: .utf8) else {
            return "Ошибка преобразования данных в строку"
        }
        return xmlString
    }

    // Логирование тела запроса
    func logRequestBody(_ body: Any) {
        if let body = body as? [String: Any] {
            let jsonBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            if let jsonBody = jsonBody, let jsonString = String(data: jsonBody, encoding: .utf8) {
                print("Тело запроса (JSON):\n\(jsonString)")
            }
        } else if let bodyXml = body as? String {
            print("Тело запроса (XML):\n\(bodyXml)")
        }
    }

    // Логирование заголовков запроса
    func logRequestHeaders(_ request: URLRequest) {
        if let headers = request.allHTTPHeaderFields {
            print("Заголовки запроса:")
            for (key, value) in headers {
                print("\(key): \(value)")
            }
        }
    }

    // Логирование ответа
    func logResponseBody(_ body: Any) {
        if let body = body as? Data {
            if let responseString = String(data: body, encoding: .utf8) {
                print("Ответ сервера (JSON):\n\(responseString)")
            }
        } else if let bodyXml = body as? String {
            print("Ответ сервера (XML):\n\(bodyXml)")
        }
    }
}
