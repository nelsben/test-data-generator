# Data Cloud Test Data Generator

This Salesforce DX project seeds realistic Accounts, Contacts, and Opportunities so you can create orgs with thousands of records for Data Cloud and Agentforce testing.

## Project Structure

All deployable metadata lives under `force-app/main/default`. The core data generation logic is implemented in the `DataSeeder` Apex class:

- `force-app/main/default/classes/DataSeeder.cls` — bulk seeding utility with invocable entry point
- `force-app/main/default/classes/DataSeederTest.cls` — test coverage for seeding logic

## Seeding Sample Data

1. Authorize a target org (scratch org or sandbox):
   ```bash
   sf org login web --alias my-test-org
   ```
2. Push the metadata:
   ```bash
   sf project deploy start --target-org my-test-org
   ```
3. Run the seeding script to create data:
   ```bash
   sf apex run --target-org my-test-org --file scripts/apex/seedData.apex
   ```

### Customizing the Seed

The `DataSeeder.seedData` method accepts the following parameters:

- `numberOfAccounts` (required)
- `contactsPerAccount` (default 2)
- `opportunitiesPerAccount` (default 3)
- `opportunityHistoryInYears` (default 3)
- `firstCloseDate` (defaults to today minus history years)

Adjust the values in `scripts/apex/seedData.apex` or call `DataSeeder.runInvocable` from Flow to fit your scenario.

## Running Tests

Execute Apex tests to validate the generator:

```bash
sf apex run test --tests DataSeederTest --target-org my-test-org
```
