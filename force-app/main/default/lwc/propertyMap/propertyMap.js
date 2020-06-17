import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import {
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';

const fields = [
    'Property__c.Address__c',
    'Property__c.City__c',
    'Property__c.Location__Latitude__s',
    'Property__c.Location__Longitude__s'
];

export default class PropertyMap extends LightningElement {
    address;
    error;
    markers = [];
    propertyId;
    subscription = null;
    zoomLevel = 14;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$propertyId', fields })
    wiredRecord({ error, data }) {
        if (data) {
            this.error = undefined;
            const property = data.fields;
            this.address = `${property.Address__c.value}, ${property.City__c.value}`;
            this.markers = [
                {
                    location: {
                        Latitude: property.Location__Latitude__s.value,
                        Longitude: property.Location__Longitude__s.value
                    },
                    title: `${property.Address__c.value}`
                }
            ];
        } else if (error) {
            this.error = error;
            this.address = undefined;
            this.markers = [];
        }
    }

    @api
    get recordId() {
        return this.propertyId;
    }

    set recordId(propertyId) {
        this.propertyId = propertyId;
    }

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            PROPERTYSELECTEDMC,
            (message) => {
                this.handlePropertySelected(message);
            }
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handlePropertySelected(message) {
        this.propertyId = message.propertyId;
    }
}
