public with sharing class OrderService {

    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders() {
        return [
            SELECT Id, Name, Account_Type__c, Pays__c
            FROM Order
            WHERE Status = 'Activated'
            LIMIT 100
        ];
    }

    public static void validateOrder(Order ord) {
        if (ord.Status != 'Activated') {
            throw new AuraHandledException('Commande non activée');
        }

        List<OrderItem> items = [
            SELECT Id, Quantity, UnitPrice
            FROM OrderItem
            WHERE OrderId = :ord.Id
        ];

        if (items.isEmpty()) {
            throw new AuraHandledException('Commande vide');
        }
    }
}