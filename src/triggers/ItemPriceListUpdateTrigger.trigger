/**
 * Trigger to update the Item Price list records with Prev qty ordered for a given Product on
 * an Outlet.
 */

trigger ItemPriceListUpdateTrigger on M_Order_sigcap_Header__c (after update) 
{
    
    // Get the list of all Orders which needs to be worked upon.
    List<M_Order_sigcap_Header__c> updOrdersList = trigger.new;

    ItemPriceListUpdateHandler.updateItemPriceListRecords(updOrdersList);
    
}