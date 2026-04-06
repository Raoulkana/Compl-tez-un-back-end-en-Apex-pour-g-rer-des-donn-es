@IsTest
public class TarifLivraisonServiceTest {

    @TestSetup
    static void setupData() {
        // Créer un compte test
        Account acc = new Account(
            Name = 'Test Account', 
            Type = 'Particulier'
        );
        insert acc;

        // Récupérer le pricebook standard
        Id pbId = Test.getStandardPricebookId();

        // Créer un produit actif
        Product2 prod = new Product2(
            Name = 'Produit Test', 
            IsActive = true
        );
        insert prod;

        // Créer une PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Créer une commande test
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated',
            Pricebook2Id = pbId,
            ShippingCountry = 'France',
            Account_Type__c = 'Particulier' // champ personnalisé utilisé dans la classe
        );
        insert ord;

        // Créer un transporteur
        Transporteur__c t = new Transporteur__c(
            Name = 'Chronopost', 
            TypeClient__c = 'Particulier'
        );
        insert t;

        // Créer un tarif de livraison
        TarifLivraison__c tarif = new TarifLivraison__c(
            Transporteur__c = t.Id,
            Pays__c = 'France',
            Prix__c = 10,
            Delai__c = 3,
            TypeClient__c = 'Particulier'
        );
        insert tarif;
    }

    @IsTest
    static void testGetTarifLivraison() {
        // Récupérer une commande de test
        Order ord = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        // Appel à la méthode exacte
        List<TarifLivraison__c> tarifs = TarifLivraisonService.getTarifLivraison(ord.Id);
        Test.stopTest();

        // Vérifications
        System.assert(!tarifs.isEmpty(), 'La liste de tarifs ne doit pas être vide');
        System.assertEquals('France', tarifs[0].Pays__c, 'Le pays doit correspondre');
        System.assertEquals('Particulier', tarifs[0].TypeClient__c, 'Le type client doit correspondre');
        System.assertNotEquals(null, tarifs[0].Transporteur__r.Id, 'Le transporteur doit être présent');
    }
}