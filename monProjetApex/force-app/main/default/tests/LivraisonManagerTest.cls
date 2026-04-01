@IsTest
public class LivraisonManagerTest {

    @TestSetup
    static void setupData() {
        // Compte
        Account acc = new Account(Name='Test Account', Type='Particulier');
        insert acc;

        // Pricebook standard
        Id pbId = Test.getStandardPricebookId();

        // Produit actif
        Product2 prod = new Product2(Name='Produit Test', IsActive=true);
        insert prod;

        // PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Commande
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pbId,
            ShippingCountry = 'United States'
        );
        insert ord;

        // OrderItem pour permettre activation
        OrderItem item = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert item;

        // Activation commande
        ord.Status = 'Activated';
        update ord;

        // Transporteur avec picklist valide
        Transporteur__c t = new Transporteur__c(Name='Chronopost', TypeClient__c='Particulier');
        insert t;

        // Tarif livraison
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
        Order ord = [SELECT Id, Status, ShippingCountry, Account.Type FROM Order WHERE Status='Activated' LIMIT 1];

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