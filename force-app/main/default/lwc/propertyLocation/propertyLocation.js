import { LightningElement, wire, api } from 'lwc';
import { getLocationService } from 'lightning/mobileCapabilities';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Using hardcoded fields due to LWC bug
const LATITUDE_FIELD = 'Property__c.Location__Latitude__s';
const LONGITUDE_FIELD = 'Property__c.Location__Longitude__s';

const fields = [LATITUDE_FIELD, LONGITUDE_FIELD];

export default class PropertyLocation extends LightningElement {
    error;
    myDeviceLocationService;
    myLocation;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredProperty({ data, error }) {
        if (data) {
            this.property = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.property = undefined;
        }
    }

    async connectedCallback() {
        this.myDeviceLocationService = getLocationService();
        if (this.myDeviceLocationService.isAvailable()) {
            // Running on the Salesforce mobile app on a device
            await this.calculateLocationFromMobileDevice();
        } else if (navigator.geolocation) {
            // Running on a browser
            this.calculateLocationFromBrowser();
        } else {
            this.error = 'No location services available';
        }
    }

    async calculateLocationFromMobileDevice() {
        try {
            //this.myLocation =
            const result =
                await this.myDeviceLocationService.getCurrentPosition();
            this.myLocation = result.coords;
        } catch (error) {
            this.error = error;
        }
    }

    calculateLocationFromBrowser() {
        navigator.geolocation.getCurrentPosition(
            (result) => {
                this.myLocation = result.coords;
            },
            (error) => {
                this.error = error;
            }
        );
    }

    get distance() {
        if (this.myLocation && this.property) {
            const latitude1 = this.myLocation.latitude;
            const latitude2 = getFieldValue(this.property, LATITUDE_FIELD);
            const longitude1 = this.myLocation.longitude;
            const longitude2 = getFieldValue(this.property, LONGITUDE_FIELD);
            return this.calculateDistance(
                latitude1,
                latitude2,
                longitude1,
                longitude2
            );
        }
        return false;
    }

    calculateDistance(latitude1, latitude2, longitude1, longitude2) {
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
        return d / 1.609344;
    }
}
