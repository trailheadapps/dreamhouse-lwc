## Salesforce DX

1. **Enable Dev Hub in Your Trailhead Playground**

2. **Log In to the Dev Hub:**
    ```sh
    sf org login web -d -a DevHub
    ```

3. **After login, you see the message of success:**
    ```
    Successfully authorized rraodv@salesforcedx1.com with org id 00D1I000000n3H5UAI
    ```

4. **Create a project:**
    ```sh
    mkdir my_sf_project
    cd my_sf_project
    ```

5. **Clone a project:**
    ```sh
    git clone https://github.com/trailheadapps/dreamhouse-lwc.git
    ```

6. **Open the project:**
    ```sh
    cd dreamhouse-lwc
    ```

7. **Create the new branch, so you do not work in the main branch of the project:**
    ```sh
    git checkout -b my_branch
    ```

8. **Command help:**
    ```sh
    sf help
    ```

## Create and Test Our Scratch Org

1. **Create a scratch org, set it as your default, and give it an alias:**
    ```sh
    sf org create scratch -d -f config/project-scratch-def.json -a dreamhouse-org
    sf open org
    ```

2. **Deploy the dreamforce-lwc project into the scratch org with this command:**
    ```sh
    sf project deploy start
    ```

3. **Assign the permission set by running the command:**
    ```sh
    sf org assign permset -n Dreamhouse
    ```

4. **Import Test Data:**
    ```sh
    sf data import tree -p data/sample-data-plan.json
    ```