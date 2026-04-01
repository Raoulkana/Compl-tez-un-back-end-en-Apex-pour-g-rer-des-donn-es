@IsTest
public class OrderServiceTest {

    @TestSetup
    static void setupData() {
        // Créer un compte pour les commandes
        Account acc = new Account(Name='Test Account');
        insert acc;

        // Commande activée avec un item
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated',
            ShippingCountry = 'United States'
        );
        insert ord;

        // Item de commande
        Product2 prod = new Product2(Name='Produit Test', IsActive=true);
        insert prod;

        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            Quantity = 2,
            UnitPrice = 50,
            PricebookEntryId = Test.getStandardPricebookId() != null ?
                               [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId() AND Product2Id = :prod.Id LIMIT 1].Id :
                               null
        );
        insert oi;

        // Commande non activée
        Order ordInactive = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            ShippingCountry = 'United States'
        );
        insert ordInactive;

        // Commande activée mais sans items
        Order ordEmpty = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated',
            ShippingCountry = 'United States'
        );
        insert ordEmpty;
    }

    @IsTest
    static void testValidateOrderSuccess() {
        Order ord = [SELECT Id FROM Order WHERE Status='Activated' LIMIT 1];

        Test.startTest();
        // Ne doit pas lever d'exception
        OrderService.validateOrder(ord);
        Test.stopTest();
    }

    @IsTest
    static void testValidateOrderNotActivated() {
        Order ord = [SELECT Id FROM Order WHERE Status='Draft' LIMIT 1];

        Test.startTest();
        try {
            OrderService.validateOrder(ord);
            System.assert(false, 'Une exception doit être levée pour une commande non activée');
        } catch (AuraHandledException e) {
            System.assertEquals('Commande non activée', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testValidateOrderEmpty() {
        Order ord = [SELECT Id FROM Order WHERE Status='Activated' 
                     AND Id NOT IN (SELECT OrderId FROM OrderItem) LIMIT 1];

        Test.startTest();
        try {
            OrderService.validateOrder(ord);
            System.assert(false, 'Une exception doit être levée pour une commande vide');
        } catch (AuraHandledException e) {
            System.assertEquals('Commande vide', e.getMessage());
        }
        Test.stopTest();
    }
}