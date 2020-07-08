public with sharing class PropertyController {
    @AuraEnabled(cacheable=true)
    public static Property__c[] getPropertyList(
        String searchKey,
        Decimal maxPrice,
        Integer minBedrooms,
        Integer minBathrooms
    ) {
        String key = '%' + searchKey + '%';
        return [
            SELECT
                Id,
                address__c,
                city__c,
                state__c,
                description__c,
                price__c,
                baths__c,
                beds__c,
                thumbnail__c,
                location__latitude__s,
                location__longitude__s
            FROM property__c
            WHERE
                (title__c LIKE :key
                OR city__c LIKE :key
                OR tags__c LIKE :key)
                AND price__c <= :maxPrice
                AND beds__c >= :minBedrooms
                AND baths__c >= :minBathrooms
            WITH SECURITY_ENFORCED
            ORDER BY price__c
            LIMIT 100
        ];
    }

    @AuraEnabled(cacheable=true)
    public static PagedResult getPagedPropertyList(
        String searchKey,
        Decimal maxPrice,
        Integer minBedrooms,
        Integer minBathrooms,
        Integer pageSize,
        Integer pageNumber
    ) {
        maxPrice = Decimal.valueOf(maxPrice + '');
        minBedrooms = Integer.valueOf(minBedrooms + '');
        minBathrooms = Integer.valueOf(minBathrooms + '');
        pageSize = Integer.valueOf(pageSize + '');
        pageNumber = Integer.valueOf(pageNumber + '');

        Integer pSize = (Integer) pageSize;
        String key = '%' + searchKey + '%';
        Integer offset = ((Integer) pageNumber - 1) * pSize;
        PagedResult result = new PagedResult();
        result.pageSize = pSize;
        result.pageNumber = (Integer) pageNumber;
        result.totalItemCount = [
            SELECT COUNT()
            FROM property__c
            WHERE
                (title__c LIKE :key
                OR city__c LIKE :key
                OR tags__c LIKE :key)
                AND price__c <= :maxPrice
                AND beds__c >= :minBedrooms
                AND baths__c >= :minBathrooms
        ];
        result.records = [
            SELECT
                Id,
                address__c,
                city__c,
                state__c,
                description__c,
                price__c,
                baths__c,
                beds__c,
                thumbnail__c
            FROM property__c
            WHERE
                (title__c LIKE :key
                OR city__c LIKE :key
                OR tags__c LIKE :key)
                AND price__c <= :maxPrice
                AND beds__c >= :minBedrooms
                AND baths__c >= :minBathrooms
            WITH SECURITY_ENFORCED
            ORDER BY price__c
            LIMIT :pSize
            OFFSET :offset
        ];
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getPictures(Id propertyId) {
        List<ContentDocumentLink> links = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE
                LinkedEntityId = :propertyId
                AND ContentDocument.FileType IN ('PNG', 'JPG', 'GIF')
            WITH SECURITY_ENFORCED
        ];

        if (links.isEmpty()) {
            return null;
        }

        Set<Id> contentIds = new Set<Id>();

        for (ContentDocumentLink link : links) {
            contentIds.add(link.ContentDocumentId);
        }

        return [
            SELECT Id, Title
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentIds AND IsLatest = TRUE
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate
        ];
    }
}
