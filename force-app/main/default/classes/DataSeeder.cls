public with sharing class DataSeeder {
  public class SeedConfig {
    @InvocableVariable(required=true)
    public Integer numberOfAccounts;
    @InvocableVariable
    public Integer contactsPerAccount;
    @InvocableVariable
    public Integer opportunitiesPerAccount;
    @InvocableVariable
    public Integer opportunityHistoryInYears;
    @InvocableVariable
    public Date firstCloseDate;
  }

  public class SeedResult {
    @InvocableVariable
    public Integer accountsCreated;
    @InvocableVariable
    public Integer contactsCreated;
    @InvocableVariable
    public Integer opportunitiesCreated;
  }

  private static final List<String> INDUSTRIES = new List<String>{
    'Technology',
    'Financial Services',
    'Healthcare',
    'Manufacturing',
    'Retail',
    'Energy',
    'Telecommunications'
  };
  private static final List<String> ACCOUNT_TYPES = new List<String>{
    'Prospect',
    'Customer - Direct',
    'Customer - Channel',
    'Partner',
    'Vendor'
  };
  private static final List<String> STAGE_NAMES = new List<String>{
    'Prospecting',
    'Qualification',
    'Needs Analysis',
    'Value Proposition',
    'Id. Decision Makers',
    'Perception Analysis',
    'Proposal/Price Quote',
    'Negotiation/Review',
    'Closed Won',
    'Closed Lost'
  };
  private static final List<String> LEAD_SOURCES = new List<String>{
    'Web',
    'Phone Inquiry',
    'Partner Referral',
    'Purchased List',
    'Trade Show',
    'Employee Referral'
  };
  private static final List<String> JOB_TITLES = new List<String>{
    'VP of Operations',
    'Chief Technology Officer',
    'Sales Director',
    'Finance Manager',
    'Head of Procurement',
    'Customer Success Manager',
    'Chief Marketing Officer',
    'IT Manager'
  };
  private static final List<String> CITIES = new List<String>{
    'San Francisco',
    'New York',
    'Chicago',
    'Austin',
    'Denver',
    'Seattle',
    'Atlanta',
    'Boston'
  };
  private static final List<String> STATES = new List<String>{
    'CA',
    'NY',
    'IL',
    'TX',
    'CO',
    'WA',
    'GA',
    'MA'
  };
  private static final List<String> CONTACT_FIRST_NAMES = new List<String>{
    'Alex',
    'Jordan',
    'Taylor',
    'Morgan',
    'Quinn',
    'Riley',
    'Harper',
    'Dakota',
    'Logan',
    'Reese'
  };
  private static final List<String> CONTACT_LAST_NAMES = new List<String>{
    'Smith',
    'Johnson',
    'Williams',
    'Brown',
    'Jones',
    'Garcia',
    'Miller',
    'Davis',
    'Lopez',
    'Wilson'
  };
  private static final List<String> OPPORTUNITY_THEMES = new List<String>{
    'Expansion',
    'Renewal',
    'Upgrade',
    'Implementation',
    'Pilot',
    'Migration',
    'Transformation',
    'Optimization'
  };

  @InvocableMethod(
    label='Seed Sample Data'
    description='Generate Accounts with related Contacts and Opportunities for testing'
  )
  public static List<SeedResult> runInvocable(List<SeedConfig> requests) {
    List<SeedResult> results = new List<SeedResult>();
    for (SeedConfig request : requests) {
      SeedResult result = seedData(
        request.numberOfAccounts,
        request.contactsPerAccount,
        request.opportunitiesPerAccount,
        request.opportunityHistoryInYears,
        request.firstCloseDate
      );
      results.add(result);
    }
    return results;
  }

  public static SeedResult seedData(
    Integer numberOfAccounts,
    Integer contactsPerAccount,
    Integer opportunitiesPerAccount,
    Integer opportunityHistoryInYears,
    Date firstCloseDate
  ) {
    if (numberOfAccounts == null || numberOfAccounts <= 0) {
      throw new IllegalArgumentException(
        'numberOfAccounts must be greater than 0.'
      );
    }

    Integer contactsPer = contactsPerAccount != null &&
      contactsPerAccount > 0
      ? contactsPerAccount
      : 2;
    Integer opportunitiesPer = opportunitiesPerAccount != null &&
      opportunitiesPerAccount > 0
      ? opportunitiesPerAccount
      : 3;
    Integer historyYears = opportunityHistoryInYears != null &&
      opportunityHistoryInYears > 0
      ? opportunityHistoryInYears
      : 3;
    Date startDate = firstCloseDate != null
      ? firstCloseDate
      : Date.today().addYears(-historyYears);

    List<Account> accountsToInsert = new List<Account>();
    for (Integer i = 0; i < numberOfAccounts; i++) {
      String accountName = generateAccountName(i);
      Account acct = new Account(
        Name = accountName,
        Type = ACCOUNT_TYPES[Math.mod(i, ACCOUNT_TYPES.size())],
        Industry = INDUSTRIES[randomIndex(INDUSTRIES.size())],
        AnnualRevenue = generateRevenue(i),
        NumberOfEmployees = 25 + randomInt(4500),
        BillingStreet = '123 ' + accountName + ' Ave',
        BillingCity = CITIES[randomIndex(CITIES.size())],
        BillingState = STATES[randomIndex(STATES.size())],
        BillingPostalCode = String.valueOf(90000 + randomInt(9999)),
        BillingCountry = 'United States',
        Description = 'Generated account seeded for data cloud testing'
      );
      accountsToInsert.add(acct);
    }

    Database.SaveResult[] accountResults = Database.insert(
      accountsToInsert,
      false
    );
    List<Id> accountIds = new List<Id>();
    Map<Id, Account> accountById = new Map<Id, Account>();
    for (Integer idx = 0; idx < accountResults.size(); idx++) {
      Database.SaveResult sr = accountResults[idx];
      if (sr.isSuccess()) {
        Account insertedAccount = accountsToInsert[idx];
        insertedAccount.Id = sr.getId();
        accountIds.add(sr.getId());
        accountById.put(sr.getId(), insertedAccount);
      }
    }

    List<Contact> contactsToInsert = new List<Contact>();
    for (Id accountId : accountIds) {
      for (Integer c = 0; c < contactsPer; c++) {
        Contact con = new Contact(
          AccountId = accountId,
          FirstName = CONTACT_FIRST_NAMES[
            Math.mod(c, CONTACT_FIRST_NAMES.size())
          ],
          LastName = CONTACT_LAST_NAMES[
            Math.mod(
              randomInt(CONTACT_LAST_NAMES.size()),
              CONTACT_LAST_NAMES.size()
            )
          ],
          Email = generateEmail(accountById.get(accountId).Name, c),
          Phone = generatePhoneNumber(),
          Title = JOB_TITLES[Math.mod(c, JOB_TITLES.size())]
        );
        contactsToInsert.add(con);
      }
    }
    Integer contactsCreated = upsertRecords(contactsToInsert);

    List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
    Date baseCloseDate = startDate;
    for (Account acct : accountById.values()) {
      for (Integer o = 0; o < opportunitiesPer; o++) {
        Date closeDate = baseCloseDate.addDays(randomInt(historyYears * 365));
        Opportunity opp = new Opportunity(
          AccountId = acct.Id,
          Name = acct.Name + ' - ' + generateOpportunityName(o),
          StageName = STAGE_NAMES[Math.mod(o, STAGE_NAMES.size())],
          CloseDate = closeDate,
          Amount = generateOpportunityAmount(o),
          Type = Math.mod(o, 2) == 0 ? 'New Customer' : 'Existing Business',
          LeadSource = LEAD_SOURCES[
            Math.mod(randomInt(LEAD_SOURCES.size()), LEAD_SOURCES.size())
          ],
          Description = 'Generated opportunity seeded for pipeline history'
        );
        opportunitiesToInsert.add(opp);
      }
    }
    Integer opportunitiesCreated = upsertRecords(opportunitiesToInsert);

    SeedResult result = new SeedResult();
    result.accountsCreated = accountIds.size();
    result.contactsCreated = contactsCreated;
    result.opportunitiesCreated = opportunitiesCreated;
    return result;
  }

  private static Integer upsertRecords(List<SObject> records) {
    if (records.isEmpty()) {
      return 0;
    }
    Integer successCount = 0;
    Database.SaveResult[] results = Database.insert(records, false);
    for (Database.SaveResult sr : results) {
      if (sr.isSuccess()) {
        successCount++;
      }
    }
    return successCount;
  }

  private static String generateAccountName(Integer index) {
    List<String> companyPrefixes = new List<String>{
      'Acme',
      'Global',
      'Pioneer',
      'Summit',
      'Vertex',
      'Momentum',
      'Nimbus',
      'Apex'
    };
    List<String> companySuffixes = new List<String>{
      'Systems',
      'Solutions',
      'Industries',
      'Technologies',
      'Holdings',
      'Enterprises'
    };
    String prefix = companyPrefixes[Math.mod(index, companyPrefixes.size())];
    String suffix = companySuffixes[
      Math.mod(randomInt(companySuffixes.size()), companySuffixes.size())
    ];
    return prefix + ' ' + suffix + ' ' + String.valueOf(100 + index);
  }

  private static Decimal generateRevenue(Integer index) {
    Decimal base = 5000000 + (index * 1000000);
    Decimal variance = Decimal.valueOf(randomInt(2000000));
    return base + variance;
  }

  private static String generateEmail(String accountName, Integer counter) {
    String domain =
      accountName.replaceAll('[^A-Za-z0-9]', '').toLowerCase() + '.example.com';
    return 'user' + counter + '@' + domain;
  }

  private static String generatePhoneNumber() {
    Integer areaCode = 200 + randomInt(600);
    Integer prefix = 200 + randomInt(700);
    Integer lineNumber = 1000 + randomInt(9000);
    return '(' + areaCode + ') ' + prefix + '-' + lineNumber;
  }

  private static String generateOpportunityName(Integer index) {
    String theme = OPPORTUNITY_THEMES[
      Math.mod(index, OPPORTUNITY_THEMES.size())
    ];
    return theme + ' Deal';
  }

  private static Decimal generateOpportunityAmount(Integer index) {
    Integer multiplier = 1 + randomInt(20);
    return 25000 * multiplier + (index * 1000);
  }

  private static Integer randomInt(Integer upperExclusive) {
    if (upperExclusive == null || upperExclusive <= 0) {
      return 0;
    }
    Double randomValue = Math.random() * upperExclusive;
    return Integer.valueOf(Math.floor(randomValue));
  }

  private static Integer randomIndex(Integer size) {
    if (size == null || size == 0) {
      return 0;
    }
    return randomInt(size);
  }
}
