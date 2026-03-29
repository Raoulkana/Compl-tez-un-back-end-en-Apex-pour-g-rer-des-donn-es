public with sharing class OrderService {

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