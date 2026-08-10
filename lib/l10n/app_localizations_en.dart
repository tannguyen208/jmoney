// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'JMoney';

  @override
  String get navHome => 'Overview';

  @override
  String get navHistory => 'History';

  @override
  String get navStats => 'Statistics';

  @override
  String get navManage => 'Manage';

  @override
  String get overview => 'Financial overview';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get thisMonth => 'This month';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expenses';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get addIncome => 'Add income';

  @override
  String get addExpense => 'Add expense';

  @override
  String get moneyOut => 'Money out';

  @override
  String get moneyIn => 'Money in';

  @override
  String get chooseExpenseCategory => 'Choose a category to record an expense.';

  @override
  String get chooseIncomeCategory => 'Choose the source of this income.';

  @override
  String get incomeCategory => 'Income source';

  @override
  String get noIncomeCategories => 'No income sources yet';

  @override
  String get noIncomeCategoriesBody =>
      'At least one income source is required to record income.';

  @override
  String get incomeAllocationJars => 'Jars receiving income';

  @override
  String get chooseSourceJar => 'Choose the source jar for this transfer.';

  @override
  String get notEnoughJars => 'More jars needed';

  @override
  String get notEnoughJarsBody =>
      'At least two jars are required to transfer money.';

  @override
  String get yourJars => 'Your jars';

  @override
  String get manageJars => 'Manage jars';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get seeAll => 'See all';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get noTransactionsBody =>
      'Add your first income to start allocating money to your jars.';

  @override
  String get retry => 'Try again';

  @override
  String get somethingWentWrong =>
      'Could not load your data. Please try again.';

  @override
  String get amount => 'Amount';

  @override
  String get amountHint => '₫0';

  @override
  String get date => 'Transaction date';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'A short description for this transaction';

  @override
  String get optional => 'Optional';

  @override
  String get selectJar => 'Select a jar';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get saveIncome => 'Save income';

  @override
  String get saveExpense => 'Save expense';

  @override
  String get invalidAmount => 'Enter an amount greater than 0';

  @override
  String get requiredField => 'This field is required';

  @override
  String get incomeDistributionHint =>
      'Income is automatically split using the jars’ current percentages.';

  @override
  String get distributionPreview => 'Allocation preview';

  @override
  String normalizedFromTotal(String value) {
    return 'Normalized from a total allocation of $value%';
  }

  @override
  String get invalidJarAllocation =>
      'Income cannot be allocated because the total jar percentage is 0%. Adjust the jar percentages before saving.';

  @override
  String availableBalance(String amount) {
    return 'Current balance: $amount';
  }

  @override
  String get savedSuccessfully => 'Transaction saved';

  @override
  String get saveFailed => 'Could not save. Check the details and try again.';

  @override
  String get historyTitle => 'History';

  @override
  String get filterAll => 'All';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterExpense => 'Expenses';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDelete => 'Delete transaction?';

  @override
  String get deleteTransactionMessage =>
      'Jar balances will be reversed for this transaction.';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get spendingByCategory => 'By category';

  @override
  String get noStats => 'No spending data yet';

  @override
  String get noStatsBody =>
      'Statistics will appear after you record your first expense.';

  @override
  String get manageTitle => 'Manage';

  @override
  String get jarsSettings => 'Financial jars';

  @override
  String get categoriesSettings => 'Expense categories';

  @override
  String get localStorageBody =>
      'All data is stored locally with MMKV inside the app sandbox and is never sent to a server.';

  @override
  String get jarsTitle => 'Manage jars';

  @override
  String allocationTotal(String value) {
    return 'Total allocation: $value%';
  }

  @override
  String get allocationBalanced => 'Allocation is balanced';

  @override
  String get allocationMismatch =>
      'Consider adjusting the total to 100%. Income is still normalized using current percentages.';

  @override
  String get addJar => 'Add jar';

  @override
  String get editJar => 'Edit jar';

  @override
  String get jarName => 'Jar name';

  @override
  String get jarDescription => 'Purpose description';

  @override
  String get percentage => 'Percentage (%)';

  @override
  String get color => 'Identification color';

  @override
  String get save => 'Save';

  @override
  String get deleteJarTitle => 'Delete this jar?';

  @override
  String get deleteJarMessage =>
      'Past categories and transactions will no longer be linked to it. This cannot be undone.';

  @override
  String get cannotDeleteLastJar => 'At least one jar must remain.';

  @override
  String get cannotDeleteJarWithHistory =>
      'A jar with transactions cannot be deleted. Keep it to preserve balances and allocation history.';

  @override
  String get jarSaved => 'Jar saved';

  @override
  String get jarDeleted => 'Jar deleted';

  @override
  String get categoriesTitle => 'Expense categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categoryIconHint =>
      'Choose the icon that best matches the category.';

  @override
  String get categoryJar => 'Assigned jar';

  @override
  String get allJars => 'Available to all jars';

  @override
  String categoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
    );
    return '$_temp0';
  }

  @override
  String get deleteCategoryTitle => 'Delete this category?';

  @override
  String get deleteCategoryMessage =>
      'Past transactions remain but will no longer be linked to this category.';

  @override
  String get categorySaved => 'Category saved';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get noCategoriesBody =>
      'Create a category to describe expenses in detail.';

  @override
  String get incomeTransaction => 'Income';

  @override
  String get expenseTransaction => 'Expense';

  @override
  String get automaticAllocation => 'Automatically split into jars';

  @override
  String get unknownCategory => 'Deleted category';

  @override
  String get unknownJar => 'Deleted jar';

  @override
  String get today => 'Today';

  @override
  String get pickDate => 'Choose date';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get budgetSettings => 'Budget plan';

  @override
  String get goalsSettings => 'Goals & emergency fund';

  @override
  String get recurringSettings => 'Recurring transactions';

  @override
  String get dataSettings => 'Backup & restore';

  @override
  String get iconsByKoboyo => 'Icons by Koboyo';

  @override
  String get cannotOpenLink => 'Could not open the link.';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get resetAllData => 'Reset all data';

  @override
  String get resetAllDataTitle => 'Reset JMoney?';

  @override
  String get resetAllDataMessage =>
      'All transactions, balances, goals, limits, recurring schedules, customizations, and local backups will be deleted. The four default JMoney jars and categories will be created again. This cannot be undone.';

  @override
  String get resetAllDataConfirm => 'Delete and reset';

  @override
  String get resetAllDataSuccess => 'All data has been reset';

  @override
  String get resetAllDataFailed =>
      'The data reset could not be completed. Please try again.';

  @override
  String get budgetTitle => 'Budget plan';

  @override
  String get budgetMethod => 'Income allocation method';

  @override
  String currentPlan(String name) {
    return 'Active: $name';
  }

  @override
  String get fourJarsPlan => 'JMoney 4 jars';

  @override
  String get fourJarsPlanBody =>
      'Prioritize essentials while maintaining wealth building, enjoyment, and personal growth.';

  @override
  String get fourJarsRatio => '55% · 25% · 10% · 10%';

  @override
  String get sixJarsPlan => '6-jar rule';

  @override
  String get sixJarsPlanBody =>
      'Separate income into six purposes to balance spending, saving, investing, learning, and giving.';

  @override
  String get sixJarsRatio => '55% · 10% · 10% · 10% · 10% · 5%';

  @override
  String get fiftyPlan => '50/20/30 rule';

  @override
  String get fiftyPlanBody =>
      'A simple split between needs, financial goals, and personal wants.';

  @override
  String get fiftyPlanRatio => '50% · 20% · 30%';

  @override
  String get jarMethodDetails => 'Jar details';

  @override
  String jarAllocationDetail(String percentage, String name) {
    return '$percentage% · $name';
  }

  @override
  String get customPlan => 'Custom';

  @override
  String get applyPlan => 'Apply method';

  @override
  String get planApplied => 'New method applied';

  @override
  String get templateWarning =>
      'The template updates names, percentages, colors, and order; your own descriptions are preserved. Existing jars with history are never deleted.';

  @override
  String get monthlyBudgets => 'This month\'s limits';

  @override
  String get noBudgets => 'No limits yet';

  @override
  String get noBudgetsBody =>
      'Set a limit for each jar to track your plan and daily allowance.';

  @override
  String get addBudget => 'Add limit';

  @override
  String get editBudget => 'Edit limit';

  @override
  String get budgetJar => 'Assigned jar';

  @override
  String get wholeJar => 'Entire jar';

  @override
  String get plannedAmount => 'Planned amount';

  @override
  String get budgetSaved => 'Limit saved';

  @override
  String get deleteBudgetTitle => 'Delete this limit?';

  @override
  String get deleteBudgetMessage =>
      'Tracking for this limit in the current month will be removed. Transactions are not affected.';

  @override
  String get budgetDeleted => 'Limit deleted';

  @override
  String get copyPreviousMonth => 'Copy last month\'s budgets';

  @override
  String get includeRollover => 'Include unused budget';

  @override
  String get budgetsCopied => 'Budgets copied from last month';

  @override
  String get planned => 'Planned';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String dailyAllowance(String amount) {
    return 'Daily allowance: $amount';
  }

  @override
  String get overBudget => 'Limit exceeded';

  @override
  String get budgetWarning70 => 'More than 70% of the limit used';

  @override
  String get budgetWarning90 => 'Monthly budget is almost gone';

  @override
  String get transferMoney => 'Transfer between jars';

  @override
  String get sourceJar => 'Source jar';

  @override
  String get destinationJar => 'Destination jar';

  @override
  String get transferSaved => 'Money transferred';

  @override
  String get sameJarError => 'Source and destination jars must be different';

  @override
  String get filterTransfer => 'Transfers';

  @override
  String get searchTransactions => 'Search notes or money source';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transferTransaction => 'Jar transfer';

  @override
  String fromTo(String source, String destination) {
    return '$source → $destination';
  }

  @override
  String get accountSource => 'Money source';

  @override
  String get accountSourceHint => 'Cash, bank, or e-wallet';

  @override
  String get distributionMode => 'Income allocation';

  @override
  String get automatic => 'By percentage';

  @override
  String get equal => 'Equal split';

  @override
  String get manual => 'Manual';

  @override
  String get selectedJars => 'Receiving jars';

  @override
  String get splitAmount => 'Amount for jar';

  @override
  String get allocationMustMatch =>
      'Allocations must add up to the income amount.';

  @override
  String get selectAtLeastOneJar => 'Select at least one receiving jar.';

  @override
  String get budgetOverview => 'Monthly plan';

  @override
  String dueReminders(int count) {
    return '$count recurring items await confirmation';
  }

  @override
  String get reviewNow => 'Review';

  @override
  String get goalsProgress => 'Goal progress';

  @override
  String get goalsTitle => 'Financial goals';

  @override
  String get noGoals => 'No goals yet';

  @override
  String get noGoalsBody =>
      'Create a goal to see how much you need to set aside each month.';

  @override
  String get addGoal => 'Add goal';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get currentAmount => 'Saved so far';

  @override
  String get deadline => 'Deadline';

  @override
  String get priority => 'Priority';

  @override
  String get isEmergencyFund => 'This is an emergency fund';

  @override
  String emergencySuggestion(String amount) {
    return 'Suggested from 6 months of essentials: $amount';
  }

  @override
  String get goalSaved => 'Goal saved';

  @override
  String get addContribution => 'Add contribution';

  @override
  String get contribution => 'Contribution amount';

  @override
  String get goalCompleted => 'Goal reached';

  @override
  String monthlyContributionNeeded(String amount) {
    return 'Set aside about $amount/month';
  }

  @override
  String get deleteGoalTitle => 'Delete goal?';

  @override
  String get deleteGoalMessage =>
      'The goal\'s contribution history will also be deleted.';

  @override
  String get recurringTitle => 'Recurring transactions';

  @override
  String get noRecurring => 'No recurring schedules';

  @override
  String get noRecurringBody =>
      'Create a schedule for salary, bills, or transfers between jars.';

  @override
  String get addRecurring => 'Add schedule';

  @override
  String get editRecurring => 'Edit schedule';

  @override
  String get ruleName => 'Schedule name';

  @override
  String get transactionType => 'Transaction type';

  @override
  String get frequency => 'Frequency';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get yearly => 'Yearly';

  @override
  String get nextRun => 'Next occurrence';

  @override
  String get endDate => 'End date';

  @override
  String get autoPost => 'Post automatically';

  @override
  String get autoPostHint =>
      'When off, the transaction waits for your confirmation in the app.';

  @override
  String get ruleSaved => 'Recurring schedule saved';

  @override
  String get deleteRuleTitle => 'Delete recurring schedule?';

  @override
  String get deleteRuleMessage =>
      'Unposted occurrences will be canceled. Posted transactions are kept.';

  @override
  String get ruleDeleted => 'Recurring schedule deleted';

  @override
  String get pendingTasks => 'Awaiting confirmation';

  @override
  String get confirmPost => 'Post transaction';

  @override
  String get skip => 'Skip';

  @override
  String get enabled => 'Active';

  @override
  String get occurrenceCompleted => 'Recurring transaction posted';

  @override
  String get dataTitle => 'Backup & restore';

  @override
  String get exportData => 'Export data';

  @override
  String get importData => 'Import data';

  @override
  String get copyBackup => 'Copy JSON';

  @override
  String get pasteJson => 'Paste a JSON snapshot here';

  @override
  String get dataExported => 'Data copied to the clipboard';

  @override
  String get dataImported => 'Data restored';

  @override
  String get invalidBackup => 'The snapshot is invalid or unsupported.';

  @override
  String get restoreWarning =>
      'Current data will be backed up before this snapshot is restored.';

  @override
  String get latestBackup => 'Latest backup';

  @override
  String get noBackupAvailable => 'No on-device backup is available yet.';

  @override
  String get backupRequired => 'A JSON snapshot is required to restore data.';

  @override
  String get hideBalance => 'Hide balance';

  @override
  String get showBalance => 'Show balance';

  @override
  String get storageStartupTitle => 'Unable to open on-device data';

  @override
  String get storageStartupBody =>
      'Close and reopen the app. If the problem persists, check the app\'s storage permission.';

  @override
  String notificationDue(String amount) {
    return 'Due: $amount';
  }

  @override
  String get recurringChannelName => 'Recurring transactions';

  @override
  String get recurringChannelDescription =>
      'Reminders for due income, expenses, and jar transfers';

  @override
  String get otherCategory => 'Other';

  @override
  String get depositToJar => 'Add money to jar';

  @override
  String get currentBalance => 'Current balance';

  @override
  String directDepositHint(String jarName) {
    return 'This amount will be added entirely to the $jarName jar.';
  }

  @override
  String get jarActivity => 'Balance activity';

  @override
  String get noJarActivity => 'No activity yet';

  @override
  String get noJarActivityBody =>
      'Deposits, expenses, and jar transfers will appear here.';

  @override
  String get jarIncomeActivity => 'Money added';

  @override
  String get jarExpenseActivity => 'Expense from jar';

  @override
  String get jarTransferInActivity => 'Transfer into jar';

  @override
  String get jarTransferOutActivity => 'Transfer out of jar';

  @override
  String jarTransferInFromActivity(String jarName) {
    return 'Transfer from $jarName';
  }

  @override
  String jarTransferOutToActivity(String jarName) {
    return 'Transfer to $jarName';
  }

  @override
  String balanceAfterActivity(String amount) {
    return 'Balance after transaction: $amount';
  }

  @override
  String get jarUnavailable => 'This jar no longer exists.';

  @override
  String get jarEssentials => 'Essentials';

  @override
  String get jarEssentialsDescription =>
      'Housing, utilities, food, transport, insurance, and basic healthcare.';

  @override
  String get jarSavingsInvestments => 'Savings & investments';

  @override
  String get jarSavingsInvestmentsDescription =>
      'Build an emergency fund, save for goals, invest long term, or repay extra debt.';

  @override
  String get jarEnjoyment => 'Enjoyment';

  @override
  String get jarEnjoymentDescription =>
      'Entertainment, travel, dining out, and personal interests within this limit.';

  @override
  String get jarEducationDevelopment => 'Education & growth';

  @override
  String get jarEducationDevelopmentDescription =>
      'Books, courses, certifications, and skills that support your future.';

  @override
  String get jarLongTermSavings => 'Long-term savings';

  @override
  String get jarLongTermSavingsDescription =>
      'Large future goals that you plan to spend on, such as a home, car, or wedding.';

  @override
  String get jarFinancialFreedom => 'Financial freedom';

  @override
  String get jarFinancialFreedomDescription =>
      'Build assets and passive income; avoid using this jar for regular spending.';

  @override
  String get jarEducation => 'Education';

  @override
  String get jarEducationDescription =>
      'Learning, books, courses, and professional development.';

  @override
  String get jarGiving => 'Giving';

  @override
  String get jarGivingDescription =>
      'Charity, helping family, or contributing to your community.';

  @override
  String get jarPersonalWants => 'Personal wants';

  @override
  String get jarPersonalWantsDescription =>
      'Dining out, entertainment, travel, subscriptions, and non-essential shopping.';

  @override
  String get categoryFood => 'Food';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryChildren => 'Children';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryCoffee => 'Coffee';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryInternet => 'Internet';

  @override
  String get categoryPhone => 'Phone';

  @override
  String get categoryFuel => 'Fuel';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryHealthcare => 'Healthcare';

  @override
  String get categoryBeauty => 'Beauty';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHousingUtilities => 'Housing & utilities';

  @override
  String get categoryEssentialShopping => 'Essential shopping';

  @override
  String get categoryBankSavings => 'Bank savings';

  @override
  String get categoryStockInvestment => 'Stock investments';

  @override
  String get categoryEntertainmentCafe => 'Entertainment & cafés';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categorySubscriptions => 'Service subscriptions';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categoryFamily => 'Family';

  @override
  String get categoryOtherExpenses => 'Other expenses';

  @override
  String get categoryCoursesBooks => 'Courses & books';

  @override
  String get categorySkillsWorkshop => 'Skills & workshops';

  @override
  String get incomeCategorySalary => 'Primary salary';

  @override
  String get incomeCategoryBonus => 'Bonus';

  @override
  String get incomeCategorySideJob => 'Side job';

  @override
  String get incomeCategoryFreelance => 'Freelance';

  @override
  String get incomeCategoryBusiness => 'Business';

  @override
  String get incomeCategoryInvestment => 'Investments';

  @override
  String get incomeCategoryOther => 'Other income';
}
