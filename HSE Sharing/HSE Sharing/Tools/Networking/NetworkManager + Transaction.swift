//
//  NetworkManager + Transaction.swift
//  HSE Sharing
//
//  Created by Екатерина on 12.04.2022.
//

import Foundation

extension Api {
    
    func createTransaction(transaction: Transaction, _ completion: @escaping (Result<Transaction>) -> Void) {
        let session = createSession()
        let url = URL(string: "\(baseURL)/api/Transactions")!
        var request = createRequest(url: url, httpMethod: .POST)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: transaction.toDict, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(Result.failure(ApiError.badResponse))
                return
            }
            guard let safeData = data else {
                return completion(Result.failure(ApiError.couldNotParse))
            }
            let jsonData = Data(safeData)
            guard let result = try? self.decoder.decode(Transaction.self, from: jsonData) else {
                return completion(Result.failure(ApiError.couldNotParse))
            }
            CurrentUser.user.transactions?.append(result)
            return completion(Result.success(result))
        })
        task.resume()
    }
    
    func editSkill(transaction: Transaction, _ completion: @escaping (Result<Any>) -> Void) {
        let session = createSession()
        let url = URL(string: "\(baseURL)/api/Transaction/\(transaction.id)")!
        var request = createRequest(url: url, httpMethod: .PUT)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: transaction.toDict, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(Result.failure(ApiError.badResponse))
                return
            }
            if let transactions = CurrentUser.user.transactions {
                for i in 0...transactions.count {
                    if transactions[i].id == transaction.id {
                        CurrentUser.user.transactions![i] = transaction
                    }
                }
            }
            return completion(Result.success(""))
        })
        task.resume()
    }
    
    func deleteSkill(transaction: Transaction, _ completion: @escaping (Result<Any>) -> Void) {
        let session = createSession()
        let url = URL(string: "\(baseURL)/api/Transaction/\(transaction.id)")!
        let request = createRequest(url: url, httpMethod: .DELETE)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(Result.failure(ApiError.badResponse))
                return
            }
            return completion(Result.success(""))
        })
        task.resume()
    }
    
    func getTransactions(_ completion: @escaping (Result<[Transaction]>) -> Void) {
        let session = createSession()
        let url = URL(string: "\(baseURL)/api/Users/\(CurrentUser.user.mail!)/skills")!
        let request = createRequest(url: url, httpMethod: .GET)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                completion(Result.failure(ApiError.badResponse))
                return
            }
            guard let safeData = data else {
                return completion(Result.failure(ApiError.couldNotParse))
            }
            let jsonData = Data(safeData)
            guard let result = try? self.decoder.decode([Skill].self, from: jsonData) else {
                return completion(Result.failure(ApiError.couldNotParse))
            }
            return completion(Result.success(result))
        })
        task.resume()
    }
}
