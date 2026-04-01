@IsTest
public class LivraisonManagerTest {

    @TestSetup
    static void setupData() {
        // Compte valide
        Account acc = new Account(Name='Test Account', Type='Customer');
        insert acc;

        // Commande valide
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated',
            ShippingCountry = 'United States' // Pays valide
        );
        insert ord;

        // Transporteur
        Transporteur__c t = new Transporteur__c(Name='Chronopost', TypeClient__c='Customer');
        insert t;

        // Tarif pour test getBestTransporteur
        TarifLivraison__c tarif = new TarifLivraison__c(
            Transporteur__c = t.Id,
            Pays__c = 'United States',
            Prix__c = 10,
            Delai__c = 3
        );
        insert tarif;
    }

    @IsTest
    static void testCreateLivraison() {
        Order ord = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        Livraison__c liv = LivraisonManager.createLivraison(ord.Id);
        Test.stopTest();

        System.assertNotEquals(null, liv.Id);
        System.assertEquals(ord.Id, liv.Order__c);
        System.assertEquals('En préparation', liv.Statut__c);
        System.assertEquals(System.today(), liv.DateExpedition__c);
        System.assertEquals(System.today().addDays(3), liv.DateLivraisonEstimee__c);
        System.assertNotEquals(null, liv.Transporteur__c);
    }
}