public with sharing class LivraisonManager {

    /**
     * Crée une livraison pour une commande et un tarif donné
     * @param orderId Id de la commande
     * @param tarifId Id du tarif choisi
     * @return Id de la livraison En préparation
     */
    @AuraEnabled
    public static Id createLivraison(Id orderId, Id tarifId) {
        if(orderId == null || tarifId == null) {
           AuraHandledException ex = new AuraHandledException('OrderId et TarifId sont requis');
    ex.setMessage('OrderId et TarifId sont requis');
    throw ex;
        }

        Livraison__c liv = new Livraison__c(
            Order__c = orderId,
            Tarif__c = tarifId,
            Statut__c = 'En préparation' // ou tout autre champ par défaut
        );

        insert liv;

        return liv.Id;
    }

    /**
     * Met à jour le tarif d'une livraison existante
     * @param livraisonId Id de la livraison
     * @param tarifId Id du nouveau tarif
     */
    @AuraEnabled
    public static void updateLivraison(Id livraisonId, Id tarifId) {
        if(livraisonId == null || tarifId == null) {
            AuraHandledException ex = new AuraHandledException('LivraisonId et TarifId sont requis');
    ex.setMessage('LivraisonId et TarifId sont requis');
    throw ex;
        }

        Livraison__c liv = [
            SELECT Id, Tarif__c
            FROM Livraison__c
            WHERE Id = :livraisonId
            LIMIT 1
        ];

        liv.Tarif__c = tarifId;

        update liv;
    }

    /**
     * Optionnel : méthode pour lancer un traitement complet de livraison
     * Exemple : sélectionner automatiquement le meilleur transporteur et créer la livraison
     */
    @AuraEnabled
    public static Id launchDelivery(Id orderId) {
        if(orderId == null) {
            AuraHandledException ex = new AuraHandledException('OrderId requis');
    ex.setMessage('OrderId requis');
    throw ex;
        }

        Order ord = [
            SELECT Id, Pays__c, Account_Type__c
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        // Récupérer le meilleur transporteur
        Transporteur__c bestTransporteur = LivraisonService.getBestTransporteur(ord.Pays__c, ord.Account_Type__c);

        if(bestTransporteur == null) {
    AuraHandledException ex = new AuraHandledException('Aucun transporteur disponible');
    ex.setMessage('Aucun transporteur disponible');
    throw ex;
}

        // Récupérer le tarif associé
        List<TarifLivraison__c> tarifs = [
            SELECT Id
            FROM TarifLivraison__c
            WHERE Pays__c = :ord.Pays__c
            AND Transporteur__c = :bestTransporteur.Id
            LIMIT 1
        ];

        if(tarifs.isEmpty()) {
    AuraHandledException ex = new AuraHandledException('Aucun tarif disponible');
    ex.setMessage('Aucun tarif disponible');
    throw ex;
}

        // Créer la livraison
        return createLivraison(orderId, tarifs[0].Id);
    }
}