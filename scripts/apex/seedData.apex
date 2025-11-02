// Run this script with `sf apex run --file scripts/apex/seedData.apex`
DataSeeder.SeedConfig config = new DataSeeder.SeedConfig();
config.numberOfAccounts = 50;
config.contactsPerAccount = 3;
config.opportunitiesPerAccount = 4;
config.opportunityHistoryInYears = 4;
config.firstCloseDate = Date.today().addYears(-4);

DataSeeder.SeedResult result = DataSeeder.seedData(
    config.numberOfAccounts,
    config.contactsPerAccount,
    config.opportunitiesPerAccount,
    config.opportunityHistoryInYears,
    config.firstCloseDate
);
System.debug('Accounts Created: ' + result.accountsCreated);
System.debug('Contacts Created: ' + result.contactsCreated);
System.debug('Opportunities Created: ' + result.opportunitiesCreated);
