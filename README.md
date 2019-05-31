# Dreamhouse Lightning Web Components Sample Application

[![CircleCI](https://circleci.com/gh/dreamhouseapp/dreamhouse-lwc.svg?style=svg)](https://circleci.com/gh/dreamhouseapp/dreamhouse-lwc)

> IMPORTANT: This is the new Lightning Web Components version of the Dreamhouse sample application. If you are looking for the Aura version, click [here](https://github.com/dreamhouseapp/dreamhouse-sfdx).

![dreamhouse-logo](dreamhouse-logo.png)

DreamHouse is a sample application that demonstrates the unique value proposition of the Salesforce platform for building Employee Productivity and Customer Engagement apps.

> This sample application is designed to run on Salesforce Platform. If you want to experience Lightning Web Components on any platform, please visit https://lwc.dev, and try out our Lightning Web Components sample application [LWC Recipes OSS](https://github.com/trailheadapps/lwc-recipes-oss).

## Installation Instructions

There are two ways to install Dreamhouse:

-   [Using a Scratch Org](#installing-dreamhouse-using-a-scratch-org): This is the recommended installation option. Use this option if you are a developer who wants to experience the app and the code.
-   [Using an Unlocked Package](#installing-dreamhouse-using-an-unlocked-package): This option allows anybody to experience the sample app without installing a local development environment.

## Installing Dreamhouse using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

-   Enable Dev Hub in your Trailhead Playground
-   Install Salesforce CLI
-   Install Visual Studio Code
-   Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

2. If you haven't already done so, authenticate with your hub org and provide it with an alias (**myhuborg** in the command below):

```
sfdx force:auth:web:login -d -a myhuborg
```

3. Clone this repository:

```
git clone https://github.com/dreamhouseapp/dreamhouse-lwc
cd dreamhouse-lwc
```

4. Create a scratch org and provide it with an alias (**dreamhouse** in the command below):

```
sfdx force:org:create -s -f config/project-scratch-def.json -a dreamhouse
```

5. Push the app to your scratch org:

```
sfdx force:source:push
```

6. Assign the **dreamhouse** permission set to the default user:

```
sfdx force:user:permset:assign -n dreamhouse
```

7. Import sample data:

```
sfdx force:data:tree:import --plan data/sample-data.json
```

8. Open the scratch org:

```
sfdx force:org:open
```

9. In **Setup**, under **Themes and Branding**, activate the **Lightning Lite** theme.

10. In App Launcher, select the **Dreamhouse** app.

## Installing Dreamhouse using an Unlocked Package

1. [Sign up](https://developer.salesforce.com/signup) for a Developer Edition (DE) org.

2. Enable MyDomain in your DE org. Instructions to do this are [here](https://trailhead.salesforce.com/modules/identity_login/units/identity_login_my_domain).

3. Click [this link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000KAfEIAW) to install the Dreamhouse unlocked package in your DE org.

4. Select **Install for All Users**

5. In App Launcher, select the Dreamhouse app.

6. Click the **Settings** tab and click the **Import Data** button in the **Sample Data Import** component.

7. In **Setup**, under **Themes and Branding**, activate the **Lightning Lite** theme.

8. In App Launcher, select the **Dreamhouse** app.

## Optional Installation Instructions

This repository contains several files that are relevant if you want to integrate modern web development tooling to your Salesforce development processes, or to your continuous integration/continuous deployment processes.

### Code formatting

[Prettier](https://prettier.io 'https://prettier.io/') is a code formatter used to ensure consistent formatting across your code base. To use Prettier with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) from the Visual Studio Code Marketplace. The [.prettierignore](/.prettierignore) and [.prettierrc](/.prettierrc) files are provided as part of this repository to control the behavior of the Prettier formatter.

### Code linting

[ESLint](https://eslint.org/) is a popular JavaScript linting tool used to identify stylistic errors and erroneous constructs. To use ESLint with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-lwc) from the Visual Studio Code Marketplace. The [.eslintignore](/.eslintignore) file is provided as part of this repository to exclude specific files from the linting process in the context of Lighning Web Components development.

### Pre-commit hook

This repository also comes with a [package.json](./package.json) file that makes it easy to set up a pre-commit hook that enforces code formatting and linting by running Prettier and ESLint every time you `git commit` changes.

To set up the formatting and linting pre-commit hook:

1. Install [Node.js](https://nodejs.org) if you haven't already done so
2. Run `npm install` in your project's root folder to install the ESLint and Prettier modules (Note: Mac users should verify that Xcode command line tools are installed before running this command.)

Prettier and ESLint will now run automatically every time you commit changes. The commit will fail if linting errors are detected. You can also run the formatting and linting from the command line using the following commands (check out [package.json](./package.json) for the full list):

```
npm run lint:lwc
npm run prettier
```
