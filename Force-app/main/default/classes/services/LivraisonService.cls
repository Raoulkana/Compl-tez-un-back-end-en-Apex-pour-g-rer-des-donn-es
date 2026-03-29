public with sharing class LivraisonService {

    public static Transporteur__c getBestTransporteur(String pays, String typeClient) {

        List<TarifLivraison__c> tarifs = [
            SELECT Prix__c, Delai__c,
                   Transporteur__r.TypeClient__c,
                   Transporteur__r.Id
            FROM TarifLivraison__c
            WHERE Pays__c = :pays
            AND Transporteur__r.TypeClient__c = :typeClient
        ];

        TarifLivraison__c best;

        for (TarifLivraison__c t : tarifs) {
            if (best == null || t.Prix__c < best.Prix__c) {
                best = t;
            }
        }

        return best != null ? best.Transporteur__r : null;
    }
}