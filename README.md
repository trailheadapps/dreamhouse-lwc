# Dreamhouse Lightning Web Components Sample Application

[![Github Workflow](<https://github.com/dreamhouseapp/dreamhouse-lwc/workflows/Salesforce%20DX%20(scratch%20org)/badge.svg?branch=master>)](https://github.com/dreamhouseapp/dreamhouse-lwc/actions?query=workflow%3A%22Salesforce+DX+%28scratch+org%29%22) [![Github Workflow](<https://github.com/dreamhouseapp/dreamhouse-lwc/workflows/Salesforce%20DX%20(packaging)/badge.svg?branch=master>)](https://github.com/dreamhouseapp/dreamhouse-lwc/actions?query=workflow%3A%22Salesforce+DX+%28packaging%29%22)

> IMPORTANT: This is the new Lightning Web Components version of the Dreamhouse sample application. If you are looking for the Aura version, click [here](https://github.com/dreamhouseapp/dreamhouse-sfdx).

![dreamhouse-logo](dreamhouse-logo.png)

DreamHouse is a sample application that demonstrates the unique value proposition of the Salesforce platform for building Employee Productivity and Customer Engagement apps.

> This sample application is designed to run on Salesforce Platform. If you want to experience Lightning Web Components on any platform, please visit https://lwc.dev, and try out our Lightning Web Components sample application [LWC Recipes OSS](https://github.com/trailheadapps/lwc-recipes-oss).

## Table of contents

-   [Installing Dreamhouse Using a Scratch Org](#installing-dreamhouse-using-a-scratch-org): This is the recommended installation option. Use this option if you are a developer who wants to experience the app and the code.

-   [Installing Dreamhouse Using an Unlocked Package](#installing-dreamhouse-using-an-unlocked-package): This option allows anybody to experience the sample app without installing a local development environment.

-   [Installing Dreamhouse using a Developer Edition Org or a Trailhead Playground](#installing-dreamhouse-using-a-developer-edition-org-or-a-trailhead-playground): Useful when tackling Trailhead Badges or if you want the app deployed to a more permanent environment than a Scratch org.

-   [Note on Sample Data Import](#note-on-sample-data-import)

-   [Optional installation instructions](#optional-installation-instructions)

## Installing Dreamhouse using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

    - Enable Dev Hub in your Trailhead Playground
    - Install Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

1. If you haven't already done so, authenticate with your hub org and provide it with an alias (**myhuborg** in the command below):

    ```
    sfdx force:auth:web:login -d -a myhuborg
    ```

1. Clone this repository:

    ```
    git clone https://github.com/dreamhouseapp/dreamhouse-lwc
    cd dreamhouse-lwc
    ```

1. Create a scratch org and provide it with an alias (**dreamhouse** in the command below):

    ```
    sfdx force:org:create -s -f config/project-scratch-def.json -a dreamhouse
    ```

1. Push the app to your scratch org:

    ```
    sfdx force:source:push
    ```

1. Assign the **dreamhouse** permission set to the default user:

    ```
    sfdx force:user:permset:assign -n dreamhouse
    ```

1. Import sample data:

    ```
    sfdx force:data:tree:import -p data/sample-data-plan.json
    ```

1. Open the scratch org:

    ```
    sfdx force:org:open
    ```

1. In **Setup**, under **Themes and Branding**, activate the **Lightning Lite** theme.

1. In App Launcher, select the **Dreamhouse** app.

## Installing Dreamhouse using an Unlocked Package

Follow this set of instructions if you want to deploy the app to a more permanent environment than a Scratch org or if you don't want to install the local developement tools. You can use a non source-tracked orgs such as a free [Developer Edition Org](https://developer.salesforce.com/signup) or a [Trailhead Playground](https://trailhead.salesforce.com/).

Make sure to start from a brand-new environment to avoid conflicts with previous work you may have done.

1. Log in to your org

1. If you are setting up a Developer Edition: go to **Setup**, under **My Domain**, [register a My Domain](https://help.salesforce.com/articleView?id=domain_name_setup.htm&type=5).

1. Click [this link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000KqVNIA0) to install the Dreamhouse unlocked package in your org.

1. Select **Install for All Users**

1. In App Launcher, click **View all**, select the Dreamhouse app.

1. Click the **Settings** tab and click the **Import Data** button in the **Sample Data Import** component.

1. In **Setup**, under **Themes and Branding**, activate the **Lightning Lite** theme.

1. In App Launcher, select the **Dreamhouse** app.

## Installing Dreamhouse using a Developer Edition Org or a Trailhead Playground

Follow this set of instructions if you want to deploy the app to a more permanent environment than a Scratch org.
This includes non source-tracked orgs such as a [free Developer Edition Org](https://developer.salesforce.com/signup) or a [Trailhead Playground](https://trailhead.salesforce.com/).

Make sure to start from a brand-new environment to avoid conflicts with previous work you may have done.

1. Authenticate with your Trailhead Playground or Developer org and provide it with an alias (**mydevorg** in the command below):

    ```
    sfdx force:auth:web:login -d -a mydevorg
    ```

1. Clone this repository:

    ```
    git clone https://github.com/dreamhouseapp/dreamhouse-lwc
    cd dreamhouse-lwc
    ```

1. If you are setting up a Developer Edition: go to **Setup**, under **My Domain**, [register a My Domain](https://help.salesforce.com/articleView?id=domain_name_setup.htm&type=5).

1. Run this command in a terminal to deploy the app.

    ```
    sfdx force:source:deploy -p force-app
    ```

1. Assign the `dreamhouse` permission set to the default user.

    ```
    sfdx force:user:permset:assign -n dreamhouse
    ```

1. Import some sample data.

    ```
    sfdx force:data:tree:import -p ./data/sample-data-plan.json
    ```

1. In **Setup**, under **Themes and Branding**, activate the **Lightning Lite** theme.

1. In App Launcher, select the **Dreamhouse** app.

## Note on Sample Data Import

Properties inserted using the Salesforce CLI will appear as listed on TODAY() - 10 days. If you want to have this value randomized, perform the data import from the app Settings tab instead.

## Optional Installation Instructions

This repository contains several files that are relevant if you want to integrate modern web development tooling to your Salesforce development processes, or to your continuous integration/continuous deployment processes.

### Code formatting

[Prettier](https://prettier.io 'https://prettier.io/') is a code formatter used to ensure consistent formatting across your code base. To use Prettier with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) from the Visual Studio Code Marketplace. The [.prettierignore](/.prettierignore) and [.prettierrc](/.prettierrc) files are provided as part of this repository to control the behavior of the Prettier formatter.

### Code linting

[ESLint](https://eslint.org/) is a popular JavaScript linting tool used to identify stylistic errors and erroneous constructs. To use ESLint with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-lwc) from the Visual Studio Code Marketplace. The [.eslintignore](/.eslintignore) file is provided as part of this repository to exclude specific files from the linting process in the context of Lightning Web Components development.

### Pre-commit hook

This repository also comes with a [package.json](./package.json) file that makes it easy to set up a pre-commit hook that enforces code formatting and linting by running Prettier and ESLint every time you `git commit` changes.

To set up the formatting and linting pre-commit hook:

1. Install [Node.js](https://nodejs.org) if you haven't already done so
1. Run `npm install` in your project's root folder to install the ESLint and Prettier modules (Note: Mac users should verify that Xcode command line tools are installed before running this command.)

Prettier and ESLint will now run automatically every time you commit changes. The commit will fail if linting errors are detected. You can also run the formatting and linting from the command line using the following commands (check out [package.json](./package.json) for the full list):

```
npm run lint:lwc
npm run prettier
```
