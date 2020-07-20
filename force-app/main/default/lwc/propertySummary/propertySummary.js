import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import {
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';
import NAME_FIELD from '@salesforce/schema/Property__c.Name';
import BED_FIELD from '@salesforce/schema/Property__c.Beds__c';
import BATH_FIELD from '@salesforce/schema/Property__c.Baths__c';
import PRICE_FIELD from '@salesforce/schema/Property__c.Price__c';
import BROKER_FIELD from '@salesforce/schema/Property__c.Broker__c';
import PICTURE_FIELD from '@salesforce/schema/Property__c.Picture__c';

export default class PropertySummary extends NavigationMixin(LightningElement) {
    propertyId;
    propertyFields = [BED_FIELD, BATH_FIELD, PRICE_FIELD, BROKER_FIELD];
    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, {
        recordId: '$propertyId',
        fields: [NAME_FIELD, PICTURE_FIELD]
    })
    property;

    @api
    get recordId() {
        return this.propertyId;
    }

    set recordId(propertyId) {
        this.propertyId = propertyId;
    }

    get propertyName() {
        return getFieldValue(this.property.data, NAME_FIELD);
    }

    get pictureURL() {
        return getFieldValue(this.property.data, PICTURE_FIELD);
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

    handleNavigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.propertyId,
                objectApiName: 'Property__c',
                actionName: 'view'
            }
        });
    }
}
