import { createElement } from 'lwc';
import DaysOnMarket from 'c/daysOnMarket';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import {
    registerLdsTestWireAdapter,
    registerTestWireAdapter
} from '@salesforce/sfdx-lwc-jest';
import {
    subscribe,
    MessageContext,
    publish,
    unsubscribe
} from 'lightning/messageService';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';
import DATE_LISTED_FIELD from '@salesforce/schema/Property__c.Date_Listed__c';
import DAYS_ON_MARKET_FIELD from '@salesforce/schema/Property__c.Days_On_Market__c';

const MAX_DAYS_CHART = 90;

const mockGetRecord = require('./data/getRecord.json');

// Register as a LDS wire adapter. Some tests verify the provisioned values trigger desired behavior.
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

// Register as a standard wire adapter because the component under test requires this adapter.
// We don't exercise this wire adapter in the tests.
const messageContextWireAdapter = registerTestWireAdapter(MessageContext);

describe('c-days-on-market', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it('renders error if no property is selected', () => {
        // Create initial element
        const element = createElement('c-days-on-market', {
            is: DaysOnMarket
        });
        document.body.appendChild(element);

        const errorPanelElement = element.shadowRoot.querySelector(
            'c-error-panel'
        );
        expect(errorPanelElement.friendlyMessage).toBe(
            'Select a property to see days on the market'
        );
    });

    it('registers the LMS subscriber during the component lifecycle', () => {
        // Create initial element
        const element = createElement('c-days-on-market', {
            is: DaysOnMarket
        });
        document.body.appendChild(element);

        // Validate if pubsub got registered after connected to the DOM
        expect(subscribe).toHaveBeenCalled();
        expect(subscribe.mock.calls[0][1]).toBe(PROPERTYSELECTEDMC);
    });

    it('unregisters the LMS subscriber during the component lifecycle', () => {
        // Create initial element
        const element = createElement('c-days-on-market', {
            is: DaysOnMarket
        });
        document.body.appendChild(element);
        document.body.removeChild(element);

        // Validate if pubsub got unsubscribed after disconnected from the DOM
        expect(unsubscribe).toHaveBeenCalled();
    });

    it('invokes getRecord with the published message payload value', () => {
        // Create element
        const element = createElement('c-days-on-market', {
            is: DaysOnMarket
        });
        document.body.appendChild(element);

        // Simulate pulishing a message using RECORD_SELECTED_CHANNEL message channel
        const messagePayload = { propertyId: '001' };
        publish(messageContextWireAdapter, PROPERTYSELECTEDMC, messagePayload);

        return Promise.resolve().then(() => {
            // The component subscription should cause getRecord to be invoked.
            // Below we test that it is invoked with the messagePayload value
            // that was published with the simulated publish invocation above.
            const { propertyId, fields } = getRecordAdapter.getLastConfig();
            expect(propertyId).toEqual(messagePayload.recordId);
            expect(fields).toEqual([DATE_LISTED_FIELD, DAYS_ON_MARKET_FIELD]);
        });
    });

    describe('getRecord @wire data', () => {
        function validateHTML(element, type) {
            const badgeEl = element.shadowRoot.querySelector(
                `div.badge.${type}`
            );
            expect(badgeEl).not.toBeNull();

            const daysDivEl = element.shadowRoot.querySelector('div.days');
            expect(daysDivEl.textContent).toBe(
                getFieldValue(mockGetRecord, DAYS_ON_MARKET_FIELD).toString()
            );

            const chartBarEl = element.shadowRoot.querySelector(
                `div.bar.${type}`
            );
            expect(chartBarEl).not.toBeNull();
            const width =
                (getFieldValue(mockGetRecord, DAYS_ON_MARKET_FIELD) /
                    MAX_DAYS_CHART) *
                100;
            expect(chartBarEl.style.width).toBe(`${width}%`);

            const formattedDateTimeEl = element.shadowRoot.querySelector(
                'lightning-formatted-date-time'
            );
            expect(formattedDateTimeEl.value).toBe(
                getFieldValue(mockGetRecord, DATE_LISTED_FIELD).toString()
            );
        }

        describe('renders days on market', () => {
            // eslint-disable-next-line jest/expect-expect
            it('in normal case', () => {
                // Create element
                const element = createElement('c-days-on-market', {
                    is: DaysOnMarket
                });
                element.recordId = '001';
                document.body.appendChild(element);

                // Emit data from @wire
                getRecordAdapter.emit(mockGetRecord);

                // Return a promise to wait for any asynchronous DOM updates. Jest
                // will automatically wait for the Promise chain to complete before
                // ending the test and fail the test if the promise rejects.
                return Promise.resolve().then(() => {
                    // Select elements for validation
                    validateHTML(element, 'normal');
                });
            });

            // eslint-disable-next-line jest/expect-expect
            it('in warning case', () => {
                // Create element
                const element = createElement('c-days-on-market', {
                    is: DaysOnMarket
                });
                element.recordId = '001';
                document.body.appendChild(element);

                // Emit data from @wire
                mockGetRecord.fields.Days_On_Market__c.value = 48;
                getRecordAdapter.emit(mockGetRecord);

                // Return a promise to wait for any asynchronous DOM updates. Jest
                // will automatically wait for the Promise chain to complete before
                // ending the test and fail the test if the promise rejects.
                return Promise.resolve().then(() => {
                    // Select elements for validation
                    validateHTML(element, 'warning');
                });
            });

            // eslint-disable-next-line jest/expect-expect
            it('in alert case', () => {
                // Create element
                const element = createElement('c-days-on-market', {
                    is: DaysOnMarket
                });
                element.recordId = '001';
                document.body.appendChild(element);

                // Emit data from @wire
                mockGetRecord.fields.Days_On_Market__c.value = 68;
                getRecordAdapter.emit(mockGetRecord);

                // Return a promise to wait for any asynchronous DOM updates. Jest
                // will automatically wait for the Promise chain to complete before
                // ending the test and fail the test if the promise rejects.
                return Promise.resolve().then(() => {
                    // Select elements for validation
                    validateHTML(element, 'alert');
                });
            });
        });
    });
    describe('getRecord @wire error', () => {
        it('renders an error panel when there is an error', () => {
            const APEX_ERROR = {
                body: 'Error retrieving records',
                ok: false,
                status: '400',
                statusText: 'Bad Request'
            };

            // Create initial element
            const element = createElement('c-days-on-market', {
                is: DaysOnMarket
            });
            element.recordId = '001';
            document.body.appendChild(element);

            // Emit error from @wire
            getRecordAdapter.error(
                APEX_ERROR.body,
                APEX_ERROR.status,
                APEX_ERROR.statusText
            );

            // Return a promise to wait for any asynchronous DOM updates. Jest
            // will automatically wait for the Promise chain to complete before
            // ending the test and fail the test if the promise rejects.
            return Promise.resolve().then(() => {
                const errorPanelEl = element.shadowRoot.querySelector(
                    'c-error-panel'
                );
                expect(errorPanelEl).not.toBeNull();
                expect(errorPanelEl.errors).toStrictEqual(APEX_ERROR);
            });
        });
    });

    it('is accessible when property selected', () => {
        const element = createElement('c-days-on-market', {
            is: DaysOnMarket
        });

        element.recordId = '001';
        document.body.appendChild(element);

        // Emit data from @wire
        getRecordAdapter.emit(mockGetRecord);

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });

    it('is accessible when no property selected', () => {
        const element = createElement('c-days-on-market', {
            is: DaysOnMarket
        });
        document.body.appendChild(element);

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });

    it('is accessible when error returned', () => {
        // Create initial element
        const element = createElement('c-days-on-market', {
            is: DaysOnMarket
        });
        element.recordId = '001';
        document.body.appendChild(element);

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });
});
