public with sharing class LivraisonManager {

    /**
     * Crée une livraison pour une commande et un tarif donné
     * @param orderId Id de la commande
     * @param tarifId Id du tarif choisi
     * @return Id de la livraison créée
     */
    @AuraEnabled
    public static Id createLivraison(Id orderId, Id tarifId) {
        if(orderId == null || tarifId == null) {
            throw new AuraHandledException('OrderId et TarifId sont requis.');
        }

        Livraison__c liv = new Livraison__c(
            Order__c = orderId,
            Tarif__c = tarifId,
            Status__c = 'Créée' // ou tout autre champ par défaut
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
            throw new AuraHandledException('LivraisonId et TarifId sont requis.');
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
            throw new AuraHandledException('OrderId requis.');
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
            throw new AuraHandledException('Aucun transporteur disponible pour cette commande.');
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
            throw new AuraHandledException('Aucun tarif disponible pour ce transporteur.');
        }

        // Créer la livraison
        return createLivraison(orderId, tarifs[0].Id);
    }
}