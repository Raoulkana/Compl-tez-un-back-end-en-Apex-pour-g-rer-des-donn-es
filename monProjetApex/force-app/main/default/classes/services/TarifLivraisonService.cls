public with sharing class TarifLivraisonService {

    @AuraEnabled(cacheable=true)
    public static List<TarifLivraison__c> getTarifLivraison(Id orderId){

        // Récupérer la commande
        Order ord = [
            SELECT Id, Pays__c, Account_Type__c
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        // Récupérer les tarifs correspondants
        return [
            SELECT Id,
                   Prix__c,
                   Delai__c,
                   Transporteur__r.Id,
                   Transporteur__r.Name,
                   Transporteur__r.TypeClient__c
            FROM TarifLivraison__c
            WHERE Pays__c = :ord.Pays__c
            AND TypeClient__c = :ord.Account_Type__c
            ORDER BY Prix__c ASC
        ];
    }
}