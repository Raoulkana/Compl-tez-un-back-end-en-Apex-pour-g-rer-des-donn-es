public with sharing class OrderService {

    // Récupérer toutes les commandes activées
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders() {

        return [
            SELECT Id,
                   OrderNumber,
                   Status,
                   Account_Type__c,
                   Pays__c,
                   CreatedDate
            FROM Order
            WHERE Status = 'Activated'
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];

    }


    // Récupérer les détails d'une commande
    @AuraEnabled(cacheable=true)
    public static Order getOrderDetails(Id orderId){

        List<Order> orders = [
            SELECT Id,
                   OrderNumber,
                   Status,
                   EffectiveDate,
                   Pays__c,
                   Account_Type__c,
                   Account.Name,
                   TotalAmount
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        if(orders.isEmpty()){
            return null;
        }

        return orders[0];

    }


    // Validation métier
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