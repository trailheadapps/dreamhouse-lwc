import { createElement } from 'lwc';
import BrokerCard from 'c/brokerCard';
import { getNavigateCalledWith } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

// Mock realistic data
const mockGetPropertyRecord = require('./data/getPropertyRecord.json');

// Register as an LDS wire adapter. Some tests verify the provisioned values trigger desired behavior.
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

const BROKER_ID = 'a003h000003xlBiAAI';

const BROKER_FIELDS_INPUT = [
    {
        fieldApiName: 'Name',
        objectApiName: 'Broker__c'
    },
    {
        fieldApiName: 'Phone__c',
        objectApiName: 'Broker__c'
    },
    {
        fieldApiName: 'Mobile_Phone__c',
        objectApiName: 'Broker__c'
    },
    {
        fieldApiName: 'Email__c',
        objectApiName: 'Broker__c'
    }
];

describe('c-broker-card', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing.
    function flushPromises() {
        // eslint-disable-next-line no-undef
        return new Promise((resolve) => setImmediate(resolve));
    }

    describe('broker record form', () => {
        it('gets property data from wire service', () => {
            // Create element
            const element = createElement('c-broker-card', {
                is: BrokerCard
            });
            document.body.appendChild(element);

            // Emit data from @wire
            getRecordAdapter.emit(mockGetPropertyRecord);

            return flushPromises().then(() => {
                const propertyEl = element.shadowRoot.querySelector(
                    'lightning-record-form'
                );
                expect(getFieldValue).toHaveBeenCalled();
                expect(propertyEl.recordId).toBe(BROKER_ID);
            });
        });

        it('renders lightning-record-form with given input values', () => {
            // Create element
            const element = createElement('c-broker-card', {
                is: BrokerCard
            });
            document.body.appendChild(element);

            // Emit data from @wire
            getRecordAdapter.emit(mockGetPropertyRecord);

            // Return a promise to wait for any asynchronous DOM updates. Jest
            // will automatically wait for the Promise chain to complete before
            // ending the test and fail the test if the promise rejects.
            return flushPromises().then(() => {
                const propertyEl = element.shadowRoot.querySelector(
                    'lightning-record-form'
                );
                expect(propertyEl.fields).toEqual(BROKER_FIELDS_INPUT);
                expect(propertyEl.recordId).toBe(BROKER_ID);
            });
        });
    });

    describe('navigate to broker record', () => {
        it('navigates to record view', () => {
            // Nav param values to test later
            const NAV_TYPE = 'standard__recordPage';
            const NAV_OBJECT_API_NAME = 'Property__c';
            const NAV_ACTION_NAME = 'view';
            const NAV_RECORD_ID = BROKER_ID;

            // Create initial lwc element and attach to virtual DOM
            const element = createElement('c-broker-card', {
                is: BrokerCard
            });
            document.body.appendChild(element);

            // Simulate the data sent over wire adapter to hydrate the wired property
            getRecordAdapter.emit(mockGetPropertyRecord);

            // Return a promise to wait for any asynchronous DOM updates. Jest
            // will automatically wait for the Promise chain to complete before
            // ending the test and fail the test if the promise rejects.
            return flushPromises().then(() => {
                // Get handle to view button and fire click event
                const buttonEl = element.shadowRoot.querySelector(
                    'lightning-button-icon'
                );
                buttonEl.click();

                const { pageReference } = getNavigateCalledWith();
                // Verify component called with correct event type and params
                expect(pageReference.type).toBe(NAV_TYPE);
                expect(pageReference.attributes.objectApiName).toBe(
                    NAV_OBJECT_API_NAME
                );
                expect(pageReference.attributes.actionName).toBe(
                    NAV_ACTION_NAME
                );
                expect(pageReference.attributes.recordId).toBe(NAV_RECORD_ID);
            });
        });
    });

    describe('error panel', () => {
        it('renders error if data is not retrieved successfully', () => {
            const WIRE_ERROR = 'Something bad happened';

            // Create element and attach to virtual DOM
            const element = createElement('c-broker-card', {
                is: BrokerCard
            });
            document.body.appendChild(element);

            getRecordAdapter.error(WIRE_ERROR);

            return flushPromises().then(() => {
                const errorPanelEl = element.shadowRoot.querySelector(
                    'c-error-panel'
                );
                expect(errorPanelEl).not.toBeNull();
                expect(errorPanelEl.errors.body).toBe(WIRE_ERROR);
                expect(errorPanelEl.friendlyMessage).toBe(
                    'Error retrieving data'
                );
            });
        });
    });

    it('is accessible when property returned', () => {
        const element = createElement('c-broker-card', {
            is: BrokerCard
        });

        document.body.appendChild(element);

        // Emit data from @wire
        getRecordAdapter.emit(mockGetPropertyRecord);

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });

    it('is accessible when error returned', () => {
        const WIRE_ERROR = 'Something bad happened';

        // Create element and attach to virtual DOM
        const element = createElement('c-broker-card', {
            is: BrokerCard
        });
        document.body.appendChild(element);

        getRecordAdapter.error(WIRE_ERROR);

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });
});
