/*
    Count por status de propiedades
*/
List<Broker__c> brokers = [Select Id, name From Broker__c];

System.debug(brokers.size());


