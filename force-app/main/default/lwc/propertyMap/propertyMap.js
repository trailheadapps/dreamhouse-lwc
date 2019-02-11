import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import { registerListener, unregisterAllListeners } from 'c/pubsub';

const fields = [
    'Property__c.Address__c',
    'Property__c.City__c',
    'Property__c.Location__Latitude__s',
    'Property__c.Location__Longitude__s'
];

export default class PropertyMap extends LightningElement {
    @api recordId;

    @track address;

    @track zoomLevel = 14;

    @track markers = [];

    @track error;

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({ error, data }) {
        if (data) {
            this.error = undefined;
            const property = data.fields;
            this.address = `${property.Address__c.value}, ${
                property.City__c.value
            }`;
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

    connectedCallback() {
        registerListener(
            'dreamhouse__propertySelected',
            this.handlePropertySelected,
            this
        );
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handlePropertySelected(propertyId) {
        this.recordId = propertyId;
    }
}
