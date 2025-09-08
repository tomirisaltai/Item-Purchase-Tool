@IsTest
public class TestDataFactory {

    public static Account makeAccount() {
        Account a = new Account(Name = 'Acme Corp');
        insert a;
        return a;
    }

    public static Item__c makeItem(String name, String family, String type, Decimal price, String descriptionText) {
        Item__c i = new Item__c(
            Name = name,
            Family__c = family,
            Type__c = type,
            Price__c = price,
            Description__c = descriptionText
        );
        insert i;
        return i;
    }

    public static List<Item__c> seedItemsForSearch() {
        List<Item__c> items = new List<Item__c>{
            new Item__c(Name='ZenBook 14',    Family__c='Laptops',    Type__c='Standard', Price__c=999,  Description__c='lightweight long battery'),
            new Item__c(Name='ProBook X',     Family__c='Laptops',    Type__c='Pro',      Price__c=1499, Description__c='high performance pro workstation'),
            new Item__c(Name='NovaPhone S',   Family__c='Phones',     Type__c='Standard', Price__c=699,  Description__c='affordable phone excellent camera'),
            new Item__c(Name='NovaPhone Pro', Family__c='Phones',     Type__c='Pro',      Price__c=999,  Description__c='premium smartphone titanium body'),
            new Item__c(Name='SoundMax 200',  Family__c='Headphones', Type__c='Standard', Price__c=199,  Description__c='wireless headphones comfy'),
            new Item__c(Name='SoundMax Pro',  Family__c='Headphones', Type__c='Pro',      Price__c=349,  Description__c='noise cancelling premium sound')
        };
        insert items;
        return items;
    }
}
