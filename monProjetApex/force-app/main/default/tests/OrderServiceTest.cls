@IsTest
public class OrderServiceTest {

    @TestSetup
    static void setupData() {

        Account acc = new Account(Name='Test Account', Type='Particulier');
        insert acc;

        Id pbId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name='Produit Test', IsActive=true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pbId,
            ShippingCountry = 'United States'
        );
        insert ord;

        OrderItem item = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert item;

        ord.Status = 'Activated';
        update ord;
    }

    // ✅ Test commande valide
    @IsTest
    static void testValidateOrderSuccess() {

        Order ord = [
            SELECT Id, Status
            FROM Order
            WHERE Status='Activated'
            LIMIT 1
        ];

        Test.startTest();
        OrderService.validateOrder(ord);
        Test.stopTest();
    }
    

    // ✅ Test commande non activée
 @IsTest
static void testValidateOrderNotActivated() {

    Account acc = new Account(Name='Temp Account');
    insert acc;

    Id pbId = Test.getStandardPricebookId();

    Order ord = new Order(
        AccountId = acc.Id,
        EffectiveDate = Date.today(),
        Status = 'Draft',
        Pricebook2Id = pbId,
        ShippingCountry = 'United States'
    );
    insert ord;

    // Recharger la commande depuis la base
    ord = [SELECT Id, Status FROM Order WHERE Id = :ord.Id];

    Test.startTest();

    Boolean exceptionThrown = false;

    try {

        OrderService.validateOrder(ord);

    } catch (Exception e) {

        exceptionThrown = true;

    }

    Test.stopTest();

    System.assertEquals(true, exceptionThrown, 'Une exception devait être levée pour une commande non activée');

}

}