# Dreamhouse Lightning Web Components Sample Application

<!--
[![CI Workflow](https://github.com/trailheadapps/dreamhouse-lwc/workflows/CI/badge.svg)](https://github.com/trailheadapps/dreamhouse-lwc/actions?query=workflow%3ACI) [![Packaging Workflow](https://github.com/trailheadapps/dreamhouse-lwc/workflows/Packaging/badge.svg)](https://github.com/trailheadapps/dreamhouse-lwc/actions?query=workflow%3APackaging) [![codecov](https://codecov.io/gh/trailheadapps/dreamhouse-lwc/branch/main/graph/badge.svg)](https://codecov.io/gh/trailheadapps/dreamhouse-lwc)
-->

![dreamhouse-logo](dreamhouse-logo.png)

This is a fork of the Dreamhouse [sample application](https://github.com/trailheadapps/dreamhouse-lwc) created by Salesforce developer relations team. This fork has been customized for the purpose of of installing and running the Audicity data tracking and field data history app.

## Table of contents

-   [Installing Dreamhouse Using a Scratch Org](#installing-dreamhouse-using-a-scratch-org): This is the recommended installation option. Use this option if you are a developer who wants to experience the app and the code.

-   [Installing Dreamhouse using a Developer Edition Org or a Trailhead Playground](#installing-dreamhouse-using-a-developer-edition-org-or-a-trailhead-playground): Useful when tackling Trailhead Badges or if you want the app deployed to a more permanent environment than a Scratch org.

-   [Note on Sample Data Import](#note-on-sample-data-import)

-   [Optional installation instructions](#optional-installation-instructions)

## Installing Dreamhouse using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

    - Enable Dev Hub in your Trailhead Playground or Developer Edition org
    - Install Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

1. If you haven't already done so, authorize your hub org and provide it with an alias (**myhuborg** in the command below):

    ```
    sf org login web -d -a myhuborg
    ```

1. Clone this repository:

    ```
    git clone https://github.com/processity/dreamhouse-audicity.git
    cd dreamhouse-audicity
    ```

1. Create a scratch org and provide it with an alias (**dreamhouse-audicity** in the command below):

    ```
    sf org create scratch -d -f config/project-scratch-def.json -a dreamhouse-audicity
    ```

1. Push the app to your scratch org:

    ```
    sf project deploy start
    ```

1. Assign the **dreamhouse** permission set to the default user:

    ```
    sf org assign permset -n dreamhouse
    ```

<!--
1. (Optional) Assign the `Walkthroughs` permission set to the default user.

    > Note: this will enable your user to use In-App Guidance Walkthroughs, allowing you to be taken through a guided tour of the sample app. The Walkthroughs permission set gets auto-created with In-App guidance activation.

    ```
    sf org assign permset -n Walkthroughs
    ```
-->

1. Import sample data:

    ```
    sf data tree import -p data/sample-data-plan.json
    ```

1. Open the scratch org:

    ```
    sf org open
    ```

1. In **Setup**, under **Themes and Branding**, activate the **Lightning Lite** theme.

1. In App Launcher, select the **Dreamhouse** app.

<!--
## Installing Dreamhouse using an Unlocked Package

Follow this set of instructions if you want to deploy the app to a more permanent environment than a Scratch org or if you don't want to install the local developement tools. You can use a non source-tracked orgs such as a free [Developer Edition Org](https://developer.salesforce.com/signup) or a [Trailhead Playground](https://trailhead.salesforce.com/).

Make sure to start from a brand-new environment to avoid conflicts with previous work you may have done.

1. Log in to your org

1. Click [this link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t3h000001RcBxAAK) to install the Dreamhouse unlocked package in your org.

1. Select **Install for All Users**

1. In App Launcher, click **View all**, select the Dreamhouse app.

1. Click the **Settings** tab and click the **Import Data** button in the **Sample Data Import** component.

1. If you're attempting the [Quick Start](https://trailhead.salesforce.com/en/content/learn/projects/quick-start-dreamhouse-sample-app) on Trailhead, this step is required, but otherwise, skip:

    - Go to **Setup > Users > Permission Sets**.
    - Click **dreamhouse**.
    - Click **Manage Assignments**.
    - Check your user and click **Add Assignments**.

1. In **Setup**, under **Themes and Branding**, activate the **Lightning Lite** theme.

1. In App Launcher, select the **Dreamhouse** app.
-->

## Installing Dreamhouse using a Developer Edition Org or a Trailhead Playground

Follow this set of instructions if you want to deploy the app to a more permanent environment than a Scratch org.
This includes non source-tracked orgs such as a [free Developer Edition Org](https://developer.salesforce.com/signup) or a [Trailhead Playground](https://trailhead.salesforce.com/).

Make sure to start from a brand-new environment to avoid conflicts with previous work you may have done.

1. Clone this repository:

    ```
    git clone https://github.com/processity/dreamhouse-audicity.git
    cd dreamhouse-audicity
    ```

1. Authorize your Trailhead Playground or Developer org and provide it with an alias (**mydevorg** in the command below):

    ```
    sf org login web -s -a mydevorg
    ```

1. Run this command in a terminal to deploy the app.

    ```
    sf project deploy start -d force-app
    ```

1. Assign the `dreamhouse` permission set to the default user.

    ```
    sf org assign permset -n dreamhouse
    ```

1. Import some sample data.

    ```
    sf data tree import -p ./data/sample-data-plan.json
    ```

1. If your org isn't already open, open it now:

    ```
    sf org open -o mydevorg
    ```

1. In App Launcher, select the **Dreamhouse** app.

## Note on Sample Data Import

Properties inserted using the Salesforce CLI will appear as listed on TODAY() - 10 days. If you want to have this value randomized, perform the data import from the app Settings tab instead.

## Optional Installation Instructions

This repository contains several files that are relevant if you want to integrate modern web development tooling to your Salesforce development processes, or to your continuous integration/continuous deployment processes.

### Code formatting

[Prettier](https://prettier.io 'https://prettier.io/') is a code formatter used to ensure consistent formatting across your code base. To use Prettier with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) from the Visual Studio Code Marketplace. The [.prettierignore](/.prettierignore) and [.prettierrc](/.prettierrc) files are provided as part of this repository to control the behavior of the Prettier formatter.

> **Warning**
> The current Apex Prettier plugin version requires that you install Java 11 or above.

### Code linting

[ESLint](https://eslint.org/) is a popular JavaScript linting tool used to identify stylistic errors and erroneous constructs. To use ESLint with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-lwc) from the Visual Studio Code Marketplace. The [.eslintignore](/.eslintignore) file is provided as part of this repository to exclude specific files from the linting process in the context of Lightning Web Components development.

### Pre-commit hook

This repository also comes with a [package.json](./package.json) file that makes it easy to set up a pre-commit hook that enforces code formatting and linting by running Prettier and ESLint every time you `git commit` changes.

To set up the formatting and linting pre-commit hook:

1. Install [Node.js](https://nodejs.org) if you haven't already done so
1. Run `npm install` in your project's root folder to install the ESLint and Prettier modules (Note: Mac users should verify that Xcode command line tools are installed before running this command.)

Prettier and ESLint will now run automatically every time you commit changes. The commit will fail if linting errors are detected. You can also run the formatting and linting from the command line using the following commands (check out [package.json](./package.json) for the full list):

```
npm run lint
npm run prettier
```

## Credits

The app GeocodingService uses OpenStreetMap API to geocode property addresses. OpenStreetMap® is open data, licensed under the [Open Data Commons Open Database License (ODbL)](https://opendatacommons.org/licenses/odbl/) by the [OpenStreetMap Foundation (OSMF)](https://wiki.osmfoundation.org/wiki/Main_Page). You are free to copy, distribute, transmit and adapt OpenStreetMap data, as long as you credit OpenStreetMap and its contributors. If you alter or build upon our data, you may distribute the result only under the same licence. The [full legal code](https://opendatacommons.org/licenses/odbl/1-0/) explains your rights and responsibilities in regard to the service.

## Notes and Additions for Audicity

-   Installation instructions for Audicity package on AppExchange (generate org password and then login to org during appexchange install)
-   Assigning Audicity Permset
    `> sf org assign permset -n AudicityLoggingAdministrator`
-   turn on audicity tracking
-   configure Property object and some fields for tracking
    -   make sure to save object settings even when changing fields
-   add the Audit Trail LWC to the property record page with Lightning app builder
-   instrument the `PropertyTrigger` trigger with `mantra.AudicityApex.track()`
-   test creating and editing a Property record
-   add the trigger for campaign and instrument it with `mantra.AudicityApex.track()`
-   (maybe test again here)
-   instrument the `jobId` in the trigger handler and `execute()` method of each Queueable
-   test an update action again
