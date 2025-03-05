import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .loading
    @Published private(set) var products: [Product] = []
    
    private let productIds = ["com.yourapp.wrestlingcoachplus.monthly"]
    private let userDefaults = UserDefaults.standard
    private let trialDuration: TimeInterval = 14 * 24 * 60 * 60 // 14 days in seconds
    private var transactionTask: Task<Void, Error>?
    
    enum SubscriptionStatus: Equatable {
        case loading
        case trial(endDate: Date)
        case subscribed
        case notSubscribed
    }
    
    init() {
        // Start listening for transaction updates
        startTransactionListener()
        
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    deinit {
        transactionTask?.cancel()
    }
    
    private func startTransactionListener() {
        transactionTask = Task {
            for await verification in Transaction.updates {
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await checkSubscriptionStatus()
                }
            }
        }
    }
    
    private func loadProducts() async {
        do {
            products = try await Product.products(for: Set(productIds))
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    private var trialStartDate: Date? {
        get { userDefaults.object(forKey: "trialStartDate") as? Date }
        set { userDefaults.set(newValue, forKey: "trialStartDate") }
    }
    
    func startTrialIfNeeded() {
        guard trialStartDate == nil else { return }
        trialStartDate = Date()
    }
    
    private func checkSubscriptionStatus() async {
        var hasActiveSubscription = false
        
        // Check for active subscriptions
        for await verification in Transaction.currentEntitlements {
            guard case .verified(let transaction) = verification else { continue }
            
            // Check if transaction is valid
            if transaction.revocationDate == nil {
                if transaction.expirationDate == nil || transaction.expirationDate! > Date() {
                    hasActiveSubscription = true
                    break
                }
            }
        }
        
        if hasActiveSubscription {
            self.subscriptionStatus = .subscribed
        } else if let startDate = trialStartDate {
            let endDate = startDate.addingTimeInterval(trialDuration)
            if Date() < endDate {
                self.subscriptionStatus = .trial(endDate: endDate)
            } else {
                self.subscriptionStatus = .notSubscribed
            }
        } else {
            self.subscriptionStatus = .notSubscribed
        }
    }
    
    func updateSubscriptionStatus() async {
        await checkSubscriptionStatus()
    }
    
    func purchase() async throws {
        guard let product = products.first else { 
            throw SubscriptionError.noProductAvailable
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            switch verificationResult {
            case .verified(let transaction):
                await transaction.finish()
                await checkSubscriptionStatus()
            case .unverified:
                throw SubscriptionError.purchaseUnverified
            }
        case .userCancelled:
            throw SubscriptionError.userCancelled
        case .pending:
            throw SubscriptionError.purchasePending
        @unknown default:
            throw SubscriptionError.unknown
        }
    }
    
    func isFeatureUnlocked() -> Bool {
        switch subscriptionStatus {
        case .subscribed, .trial:
            return true
        case .notSubscribed, .loading:
            return false
        }
    }
}

enum SubscriptionError: Error {
    case purchaseUnverified
    case userCancelled
    case purchasePending
    case unknown
    case noProductAvailable
} 