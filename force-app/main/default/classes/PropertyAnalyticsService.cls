public with sharing class PropertyAnalyticsService {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMarketTrends() {
        return new Map<String, Object>{
            'averagePrice' => 850000,
            'totalActive' => 42
        };
    }
}
