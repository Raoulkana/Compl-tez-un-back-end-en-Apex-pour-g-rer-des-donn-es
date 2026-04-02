public with sharing class TransporterSelector {

    public static List<TarifLivraison__c> getTarifsByPaysAndClientType(
        String pays,
        String typeClient
    ){

        return [
            SELECT Id,
                   Prix__c,
                   Delai__c,
                   Pays__c,
                   TypeClient__c,
                   Transporteur__r.Name
            FROM TarifLivraison__c
            WHERE Pays__c = :pays
            AND TypeClient__c = :typeClient
        ];
    }

}