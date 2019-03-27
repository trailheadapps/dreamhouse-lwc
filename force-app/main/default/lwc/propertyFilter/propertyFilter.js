import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

const DELAY = 350;

export default class PropertyFilter extends LightningElement {
    // Set the price slider's max value via a parameter exposed in App Builder
    @api priceSliderMaxValue;

    @track searchKey = '';

    @track maxPrice = 0;

    @track minBedrooms = 0;

    @track minBathrooms = 0;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        // Set the price slider to its max value
        this.maxPrice = this.priceSliderMaxValue;
    }

    handleReset() {
        this.searchKey = '';
        this.maxPrice = this.priceSliderMaxValue;
        this.minBedrooms = 0;
        this.minBathrooms = 0;
        this.fireChangeEvent();
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.detail.value;
        this.fireChangeEvent();
    }

    handleMaxPriceChange(event) {
        this.maxPrice = event.detail.value;
        this.fireChangeEvent();
    }

    handleMinBedroomsChange(event) {
        this.minBedrooms = event.detail.value;
        this.fireChangeEvent();
    }

    handleMinBathroomsChange(event) {
        this.minBathrooms = event.detail.value;
        this.fireChangeEvent();
    }

    fireChangeEvent() {
        // Debouncing this method: Do not actually fire the event as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex
        // method calls in components listening to this event.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            const filters = {
                searchKey: this.searchKey,
                maxPrice: this.maxPrice,
                minBedrooms: this.minBedrooms,
                minBathrooms: this.minBathrooms
            };
            fireEvent(this.pageRef, 'dreamhouse__filterChange', filters);
        }, DELAY);
    }
}
