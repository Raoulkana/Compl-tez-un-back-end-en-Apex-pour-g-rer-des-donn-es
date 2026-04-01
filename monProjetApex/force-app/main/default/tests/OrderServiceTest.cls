@IsTest
public class OrderServiceTest {

    @TestSetup
    static void setupData() {
        // Compte
        Account acc = new Account(Name='Test Account', Type='Customer');
        insert acc;

        // Pricebook standard
        Id pbId = Test.getStandardPricebookId();

        // Produit actif
        Product2 prod = new Product2(Name='Produit Test', IsActive=true);
        insert prod;

        // PricebookEntry
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=prod.Id, UnitPrice=100, IsActive=true);
        insert pbe;

        // Commande activable
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pbId,
            ShippingCountry = 'United States'
        );
        insert ord;

        // OrderItem
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
    }

    @IsTest
    static void testValidateOrderSuccess() {
        Order ord = [SELECT Id, Status FROM Order WHERE Status='Activated' LIMIT 1];
        Test.startTest();
        OrderService.validateOrder(ord);
        Test.stopTest();
    }

    @IsTest
    static void testValidateOrderNotActivated() {
        // Nouvelle commande Draft pour test
        Account acc = new Account(Name='Temp Account', Type='Customer');
        insert acc;

        Id pbId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name='Temp Prod', IsActive=true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=prod.Id, UnitPrice=100, IsActive=true);
        insert pbe;

        Order ord = new Order(AccountId=acc.Id, EffectiveDate=Date.today(), Status='Draft', Pricebook2Id=pbId, ShippingCountry='United States');
        insert ord;

        try {
            Test.startTest();
            OrderService.validateOrder(ord);
            Test.stopTest();
            System.assert(false, 'La commande non activée aurait dû générer une exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Commande non activée', e.getMessage());
        }
    }

    @IsTest
    static void testValidateOrderEmpty() {
        // Nouvelle commande activée sans OrderItem
        Account acc = new Account(Name='Temp Account 2', Type='Customer');
        insert acc;

        Id pbId = Test.getStandardPricebookId();
        Order ord = new Order(AccountId=acc.Id, EffectiveDate=Date.today(), Status='Draft', Pricebook2Id=pbId, ShippingCountry='United States');
        insert ord;

        // Activation sans produit
        ord.Status = 'Activated';
        update ord;

        try {
            Test.startTest();
            OrderService.validateOrder(ord);
            Test.stopTest();
            System.assert(false, 'Une commande vide aurait dû générer une exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Commande vide', e.getMessage());
        }
    }
}
