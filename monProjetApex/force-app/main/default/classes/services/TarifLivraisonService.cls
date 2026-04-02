public with sharing class TarifLivraisonService {

    @AuraEnabled(cacheable=true)
    public static List<TarifLivraison__c> getTarifs(Id orderId){

        Order ord = [
            SELECT Id, Pays__c, Account_Type__c
            FROM Order
            WHERE Id = :orderId
        ];

        return [
            SELECT Id,
                   Prix__c,
                   Delai__c,
                   Transporteur__r.Name
            FROM TarifLivraison__c
            WHERE Pays__c = :ord.Pays__c
            AND TypeClient__c = :ord.Account_Type__c
        ];
    }
}