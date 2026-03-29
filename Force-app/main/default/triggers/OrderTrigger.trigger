trigger OrderTrigger on Order (before insert, before update) {

    if (Trigger.isBefore) {
        OrderTriggerHandler.handle(Trigger.new);
    }
}