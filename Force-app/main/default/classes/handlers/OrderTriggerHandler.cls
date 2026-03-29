public with sharing class OrderTriggerHandler {

    public static void handle(List<Order> orders) {

        for (Order ord : orders) {

            if (ord.AccountId == null) continue;

            // Exemple simple
            if (ord.Status == 'Activated') {
                // logique possible
            }
        }
    }
}