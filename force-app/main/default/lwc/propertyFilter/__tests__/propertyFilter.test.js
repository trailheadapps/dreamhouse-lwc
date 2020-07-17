import { createElement } from 'lwc';
import PropertyFilter from 'c/propertyFilter';
import { publish } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';

const MAX_PRICE = 1200000;

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

    it('renders the component with all the filters', () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-button element
        const lightningButtonEl = element.shadowRoot.querySelector(
            'lightning-button'
        );
        expect(lightningButtonEl).not.toBeNull();

        // Query lightning-input element
        const lightningInputEl = element.shadowRoot.querySelector(
            'lightning-input'
        );
        expect(lightningInputEl).not.toBeNull();

        // Query lightning-slider elements
        const lightningSliderEls = element.shadowRoot.querySelectorAll(
            'lightning-slider'
        );
        expect(lightningSliderEls.length).toBe(3);
    });

    it('fires the change event on new search input', () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-input element
        const lightningInputEl = element.shadowRoot.querySelector(
            'lightning-input'
        );
        lightningInputEl.value = 'Boston';
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
        return Promise.resolve().then(() => {
            // Was publish called and was it called with the correct params?
            expect(publish).toHaveBeenCalledWith(
                undefined,
                FILTERSCHANGEMC,
                SEARCH_CRITERIA
            );
        });
    });

    it('fires the change event on Max Price slider input', () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-input element
        const lightningSliderEl = element.shadowRoot.querySelector(
            'lightning-slider'
        );
        lightningSliderEl.value = 4500000;
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
        return Promise.resolve().then(() => {
            // Was publish called and was it called with the correct params?
            expect(publish).toHaveBeenCalledWith(
                undefined,
                FILTERSCHANGEMC,
                SEARCH_CRITERIA
            );
        });
    });

    it('fires the change event on Bedrooms slider input', () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-input element
        const lightningSliderEl = element.shadowRoot.querySelectorAll(
            'lightning-slider'
        )[1];
        lightningSliderEl.value = 2;
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
        return Promise.resolve().then(() => {
            // Was publish called and was it called with the correct params?
            expect(publish).toHaveBeenCalledWith(
                undefined,
                FILTERSCHANGEMC,
                SEARCH_CRITERIA
            );
        });
    });

    it('fires the change event on Bathrooms slider input', () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Query lightning-input element
        const lightningSliderEl = element.shadowRoot.querySelectorAll(
            'lightning-slider'
        )[2];
        lightningSliderEl.value = 2;
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
        return Promise.resolve().then(() => {
            // Was publish called and was it called with the correct params?
            expect(publish).toHaveBeenCalledWith(
                undefined,
                FILTERSCHANGEMC,
                SEARCH_CRITERIA
            );
        });
    });

    it('resets to default values when reset button is clicked', () => {
        // Create initial element
        const element = createElement('c-property-filter', {
            is: PropertyFilter
        });
        document.body.appendChild(element);

        // Mock handlers for child events
        const handleReset = jest.fn();
        element.addEventListener('click', handleReset);

        // Query lightning-input element
        const lightningButtonEl = element.shadowRoot.querySelector(
            'lightning-button'
        );
        lightningButtonEl.click();
        // Run all fake timers.
        jest.runAllTimers();

        const SEARCH_CRITERIA = {
            searchKey: '',
            maxPrice: MAX_PRICE,
            minBedrooms: 0,
            minBathrooms: 0
        };
        return Promise.resolve().then(() => {
            // Was publish called and was it called with the correct params?
            expect(publish).toHaveBeenCalledWith(
                undefined,
                FILTERSCHANGEMC,
                SEARCH_CRITERIA
            );
        });
    });
});
