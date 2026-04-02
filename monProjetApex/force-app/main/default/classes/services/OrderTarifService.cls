public with sharing class OrderTarifService {

    @AuraEnabled(cacheable=true)
    public static List<TarifLivraison__c> getByOrderIds(Id orderId){

        Order ord = [
            SELECT Id, Pays__c, Account_Type__c
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        return TransporterSelector.getTarifsByPaysAndClientType(
            ord.Pays__c,
            ord.Account_Type__c
        );
    }

}