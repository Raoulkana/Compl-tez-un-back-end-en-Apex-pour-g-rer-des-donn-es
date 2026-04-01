public with sharing class LivraisonManager {

    @AuraEnabled
    public static Livraison__c createLivraison(Id orderId) {

        // Ajouter Status pour que validateOrder fonctionne
        Order ord = [
            SELECT Id, Status, ShippingCountry, Account.Type
            FROM Order
            WHERE Id = :orderId
        ];

        // Valide la commande
        OrderService.validateOrder(ord);

        // Récupère le meilleur transporteur
        Transporteur__c t = LivraisonService.getBestTransporteur(
            ord.ShippingCountry,
            ord.Account.Type
        );

        // Création de la livraison
        Livraison__c liv = new Livraison__c(
            Order__c = ord.Id,
            Transporteur__c = t.Id,
            Statut__c = 'En préparation',
            DateExpedition__c = System.today(),
            DateLivraisonEstimee__c = System.today().addDays(3)
        );

        insert liv;
        return liv;
    }
}