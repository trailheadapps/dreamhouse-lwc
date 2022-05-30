import { LightningElement, wire, api } from 'lwc';
import { getLocationService } from 'lightning/mobileCapabilities';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Using hardcoded fields due to LWC bug
const LATITUDE_FIELD = 'Property__c.Location__Latitude__s';
const LONGITUDE_FIELD = 'Property__c.Location__Longitude__s';

const fields = [LATITUDE_FIELD, LONGITUDE_FIELD];

export default class PropertyLocation extends LightningElement {
    error;
    deviceLocationService;
    distance;
    location;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredProperty({ data, error }) {
        if (data) {
            this.property = data;
            this.error = undefined;
            this.calculateDistance();
        } else if (error) {
            this.error = error;
            this.property = undefined;
        }
    }

    async connectedCallback() {
        this.deviceLocationService = getLocationService();
        if (this.deviceLocationService.isAvailable()) {
            // Running on the Salesforce mobile app on a device
            await this.calculateLocationFromMobileDevice();
        } else if (navigator.geolocation) {
            // Running on a browser
            this.calculateLocationFromBrowser();
        } else {
            this.error = { message: 'No location services available' };
        }
    }

    async calculateLocationFromMobileDevice() {
        try {
            this.location =
                await this.deviceLocationService.getCurrentPosition();
            this.calculateDistance();
        } catch (error) {
            this.error = error;
        }
    }

    calculateLocationFromBrowser() {
        navigator.geolocation.getCurrentPosition(
            (result) => {
                this.location = result.coords;
                this.calculateDistance();
            },
            (error) => {
                this.error = error;
            }
        );
    }

    calculateDistance() {
        if (this.location && this.property) {
            const latitude1 = this.location.latitude;
            const latitude2 = getFieldValue(this.property, LATITUDE_FIELD);
            const longitude1 = this.location.longitude;
            const longitude2 = getFieldValue(this.property, LONGITUDE_FIELD);

            // Haversine formula
            const deg2rad = (deg) => (deg * Math.PI) / 180.0;
            const earthRadius = 6371; // Radius of the earth in km
            const dLat = deg2rad(latitude2 - latitude1); // deg2rad below
            const dLon = deg2rad(longitude2 - longitude1);
            const a =
                Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(deg2rad(latitude1)) *
                    Math.cos(deg2rad(latitude2)) *
                    Math.sin(dLon / 2) *
                    Math.sin(dLon / 2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            const d = earthRadius * c;
            this.distance = d / 1.609344;
        }
    }
}
