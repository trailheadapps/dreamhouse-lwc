import { LightningElement, wire } from 'lwc';
import {
    publish,
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Address', fieldName: 'Address__c' },
    { label: 'City', fieldName: 'City__c' },
    { label: 'State', fieldName: 'State__c' },
    { label: 'Price', fieldName: 'Price__c' },
    { label: 'No of Beds', fieldName: 'Beds__c' },
    { label: 'No of Baths', fieldName: 'Baths__c' }
];

const pageSize = 10;

export default class PropertyListDataTable extends LightningElement {
    pageNumber = 1;
    columns = columns;
    searchKey = '';
    maxPrice = 9999999;
    minBedrooms = 0;
    minBathrooms = 0;
    after;

    @wire(MessageContext)
    messageContext;

    @wire(graphql, {
        query: gql`
            query paginatedProperties(
                $after: String
                $pageSize: Int!
                $maxPrice: Currency!
                $minBedrooms: Double
                $minBathrooms: Double
                $searchKey: String
            ) {
                uiapi {
                    query {
                        Property__c(
                            where: {
                                and: [
                                    {
                                        or: [
                                            { Name: { like: $searchKey } },
                                            { City__c: { like: $searchKey } }
                                        ]
                                    },
                                    { Price__c: { lte: $maxPrice } },
                                    { Beds__c: { gte: $minBedrooms } },
                                    { Baths__c: { gte: $minBathrooms } }
                                ]
                            }
                            first: $pageSize
                            after: $after
                            orderBy: { Price__c: { order: ASC } }
                        ) {
                            edges {
                                node {
                                    Id
                                    Name {
                                        value
                                    }
                                    Address__c {
                                        value
                                    }
                                    City__c {
                                        value
                                    }
                                    State__c {
                                        value
                                    }
                                    Description__c {
                                        value
                                    }
                                    Price__c {
                                        value
                                    }
                                    Baths__c {
                                        value
                                    }
                                    Beds__c {
                                        value
                                    }
                                    Thumbnail__c {
                                        value
                                    }
                                }
                            }
                            pageInfo {
                                endCursor
                                hasNextPage
                                hasPreviousPage
                            }
                            # Requesting totalCount can have performance implications
                            # for large and/or complex queries. Use with caution.
                            totalCount
                        }
                    }
                }
            }
        `,
        variables: '$variables'
    })
    graphqlResponse;

    get variables() {
        return {
            after: this.after || null,
            pageSize,
            maxPrice: this.maxPrice || 999999,
            minBedrooms: this.minBedrooms || 0,
            minBathrooms: this.minBathrooms || 0,
            searchKey: '%' + this.searchKey + '%',

        };
    }

    get data() {
        return this.graphqlResponse.data?.uiapi.query.Property__c.edges.map(
            (edge) => ({
                Id: edge.node.Id,
                Name: edge.node.Name.value,
                City__c: edge.node.City__c.value,
                State__c: edge.node.State__c.value,
                Price__c: edge.node.State__c.value,
                Beds__c: edge.node.Beds__c.value,
                Baths__c: edge.node.Beds__c.value
            })
        );
    }

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            FILTERSCHANGEMC,
            (message) => {
                this.handleFilterChange(message);
            }
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleFilterChange(filters) {
        console.log(filters);
        this.searchKey = filters.searchKey;
        this.maxPrice = filters.maxPrice;
        this.minBedrooms = filters.minBedrooms;
        this.minBathrooms = filters.minBathrooms;
    }

    handlePropertySelected(event) {
        const message = { propertyId: event.detail };
        publish(this.messageContext, PROPERTYSELECTEDMC, message);
    }

    get currentPageNumber() {
        return this.totalCount === 0 ? 0 : this.pageNumber;
    }

    get isFirstPage() {
        return !this.graphqlResponse.data?.uiapi.query.Property__c.pageInfo
            .hasPreviousPage;
    }

    get isLastPage() {
        return !this.graphqlResponse.data?.uiapi.query.Property__c.pageInfo
            .hasNextPage;
    }

    get totalCount() {
        return (
            this.graphqlResponse.data?.uiapi.query.Property__c.totalCount || 0
        );
    }

    get totalPages() {
        return Math.ceil(this.totalCount / pageSize);
    }

    handleNext() {
        if (
            this.graphqlResponse.data?.uiapi.query.Property__c.pageInfo
                .hasNextPage
        ) {
            this.after =
                this.graphqlResponse.data?.uiapi.query.Property__c.pageInfo.endCursor;
            this.pageNumber++;
        }
    }

    handleReset() {
        this.after = null;
        this.pageNumber = 1;
    }
}