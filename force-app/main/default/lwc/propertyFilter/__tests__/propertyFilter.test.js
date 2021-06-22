import { createElement } from 'lwc';
import PropertyFilter from 'c/propertyFilter';
import { publish } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';

const MAX_PRICE = 1200000;

const DEFAULT_SEARCH_CRITERIA = {
    searchKey: '',
    maxPrice: MAX_PRICE,
    minBedrooms: 0,
    minBathrooms: 0
};

describe('c-property-filter', () => {
    beforeAll(() => {
        // We use fake timers as setTimeout is used in the JavaScript file.
        jest.useFakeTimers();
    });

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('fires the change event on new search input', async () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-input element
        const lightningInputEl =
            element.shadowRoot.querySelector('lightning-input');
        lightningInputEl.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 'Boston'
                }
            })
        );

        // Run all fake timers.
        jest.runAllTimers();

        const SEARCH_CRITERIA = {
            searchKey: 'Boston',
            maxPrice: MAX_PRICE,
            minBedrooms: 0,
            minBathrooms: 0
        };

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Was publish called and was it called with the correct params?
        expect(publish).toHaveBeenCalledWith(
            undefined,
            FILTERSCHANGEMC,
            SEARCH_CRITERIA
        );
    });

    it('fires the change event on Max Price slider input', async () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-input element
        const lightningSliderEl =
            element.shadowRoot.querySelector('lightning-slider');
        lightningSliderEl.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 60000
                }
            })
        );

        // Run all fake timers.
        jest.runAllTimers();

        const SEARCH_CRITERIA = {
            searchKey: '',
            maxPrice: 60000,
            minBedrooms: 0,
            minBathrooms: 0
        };

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Was publish called and was it called with the correct params?
        expect(publish).toHaveBeenCalledWith(
            undefined,
            FILTERSCHANGEMC,
            SEARCH_CRITERIA
        );
    });

    it('fires the change event on Bedrooms slider input', async () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-input element
        const lightningSliderEl =
            element.shadowRoot.querySelectorAll('lightning-slider')[1];
        lightningSliderEl.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 2
                }
            })
        );

        // Run all fake timers.
        jest.runAllTimers();

        const SEARCH_CRITERIA = {
            searchKey: '',
            maxPrice: MAX_PRICE,
            minBedrooms: 2,
            minBathrooms: 0
        };

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Was publish called and was it called with the correct params?
        expect(publish).toHaveBeenCalledWith(
            undefined,
            FILTERSCHANGEMC,
            SEARCH_CRITERIA
        );
    });

    it('fires the change event on Bathrooms slider input', async () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-input element
        const lightningSliderEl =
            element.shadowRoot.querySelectorAll('lightning-slider')[2];
        lightningSliderEl.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 2
                }
            })
        );

        // Run all fake timers.
        jest.runAllTimers();

        const SEARCH_CRITERIA = {
            searchKey: '',
            maxPrice: MAX_PRICE,
            minBedrooms: 0,
            minBathrooms: 2
        };

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Was publish called and was it called with the correct params?
        expect(publish).toHaveBeenCalledWith(
            undefined,
            FILTERSCHANGEMC,
            SEARCH_CRITERIA
        );
    });

    it('fires change event when reset button is clicked', async () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Click reset button
        const lightningButtonEl =
            element.shadowRoot.querySelector('lightning-button');
        lightningButtonEl.click();
        // Run all fake timers.
        jest.runAllTimers();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Was publish called and was it called with the correct params?
        expect(publish).toHaveBeenCalledWith(
            undefined,
            FILTERSCHANGEMC,
            DEFAULT_SEARCH_CRITERIA
        );
    });

    it('resets to default values when reset button is clicked', async () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Set inital form values
        let searchKeyEl = element.shadowRoot.querySelector('lightning-input');
        searchKeyEl.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 'someValue'
                }
            })
        );
        let sliderEls = element.shadowRoot.querySelectorAll('lightning-slider');
        sliderEls[0].dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 1
                }
            })
        );
        sliderEls[1].dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 2
                }
            })
        );
        sliderEls[2].dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 3
                }
            })
        );

        // Click reset button
        const lightningButtonEl =
            element.shadowRoot.querySelector('lightning-button');
        lightningButtonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check for default searchkey value
        searchKeyEl = element.shadowRoot.querySelector('lightning-input');
        expect(searchKeyEl.value).toBe(DEFAULT_SEARCH_CRITERIA.searchKey);

        sliderEls = element.shadowRoot.querySelectorAll('lightning-slider');
        // Check for default maxPrice value
        expect(sliderEls[0].value).toBe(DEFAULT_SEARCH_CRITERIA.maxPrice);
        // Check for default minBedrooms value
        expect(sliderEls[1].value).toBe(DEFAULT_SEARCH_CRITERIA.minBedrooms);
        // Check for default minBathrooms value
        expect(sliderEls[2].value).toBe(DEFAULT_SEARCH_CRITERIA.minBathrooms);
    });
});
