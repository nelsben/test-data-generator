@IsTest
private class DataSeederTest {
  @IsTest
  static void seedDataCreatesExpectedRecords() {
    Test.startTest();
    DataSeeder.SeedResult result = DataSeeder.seedData(
      5,
      2,
      3,
      2,
      Date.today().addYears(-2)
    );
    Test.stopTest();

    System.assertEquals(
      5,
      result.accountsCreated,
      'Expected number of accounts created.'
    );
    System.assertEquals(
      10,
      result.contactsCreated,
      'Expected number of contacts created.'
    );
    System.assertEquals(
      15,
      result.opportunitiesCreated,
      'Expected number of opportunities created.'
    );

    System.assertEquals(
      5,
      [SELECT COUNT() FROM Account],
      'Should create 5 accounts.'
    );
    System.assertEquals(
      10,
      [SELECT COUNT() FROM Contact WHERE AccountId != NULL],
      'Should create 2 contacts per account.'
    );
    System.assertEquals(
      15,
      [SELECT COUNT() FROM Opportunity WHERE AccountId != NULL],
      'Should create 3 opportunities per account.'
    );

    Opportunity sampleOpportunity = [
      SELECT CloseDate, StageName, Amount
      FROM Opportunity
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      sampleOpportunity.CloseDate,
      'CloseDate should be populated.'
    );
    System.assertNotEquals(
      null,
      sampleOpportunity.StageName,
      'Stage should be set.'
    );
    System.assert(sampleOpportunity.Amount > 0, 'Amount should be positive.');
  }

  @IsTest
  static void invocableMethodReturnsResults() {
    DataSeeder.SeedConfig config = new DataSeeder.SeedConfig();
    config.numberOfAccounts = 2;
    config.contactsPerAccount = 1;
    config.opportunitiesPerAccount = 1;

    Test.startTest();
    List<DataSeeder.SeedResult> results = DataSeeder.runInvocable(
      new List<DataSeeder.SeedConfig>{ config }
    );
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Should return a single result.');
    DataSeeder.SeedResult result = results[0];
    System.assertEquals(2, result.accountsCreated, 'Should create 2 accounts.');
    System.assertEquals(
      2,
      result.contactsCreated,
      'Should create 1 contact per account.'
    );
    System.assertEquals(
      2,
      result.opportunitiesCreated,
      'Should create 1 opportunity per account.'
    );
  }

  @IsTest
  static void seedDataValidatesArguments() {
    try {
      DataSeeder.seedData(0, 1, 1, 1, Date.today());
      System.assert(false, 'Expected exception for zero accounts.');
    } catch (Exception ex) {
      System.assert(
        ex.getMessage().contains('numberOfAccounts'),
        'Should mention invalid accounts parameter.'
      );
    }
  }
}
