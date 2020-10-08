const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

const setupFilesAfterEnv = jestConfig.setupFilesAfterEnv || [];
setupFilesAfterEnv.push('<rootDir>/jest-sa11y-setup.js');

module.exports = {
    ...jestConfig,
    moduleNameMapper: {
        '^@salesforce/schema$': '<rootDir>/force-app/test/jest-mocks/schema',
        '^lightning/navigation$':
            '<rootDir>/force-app/test/jest-mocks/lightning/navigation',
        '^lightning/platformShowToastEvent$':
            '<rootDir>/force-app/test/jest-mocks/lightning/platformShowToastEvent',
        '^lightning/messageService$':
            '<rootDir>/force-app/test/jest-mocks/lightning/messageService'
    },
    setupFilesAfterEnv
};
