@IsTest
public class DeliveryOrderServiceTest {

    private static final String DEFAULT_STATUT = 'En préparation';

    @TestSetup
    static void setupData() {

        // ---------- Account ----------
        Account acc = new Account(
            Name = 'Test Account',
            Type = 'Particulier'
        );
        insert acc;

        // ---------- Standard Pricebook ----------
        Id pbId = Test.getStandardPricebookId();

        // ---------- Product ----------
        Product2 prod = new Product2(
            Name = 'Produit Test',
            IsActive = true
        );
        insert prod;

        // ---------- PricebookEntry ----------
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // ---------- Order ----------
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pbId,
            Pays__c = 'United States'
        );
        insert ord;

        // ---------- OrderItem ----------
        OrderItem item = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert item;

        // ---------- Transporteur ----------
        Transporteur__c transporteur = new Transporteur__c(
            Name = 'Chronopost',
            TypeClient__c = 'Particulier'
        );
        insert transporteur;

        // ---------- Tarif Livraison ----------
        TarifLivraison__c tarif = new TarifLivraison__c(
            Name = 'Tarif Standard',
            Transporteur__c = transporteur.Id,
            Pays__c = 'United States',
            Prix__c = 10,
            Delai__c = 3
        );
        insert tarif;
    }

    // =============================
    // TEST createByOrderIds
    // =============================
    @IsTest
    static void testCreateByOrderIds() {

        Order ord = [SELECT Id FROM Order LIMIT 1];
        TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        Map<Id, Id> selectedTarif = new Map<Id, Id>{
            ord.Id => tarif.Id
        };

        Test.startTest();
        Map<Id, Id> result = DeliveryOrderService.createByOrderIds(
            new List<Id>{ord.Id}, selectedTarif
        );
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Une livraison doit être créée');

        Id livId = result.get(ord.Id);
        Livraison__c liv = [
            SELECT Id, Order__c, Tarif__c, Statut__c
            FROM Livraison__c
            WHERE Id = :livId
        ];

        System.assertEquals(ord.Id, liv.Order__c);
        System.assertEquals(tarif.Id, liv.Tarif__c);
        System.assertEquals(DEFAULT_STATUT, liv.Statut__c, 'Statut incorrect');
    }

    // =============================
    // TEST getByOrderIds
    // =============================
    @IsTest
    static void testGetByOrderIds() {

        Order ord = [SELECT Id FROM Order LIMIT 1];
        TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        Livraison__c liv = new Livraison__c(
            Order__c = ord.Id,
            Tarif__c = tarif.Id,
            Statut__c = DEFAULT_STATUT
        );
        insert liv;

        Test.startTest();
        Map<Id, List<Livraison__c>> result = DeliveryOrderService.getByOrderIds(
            new List<Id>{ord.Id}
        );
        Test.stopTest();

        System.assert(result.containsKey(ord.Id), 'La commande doit exister dans la map');
        List<Livraison__c> livraisons = result.get(ord.Id);
        System.assertEquals(1, livraisons.size(), 'Une livraison attendue');
        System.assertEquals(ord.Id, livraisons[0].Order__c);
        System.assertEquals(DEFAULT_STATUT, livraisons[0].Statut__c, 'Statut incorrect');
    }

    // =============================
    // TEST updateByIds
    // =============================
    @IsTest
    static void testUpdateByIds() {

        Order ord = [SELECT Id FROM Order LIMIT 1];
        Transporteur__c transporteur = [SELECT Id FROM Transporteur__c LIMIT 1];
        TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        Livraison__c liv = new Livraison__c(
            Order__c = ord.Id,
            Tarif__c = tarif.Id,
            Statut__c = DEFAULT_STATUT
        );
        insert liv;

        // Nouveau tarif
        TarifLivraison__c newTarif = new TarifLivraison__c(
            Name = 'Tarif Express',
            Transporteur__c = transporteur.Id,
            Pays__c = 'United States',
            Prix__c = 20,
            Delai__c = 1
        );
        insert newTarif;

        Map<Id, Id> newTarifMap = new Map<Id, Id>{ liv.Id => newTarif.Id };

        Test.startTest();
        DeliveryOrderService.updateByIds(new List<Id>{liv.Id}, newTarifMap);
        Test.stopTest();

        Livraison__c updated = [SELECT Tarif__c FROM Livraison__c WHERE Id = :liv.Id];
        System.assertEquals(newTarif.Id, updated.Tarif__c, 'Le tarif doit être mis à jour');
    }

}