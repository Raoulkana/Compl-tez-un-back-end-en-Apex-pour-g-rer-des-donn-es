@IsTest
public class LivraisonServiceTest {

    @TestSetup
    static void setupData() {
        // Transporteurs
        Transporteur__c t1 = new Transporteur__c(Name='Chronopost', TypeClient__c='Particulier');
        Transporteur__c t2 = new Transporteur__c(Name='DHL', TypeClient__c='Particulier');
        insert new List<Transporteur__c>{t1, t2};

        // Tarifs pour France
        TarifLivraison__c tarif1 = new TarifLivraison__c(
            Transporteur__c = t1.Id,
            Pays__c = 'United States',
            Prix__c = 15,
            Delai__c = 2
        );
        TarifLivraison__c tarif2 = new TarifLivraison__c(
            Transporteur__c = t2.Id,
            Pays__c = 'United States',
            Prix__c = 10,
            Delai__c = 3
        );
        insert new List<TarifLivraison__c>{tarif1, tarif2};
    }

    @IsTest
    static void testGetBestTransporteur() {
        Test.startTest();
        Transporteur__c best = LivraisonService.getBestTransporteur('United States', 'Particulier');
        Test.stopTest();

        System.assertNotEquals(null, best);
        System.assertEquals('DHL', best.Name);
    }

    @IsTest
    static void testGetBestTransporteurNoMatch() {
        Test.startTest();
        Transporteur__c best = LivraisonService.getBestTransporteur('Allemagne', 'Professionnel');
        Test.stopTest();

        System.assertEquals(null, best);
    }
}