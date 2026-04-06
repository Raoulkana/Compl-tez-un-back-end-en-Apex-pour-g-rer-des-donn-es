@IsTest
public class DeliveryOrderServiceTest {

    @TestSetup
    static void setupData() {
        // --- Création compte ---
        Account acc = new Account(Name='Test Account', Type='Particulier');
        insert acc;

        // --- Pricebook standard ---
        Id pbId = Test.getStandardPricebookId();

        // --- Produit actif ---
        Product2 prod = new Product2(Name='Produit Test', IsActive=true);
        insert prod;

        // --- PricebookEntry ---
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // --- Commande ---
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated',
            Pricebook2Id = pbId,
            ShippingCountry = 'United States'
        );
        insert ord;

        // --- OrderItem ---
        OrderItem item = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert item;

        // --- Transporteur ---
        Transporteur__c t = new Transporteur__c(Name='Chronopost', TypeClient__c='Particulier');
        insert t;

        // --- Tarif livraison ---
        TarifLivraison__c tarif = new TarifLivraison__c(
            Transporteur__c = t.Id,
            Pays__c = 'United States',
            Prix__c = 10,
            Delai__c = 3
        );
        insert tarif;
    }

    @IsTest
    static void testCreateAndGetLivraison() {
        // Récupération commande de test
        Order ord = [SELECT Id FROM Order WHERE Status='Activated' LIMIT 1];
        TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        Map<Id, Id> selectedTarif = new Map<Id, Id>{ ord.Id => tarif.Id };

        Test.startTest();
        // --- Création livraison ---
        Map<Id, Id> result = DeliveryOrderService.createByOrderIds(
            new List<Id>{ord.Id},
            selectedTarif
        );
        Test.stopTest();

        System.assertNotEquals(null, result.get(ord.Id), 'Livraison non créée');

        // --- Vérification récupération ---
        Map<Id, List<Livraison__c>> livMap = DeliveryOrderService.getByOrderIds(new List<Id>{ord.Id});
        System.assertEquals(1, livMap.get(ord.Id).size(), 'Livraison non trouvée');

        // --- Mise à jour ---
        Livraison__c liv = livMap.get(ord.Id)[0];
        Test.startTest();
        DeliveryOrderService.updateByIds(
            new List<Id>{liv.Id},
            new Map<Id, Id>{ liv.Id => tarif.Id }
        );
        Test.stopTest();

        // Vérifier que le tarif est toujours correct après mise à jour
        Livraison__c updatedLiv = [SELECT Id, Tarif__c FROM Livraison__c WHERE Id=:liv.Id];
        System.assertEquals(tarif.Id, updatedLiv.Tarif__c, 'Le Tarif de la livraison n’a pas été mis à jour correctement');
    }
}