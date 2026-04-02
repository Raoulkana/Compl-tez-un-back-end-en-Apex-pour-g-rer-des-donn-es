public with sharing class LivraisonService {

    @AuraEnabled(cacheable=true)
    public static Transporteur__c getBestTransporteur(String pays, String typeClient) {

        List<TarifLivraison__c> tarifs = [
            SELECT Prix__c,
                   Delai__c,
                   Transporteur__c,
                   Transporteur__r.Id,
                   Transporteur__r.Name,
                   Transporteur__r.TypeClient__c
            FROM TarifLivraison__c
            WHERE Pays__c = :pays
            AND Transporteur__r.TypeClient__c = :typeClient
            ORDER BY Prix__c ASC
            LIMIT 1
        ];

        if (!tarifs.isEmpty()) {
            return tarifs[0].Transporteur__r;
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<TarifLivraison__c> getTarifs(String pays, String typeClient){

        return [
            SELECT Id,
                   Prix__c,
                   Delai__c,
                   Transporteur__c,
                   Transporteur__r.Id,
                   Transporteur__r.Name,
                   Transporteur__r.TypeClient__c
            FROM TarifLivraison__c
            WHERE Pays__c = :pays
            AND Transporteur__r.TypeClient__c = :typeClient
            ORDER BY Prix__c ASC
        ];
    }
}