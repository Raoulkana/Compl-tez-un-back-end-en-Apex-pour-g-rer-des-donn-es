public with sharing class LivraisonService {

    public static Transporteur__c getBestTransporteur(String pays, String typeClient) {

        // Requête SOQL corrigée : on récupère le champ Name du Transporteur
        List<TarifLivraison__c> tarifs = [
            SELECT Prix__c,
                   Delai__c,
                   Transporteur__r.Id,
                   Transporteur__r.Name,
                   Transporteur__r.TypeClient__c
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

        // Retourne le transporteur trouvé ou null si aucun tarif ne correspond
        if (best != null) {
            return best.Transporteur__r;
        }

        return null;
    }
}