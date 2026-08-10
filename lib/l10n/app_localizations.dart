import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'JMoney'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get navHistory;

  /// No description provided for @navStats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get navStats;

  /// No description provided for @navManage.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý'**
  String get navManage;

  /// No description provided for @overview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan tài chính'**
  String get overview;

  /// No description provided for @totalBalance.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số dư'**
  String get totalBalance;

  /// No description provided for @thisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get thisMonth;

  /// No description provided for @previousMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng trước'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng sau'**
  String get nextMonth;

  /// No description provided for @income.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get expense;

  /// No description provided for @addTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch'**
  String get addTransaction;

  /// No description provided for @addIncome.
  ///
  /// In vi, this message translates to:
  /// **'Thêm thu nhập'**
  String get addIncome;

  /// No description provided for @addExpense.
  ///
  /// In vi, this message translates to:
  /// **'Thêm chi tiêu'**
  String get addExpense;

  /// No description provided for @moneyOut.
  ///
  /// In vi, this message translates to:
  /// **'Tiền ra'**
  String get moneyOut;

  /// No description provided for @moneyIn.
  ///
  /// In vi, this message translates to:
  /// **'Tiền vào'**
  String get moneyIn;

  /// No description provided for @chooseExpenseCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục để ghi khoản chi.'**
  String get chooseExpenseCategory;

  /// No description provided for @chooseIncomeCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nguồn của khoản thu.'**
  String get chooseIncomeCategory;

  /// No description provided for @incomeCategory.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn thu nhập'**
  String get incomeCategory;

  /// No description provided for @noIncomeCategories.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nguồn thu nhập'**
  String get noIncomeCategories;

  /// No description provided for @noIncomeCategoriesBody.
  ///
  /// In vi, this message translates to:
  /// **'Cần có ít nhất một nguồn thu nhập để ghi khoản thu.'**
  String get noIncomeCategoriesBody;

  /// No description provided for @incomeAllocationJars.
  ///
  /// In vi, this message translates to:
  /// **'Các hũ nhận tiền'**
  String get incomeAllocationJars;

  /// No description provided for @chooseSourceJar.
  ///
  /// In vi, this message translates to:
  /// **'Chọn hũ nguồn để chuyển tiền.'**
  String get chooseSourceJar;

  /// No description provided for @notEnoughJars.
  ///
  /// In vi, this message translates to:
  /// **'Cần thêm hũ'**
  String get notEnoughJars;

  /// No description provided for @notEnoughJarsBody.
  ///
  /// In vi, this message translates to:
  /// **'Cần ít nhất hai hũ để chuyển tiền.'**
  String get notEnoughJarsBody;

  /// No description provided for @yourJars.
  ///
  /// In vi, this message translates to:
  /// **'Các hũ của bạn'**
  String get yourJars;

  /// No description provided for @manageJars.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý hũ'**
  String get manageJars;

  /// No description provided for @recentTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch gần đây'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get seeAll;

  /// No description provided for @noTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch'**
  String get noTransactions;

  /// No description provided for @noTransactionsBody.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khoản thu đầu tiên để bắt đầu phân bổ tiền vào các hũ.'**
  String get noTransactionsBody;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @somethingWentWrong.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải dữ liệu. Hãy thử lại.'**
  String get somethingWentWrong;

  /// No description provided for @amount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get amount;

  /// No description provided for @amountHint.
  ///
  /// In vi, this message translates to:
  /// **'0 ₫'**
  String get amountHint;

  /// No description provided for @date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày giao dịch'**
  String get date;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả ngắn cho giao dịch'**
  String get noteHint;

  /// No description provided for @optional.
  ///
  /// In vi, this message translates to:
  /// **'Không bắt buộc'**
  String get optional;

  /// No description provided for @selectJar.
  ///
  /// In vi, this message translates to:
  /// **'Chọn hũ'**
  String get selectJar;

  /// No description provided for @selectCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục'**
  String get selectCategory;

  /// No description provided for @saveIncome.
  ///
  /// In vi, this message translates to:
  /// **'Lưu khoản thu'**
  String get saveIncome;

  /// No description provided for @saveExpense.
  ///
  /// In vi, this message translates to:
  /// **'Lưu khoản chi'**
  String get saveExpense;

  /// No description provided for @invalidAmount.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền lớn hơn 0'**
  String get invalidAmount;

  /// No description provided for @requiredField.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin này là bắt buộc'**
  String get requiredField;

  /// No description provided for @incomeDistributionHint.
  ///
  /// In vi, this message translates to:
  /// **'Khoản thu sẽ được chia tự động theo tỷ lệ hiện tại của các hũ.'**
  String get incomeDistributionHint;

  /// No description provided for @distributionPreview.
  ///
  /// In vi, this message translates to:
  /// **'Phân bổ dự kiến'**
  String get distributionPreview;

  /// No description provided for @normalizedFromTotal.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuẩn hóa từ tổng tỷ lệ {value}%'**
  String normalizedFromTotal(String value);

  /// No description provided for @invalidJarAllocation.
  ///
  /// In vi, this message translates to:
  /// **'Không thể chia thu nhập vì tổng tỷ lệ các hũ đang bằng 0%. Hãy chỉnh tỷ lệ hũ trước khi lưu.'**
  String get invalidJarAllocation;

  /// No description provided for @availableBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư hiện tại: {amount}'**
  String availableBalance(String amount);

  /// No description provided for @savedSuccessfully.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu giao dịch'**
  String get savedSuccessfully;

  /// No description provided for @saveFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu. Hãy kiểm tra thông tin và thử lại.'**
  String get saveFailed;

  /// No description provided for @historyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get historyTitle;

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @filterIncome.
  ///
  /// In vi, this message translates to:
  /// **'Khoản thu'**
  String get filterIncome;

  /// No description provided for @filterExpense.
  ///
  /// In vi, this message translates to:
  /// **'Khoản chi'**
  String get filterExpense;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa giao dịch?'**
  String get confirmDelete;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In vi, this message translates to:
  /// **'Số dư các hũ sẽ được hoàn tác theo giao dịch này.'**
  String get deleteTransactionMessage;

  /// No description provided for @transactionDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa giao dịch'**
  String get transactionDeleted;

  /// No description provided for @statsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get statsTitle;

  /// No description provided for @totalSpent.
  ///
  /// In vi, this message translates to:
  /// **'Tổng đã chi'**
  String get totalSpent;

  /// No description provided for @total.
  ///
  /// In vi, this message translates to:
  /// **'Tổng'**
  String get total;

  /// No description provided for @spendingByCategory.
  ///
  /// In vi, this message translates to:
  /// **'Theo danh mục'**
  String get spendingByCategory;

  /// No description provided for @noStats.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu chi tiêu'**
  String get noStats;

  /// No description provided for @noStatsBody.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê sẽ xuất hiện sau khi bạn ghi nhận khoản chi đầu tiên.'**
  String get noStatsBody;

  /// No description provided for @manageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý'**
  String get manageTitle;

  /// No description provided for @jarsSettings.
  ///
  /// In vi, this message translates to:
  /// **'Hũ tài chính'**
  String get jarsSettings;

  /// No description provided for @categoriesSettings.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục chi tiêu'**
  String get categoriesSettings;

  /// No description provided for @localStorageBody.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ dữ liệu được lưu cục bộ bằng MMKV trong vùng riêng của ứng dụng và không gửi lên máy chủ.'**
  String get localStorageBody;

  /// No description provided for @jarsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý hũ'**
  String get jarsTitle;

  /// No description provided for @allocationTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tỷ lệ: {value}%'**
  String allocationTotal(String value);

  /// No description provided for @allocationBalanced.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ đã cân bằng'**
  String get allocationBalanced;

  /// No description provided for @allocationMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Nên điều chỉnh tổng tỷ lệ về 100%. Thu nhập vẫn được chuẩn hóa theo tỷ lệ hiện tại.'**
  String get allocationMismatch;

  /// No description provided for @addJar.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hũ'**
  String get addJar;

  /// No description provided for @editJar.
  ///
  /// In vi, this message translates to:
  /// **'Sửa hũ'**
  String get editJar;

  /// No description provided for @jarName.
  ///
  /// In vi, this message translates to:
  /// **'Tên hũ'**
  String get jarName;

  /// No description provided for @jarDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả công dụng'**
  String get jarDescription;

  /// No description provided for @percentage.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ (%)'**
  String get percentage;

  /// No description provided for @color.
  ///
  /// In vi, this message translates to:
  /// **'Màu nhận diện'**
  String get color;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @deleteJarTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa hũ này?'**
  String get deleteJarTitle;

  /// No description provided for @deleteJarMessage.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục và giao dịch cũ sẽ không còn gắn với hũ. Thao tác này không thể hoàn tác.'**
  String get deleteJarMessage;

  /// No description provided for @cannotDeleteLastJar.
  ///
  /// In vi, this message translates to:
  /// **'Cần giữ lại ít nhất một hũ.'**
  String get cannotDeleteLastJar;

  /// No description provided for @cannotDeleteJarWithHistory.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa hũ đã có giao dịch. Hãy giữ hũ để bảo toàn số dư và lịch sử phân bổ.'**
  String get cannotDeleteJarWithHistory;

  /// No description provided for @jarSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu hũ'**
  String get jarSaved;

  /// No description provided for @jarDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa hũ'**
  String get jarDeleted;

  /// No description provided for @categoriesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục chi tiêu'**
  String get categoriesTitle;

  /// No description provided for @addCategory.
  ///
  /// In vi, this message translates to:
  /// **'Thêm danh mục'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In vi, this message translates to:
  /// **'Sửa danh mục'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In vi, this message translates to:
  /// **'Tên danh mục'**
  String get categoryName;

  /// No description provided for @categoryIcon.
  ///
  /// In vi, this message translates to:
  /// **'Biểu tượng'**
  String get categoryIcon;

  /// No description provided for @categoryIconHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn biểu tượng phù hợp với danh mục.'**
  String get categoryIconHint;

  /// No description provided for @categoryJar.
  ///
  /// In vi, this message translates to:
  /// **'Hũ áp dụng'**
  String get categoryJar;

  /// No description provided for @allJars.
  ///
  /// In vi, this message translates to:
  /// **'Dùng chung cho mọi hũ'**
  String get allJars;

  /// No description provided for @categoryCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} danh mục'**
  String categoryCount(int count);

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa danh mục này?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In vi, this message translates to:
  /// **'Các giao dịch cũ sẽ được giữ lại nhưng không còn gắn với danh mục.'**
  String get deleteCategoryMessage;

  /// No description provided for @categorySaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu danh mục'**
  String get categorySaved;

  /// No description provided for @categoryDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa danh mục'**
  String get categoryDeleted;

  /// No description provided for @noCategories.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có danh mục'**
  String get noCategories;

  /// No description provided for @noCategoriesBody.
  ///
  /// In vi, this message translates to:
  /// **'Tạo danh mục để mô tả chi tiết các khoản chi.'**
  String get noCategoriesBody;

  /// No description provided for @incomeTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get incomeTransaction;

  /// No description provided for @expenseTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get expenseTransaction;

  /// No description provided for @automaticAllocation.
  ///
  /// In vi, this message translates to:
  /// **'Tự động chia vào các hũ'**
  String get automaticAllocation;

  /// No description provided for @unknownCategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục đã xóa'**
  String get unknownCategory;

  /// No description provided for @unknownJar.
  ///
  /// In vi, this message translates to:
  /// **'Hũ đã xóa'**
  String get unknownJar;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @pickDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get pickDate;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @budgetSettings.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch ngân sách'**
  String get budgetSettings;

  /// No description provided for @goalsSettings.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu & quỹ dự phòng'**
  String get goalsSettings;

  /// No description provided for @recurringSettings.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch định kỳ'**
  String get recurringSettings;

  /// No description provided for @dataSettings.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu & khôi phục'**
  String get dataSettings;

  /// No description provided for @iconsByKoboyo.
  ///
  /// In vi, this message translates to:
  /// **'Biểu tượng bởi Koboyo'**
  String get iconsByKoboyo;

  /// No description provided for @cannotOpenLink.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở liên kết.'**
  String get cannotOpenLink;

  /// No description provided for @dangerZone.
  ///
  /// In vi, this message translates to:
  /// **'Vùng nguy hiểm'**
  String get dangerZone;

  /// No description provided for @resetAllData.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại toàn bộ dữ liệu'**
  String get resetAllData;

  /// No description provided for @resetAllDataTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại JMoney?'**
  String get resetAllDataTitle;

  /// No description provided for @resetAllDataMessage.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ giao dịch, số dư, mục tiêu, hạn mức, lịch định kỳ, tùy chỉnh và bản sao lưu cục bộ sẽ bị xóa. 4 hũ JMoney cùng danh mục mặc định sẽ được tạo lại. Thao tác này không thể hoàn tác.'**
  String get resetAllDataMessage;

  /// No description provided for @resetAllDataConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xóa và đặt lại'**
  String get resetAllDataConfirm;

  /// No description provided for @resetAllDataSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã đặt lại toàn bộ dữ liệu'**
  String get resetAllDataSuccess;

  /// No description provided for @resetAllDataFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể hoàn tất việc đặt lại dữ liệu. Hãy thử lại.'**
  String get resetAllDataFailed;

  /// No description provided for @budgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch ngân sách'**
  String get budgetTitle;

  /// No description provided for @budgetMethod.
  ///
  /// In vi, this message translates to:
  /// **'Phương pháp chia thu nhập'**
  String get budgetMethod;

  /// No description provided for @currentPlan.
  ///
  /// In vi, this message translates to:
  /// **'Đang áp dụng: {name}'**
  String currentPlan(String name);

  /// No description provided for @fourJarsPlan.
  ///
  /// In vi, this message translates to:
  /// **'4 hũ JMoney'**
  String get fourJarsPlan;

  /// No description provided for @fourJarsPlanBody.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên các nhu cầu cần thiết, đồng thời duy trì tích lũy, hưởng thụ và phát triển bản thân.'**
  String get fourJarsPlanBody;

  /// No description provided for @fourJarsRatio.
  ///
  /// In vi, this message translates to:
  /// **'55% · 25% · 10% · 10%'**
  String get fourJarsRatio;

  /// No description provided for @sixJarsPlan.
  ///
  /// In vi, this message translates to:
  /// **'Quy tắc 6 hũ'**
  String get sixJarsPlan;

  /// No description provided for @sixJarsPlanBody.
  ///
  /// In vi, this message translates to:
  /// **'Tách thu nhập theo sáu mục đích để cân bằng chi tiêu, tích lũy, đầu tư, học tập và sẻ chia.'**
  String get sixJarsPlanBody;

  /// No description provided for @sixJarsRatio.
  ///
  /// In vi, this message translates to:
  /// **'55% · 10% · 10% · 10% · 10% · 5%'**
  String get sixJarsRatio;

  /// No description provided for @fiftyPlan.
  ///
  /// In vi, this message translates to:
  /// **'Quy tắc 50/20/30'**
  String get fiftyPlan;

  /// No description provided for @fiftyPlanBody.
  ///
  /// In vi, this message translates to:
  /// **'Cách chia đơn giản giữa nhu cầu thiết yếu, mục tiêu tài chính và mong muốn cá nhân.'**
  String get fiftyPlanBody;

  /// No description provided for @fiftyPlanRatio.
  ///
  /// In vi, this message translates to:
  /// **'50% · 20% · 30%'**
  String get fiftyPlanRatio;

  /// No description provided for @jarMethodDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết các hũ'**
  String get jarMethodDetails;

  /// No description provided for @jarAllocationDetail.
  ///
  /// In vi, this message translates to:
  /// **'{percentage}% · {name}'**
  String jarAllocationDetail(String percentage, String name);

  /// No description provided for @customPlan.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh'**
  String get customPlan;

  /// No description provided for @applyPlan.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng phương pháp'**
  String get applyPlan;

  /// No description provided for @planApplied.
  ///
  /// In vi, this message translates to:
  /// **'Đã áp dụng phương pháp mới'**
  String get planApplied;

  /// No description provided for @templateWarning.
  ///
  /// In vi, this message translates to:
  /// **'Template sẽ cập nhật tên, tỷ lệ, màu và thứ tự; mô tả tự nhập vẫn được giữ. Hũ cũ có lịch sử không bị xóa.'**
  String get templateWarning;

  /// No description provided for @monthlyBudgets.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức tháng này'**
  String get monthlyBudgets;

  /// No description provided for @noBudgets.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đặt hạn mức'**
  String get noBudgets;

  /// No description provided for @noBudgetsBody.
  ///
  /// In vi, this message translates to:
  /// **'Đặt hạn mức cho từng hũ để theo dõi kế hoạch và mức nên chi mỗi ngày.'**
  String get noBudgetsBody;

  /// No description provided for @addBudget.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hạn mức'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In vi, this message translates to:
  /// **'Sửa hạn mức'**
  String get editBudget;

  /// No description provided for @budgetJar.
  ///
  /// In vi, this message translates to:
  /// **'Hũ áp dụng'**
  String get budgetJar;

  /// No description provided for @wholeJar.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ hũ'**
  String get wholeJar;

  /// No description provided for @plannedAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền dự kiến'**
  String get plannedAmount;

  /// No description provided for @budgetSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu hạn mức'**
  String get budgetSaved;

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa hạn mức này?'**
  String get deleteBudgetTitle;

  /// No description provided for @deleteBudgetMessage.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi chi tiêu tháng hiện tại cho hạn mức này sẽ bị xóa. Giao dịch không bị ảnh hưởng.'**
  String get deleteBudgetMessage;

  /// No description provided for @budgetDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa hạn mức'**
  String get budgetDeleted;

  /// No description provided for @copyPreviousMonth.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép ngân sách tháng trước'**
  String get copyPreviousMonth;

  /// No description provided for @includeRollover.
  ///
  /// In vi, this message translates to:
  /// **'Cộng phần ngân sách chưa dùng'**
  String get includeRollover;

  /// No description provided for @budgetsCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo ngân sách từ tháng trước'**
  String get budgetsCopied;

  /// No description provided for @planned.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch'**
  String get planned;

  /// No description provided for @spent.
  ///
  /// In vi, this message translates to:
  /// **'Đã chi'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn lại'**
  String get remaining;

  /// No description provided for @dailyAllowance.
  ///
  /// In vi, this message translates to:
  /// **'Nên chi mỗi ngày: {amount}'**
  String dailyAllowance(String amount);

  /// No description provided for @overBudget.
  ///
  /// In vi, this message translates to:
  /// **'Đã vượt hạn mức'**
  String get overBudget;

  /// No description provided for @budgetWarning70.
  ///
  /// In vi, this message translates to:
  /// **'Đã dùng hơn 70% hạn mức'**
  String get budgetWarning70;

  /// No description provided for @budgetWarning90.
  ///
  /// In vi, this message translates to:
  /// **'Sắp hết ngân sách tháng'**
  String get budgetWarning90;

  /// No description provided for @transferMoney.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển tiền giữa hũ'**
  String get transferMoney;

  /// No description provided for @sourceJar.
  ///
  /// In vi, this message translates to:
  /// **'Hũ nguồn'**
  String get sourceJar;

  /// No description provided for @destinationJar.
  ///
  /// In vi, this message translates to:
  /// **'Hũ nhận'**
  String get destinationJar;

  /// No description provided for @transferSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển tiền'**
  String get transferSaved;

  /// No description provided for @sameJarError.
  ///
  /// In vi, this message translates to:
  /// **'Hũ nguồn và hũ nhận phải khác nhau'**
  String get sameJarError;

  /// No description provided for @filterTransfer.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển hũ'**
  String get filterTransfer;

  /// No description provided for @searchTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo ghi chú hoặc nguồn tiền'**
  String get searchTransactions;

  /// No description provided for @transactionUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật giao dịch'**
  String get transactionUpdated;

  /// No description provided for @transferTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển hũ'**
  String get transferTransaction;

  /// No description provided for @fromTo.
  ///
  /// In vi, this message translates to:
  /// **'{source} → {destination}'**
  String fromTo(String source, String destination);

  /// No description provided for @accountSource.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn tiền'**
  String get accountSource;

  /// No description provided for @accountSourceHint.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt, ngân hàng hoặc ví điện tử'**
  String get accountSourceHint;

  /// No description provided for @distributionMode.
  ///
  /// In vi, this message translates to:
  /// **'Cách chia thu nhập'**
  String get distributionMode;

  /// No description provided for @automatic.
  ///
  /// In vi, this message translates to:
  /// **'Theo tỷ lệ'**
  String get automatic;

  /// No description provided for @equal.
  ///
  /// In vi, this message translates to:
  /// **'Chia đều'**
  String get equal;

  /// No description provided for @manual.
  ///
  /// In vi, this message translates to:
  /// **'Thủ công'**
  String get manual;

  /// No description provided for @selectedJars.
  ///
  /// In vi, this message translates to:
  /// **'Hũ nhận tiền'**
  String get selectedJars;

  /// No description provided for @splitAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền vào hũ'**
  String get splitAmount;

  /// No description provided for @allocationMustMatch.
  ///
  /// In vi, this message translates to:
  /// **'Tổng phân bổ phải bằng đúng khoản thu.'**
  String get allocationMustMatch;

  /// No description provided for @selectAtLeastOneJar.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ít nhất một hũ nhận tiền.'**
  String get selectAtLeastOneJar;

  /// No description provided for @budgetOverview.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch tháng'**
  String get budgetOverview;

  /// No description provided for @dueReminders.
  ///
  /// In vi, this message translates to:
  /// **'{count} khoản định kỳ đang chờ xác nhận'**
  String dueReminders(int count);

  /// No description provided for @reviewNow.
  ///
  /// In vi, this message translates to:
  /// **'Xem ngay'**
  String get reviewNow;

  /// No description provided for @goalsProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ mục tiêu'**
  String get goalsProgress;

  /// No description provided for @goalsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu tài chính'**
  String get goalsTitle;

  /// No description provided for @noGoals.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mục tiêu'**
  String get noGoals;

  /// No description provided for @noGoalsBody.
  ///
  /// In vi, this message translates to:
  /// **'Tạo một mục tiêu để biết mỗi tháng bạn cần dành ra bao nhiêu.'**
  String get noGoalsBody;

  /// No description provided for @addGoal.
  ///
  /// In vi, this message translates to:
  /// **'Thêm mục tiêu'**
  String get addGoal;

  /// No description provided for @editGoal.
  ///
  /// In vi, this message translates to:
  /// **'Sửa mục tiêu'**
  String get editGoal;

  /// No description provided for @goalName.
  ///
  /// In vi, this message translates to:
  /// **'Tên mục tiêu'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền mục tiêu'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In vi, this message translates to:
  /// **'Đã tích lũy'**
  String get currentAmount;

  /// No description provided for @deadline.
  ///
  /// In vi, this message translates to:
  /// **'Hạn hoàn thành'**
  String get deadline;

  /// No description provided for @priority.
  ///
  /// In vi, this message translates to:
  /// **'Mức ưu tiên'**
  String get priority;

  /// No description provided for @isEmergencyFund.
  ///
  /// In vi, this message translates to:
  /// **'Đây là quỹ dự phòng'**
  String get isEmergencyFund;

  /// No description provided for @emergencySuggestion.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý theo 6 tháng chi thiết yếu: {amount}'**
  String emergencySuggestion(String amount);

  /// No description provided for @goalSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu mục tiêu'**
  String get goalSaved;

  /// No description provided for @addContribution.
  ///
  /// In vi, this message translates to:
  /// **'Góp thêm'**
  String get addContribution;

  /// No description provided for @contribution.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền đóng góp'**
  String get contribution;

  /// No description provided for @goalCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt mục tiêu'**
  String get goalCompleted;

  /// No description provided for @monthlyContributionNeeded.
  ///
  /// In vi, this message translates to:
  /// **'Cần góp khoảng {amount}/tháng'**
  String monthlyContributionNeeded(String amount);

  /// No description provided for @deleteGoalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa mục tiêu?'**
  String get deleteGoalTitle;

  /// No description provided for @deleteGoalMessage.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử đóng góp của mục tiêu cũng sẽ bị xóa.'**
  String get deleteGoalMessage;

  /// No description provided for @recurringTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch định kỳ'**
  String get recurringTitle;

  /// No description provided for @noRecurring.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lịch định kỳ'**
  String get noRecurring;

  /// No description provided for @noRecurringBody.
  ///
  /// In vi, this message translates to:
  /// **'Tạo lịch cho lương, hóa đơn hoặc chuyển tiền giữa các hũ.'**
  String get noRecurringBody;

  /// No description provided for @addRecurring.
  ///
  /// In vi, this message translates to:
  /// **'Thêm lịch'**
  String get addRecurring;

  /// No description provided for @editRecurring.
  ///
  /// In vi, this message translates to:
  /// **'Sửa lịch'**
  String get editRecurring;

  /// No description provided for @ruleName.
  ///
  /// In vi, this message translates to:
  /// **'Tên lịch'**
  String get ruleName;

  /// No description provided for @transactionType.
  ///
  /// In vi, this message translates to:
  /// **'Loại giao dịch'**
  String get transactionType;

  /// No description provided for @frequency.
  ///
  /// In vi, this message translates to:
  /// **'Chu kỳ'**
  String get frequency;

  /// No description provided for @weekly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng tuần'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng tháng'**
  String get monthly;

  /// No description provided for @quarterly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng quý'**
  String get quarterly;

  /// No description provided for @yearly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng năm'**
  String get yearly;

  /// No description provided for @nextRun.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ tiếp theo'**
  String get nextRun;

  /// No description provided for @endDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc'**
  String get endDate;

  /// No description provided for @autoPost.
  ///
  /// In vi, this message translates to:
  /// **'Tự động ghi giao dịch'**
  String get autoPost;

  /// No description provided for @autoPostHint.
  ///
  /// In vi, this message translates to:
  /// **'Nếu tắt, giao dịch sẽ chờ bạn xác nhận trong app.'**
  String get autoPostHint;

  /// No description provided for @ruleSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu lịch định kỳ'**
  String get ruleSaved;

  /// No description provided for @deleteRuleTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch định kỳ?'**
  String get deleteRuleTitle;

  /// No description provided for @deleteRuleMessage.
  ///
  /// In vi, this message translates to:
  /// **'Các kỳ chưa ghi sẽ bị hủy. Giao dịch đã ghi vẫn được giữ lại.'**
  String get deleteRuleMessage;

  /// No description provided for @ruleDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa lịch định kỳ'**
  String get ruleDeleted;

  /// No description provided for @pendingTasks.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ xác nhận'**
  String get pendingTasks;

  /// No description provided for @confirmPost.
  ///
  /// In vi, this message translates to:
  /// **'Ghi giao dịch'**
  String get confirmPost;

  /// No description provided for @skip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get skip;

  /// No description provided for @enabled.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get enabled;

  /// No description provided for @occurrenceCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi giao dịch định kỳ'**
  String get occurrenceCompleted;

  /// No description provided for @dataTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu & khôi phục'**
  String get dataTitle;

  /// No description provided for @exportData.
  ///
  /// In vi, this message translates to:
  /// **'Xuất dữ liệu'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In vi, this message translates to:
  /// **'Nhập dữ liệu'**
  String get importData;

  /// No description provided for @copyBackup.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép JSON'**
  String get copyBackup;

  /// No description provided for @pasteJson.
  ///
  /// In vi, this message translates to:
  /// **'Dán snapshot JSON vào đây'**
  String get pasteJson;

  /// No description provided for @dataExported.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép dữ liệu vào clipboard'**
  String get dataExported;

  /// No description provided for @dataImported.
  ///
  /// In vi, this message translates to:
  /// **'Đã khôi phục dữ liệu'**
  String get dataImported;

  /// No description provided for @invalidBackup.
  ///
  /// In vi, this message translates to:
  /// **'Snapshot không hợp lệ hoặc không được hỗ trợ.'**
  String get invalidBackup;

  /// No description provided for @restoreWarning.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu hiện tại sẽ được sao lưu trước khi khôi phục snapshot này.'**
  String get restoreWarning;

  /// No description provided for @latestBackup.
  ///
  /// In vi, this message translates to:
  /// **'Bản sao lưu gần nhất'**
  String get latestBackup;

  /// No description provided for @noBackupAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bản sao lưu nào trên thiết bị.'**
  String get noBackupAvailable;

  /// No description provided for @backupRequired.
  ///
  /// In vi, this message translates to:
  /// **'Cần có snapshot JSON để khôi phục.'**
  String get backupRequired;

  /// No description provided for @hideBalance.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn số dư'**
  String get hideBalance;

  /// No description provided for @showBalance.
  ///
  /// In vi, this message translates to:
  /// **'Hiện số dư'**
  String get showBalance;

  /// No description provided for @storageStartupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở dữ liệu trên thiết bị'**
  String get storageStartupTitle;

  /// No description provided for @storageStartupBody.
  ///
  /// In vi, this message translates to:
  /// **'Hãy đóng và mở lại ứng dụng. Nếu lỗi vẫn còn, kiểm tra quyền lưu trữ của ứng dụng.'**
  String get storageStartupBody;

  /// No description provided for @notificationDue.
  ///
  /// In vi, this message translates to:
  /// **'Đến hạn {amount}'**
  String notificationDue(String amount);

  /// No description provided for @recurringChannelName.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch định kỳ'**
  String get recurringChannelName;

  /// No description provided for @recurringChannelDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc các khoản thu, chi và chuyển hũ đến hạn'**
  String get recurringChannelDescription;

  /// No description provided for @otherCategory.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get otherCategory;

  /// No description provided for @depositToJar.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền vào hũ'**
  String get depositToJar;

  /// No description provided for @currentBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư hiện tại'**
  String get currentBalance;

  /// No description provided for @directDepositHint.
  ///
  /// In vi, this message translates to:
  /// **'Khoản tiền này được nạp 100% vào hũ {jarName}.'**
  String directDepositHint(String jarName);

  /// No description provided for @jarActivity.
  ///
  /// In vi, this message translates to:
  /// **'Biến động số dư'**
  String get jarActivity;

  /// No description provided for @noJarActivity.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có biến động'**
  String get noJarActivity;

  /// No description provided for @noJarActivityBody.
  ///
  /// In vi, this message translates to:
  /// **'Các khoản nạp, chi tiêu và chuyển hũ sẽ xuất hiện tại đây.'**
  String get noJarActivityBody;

  /// No description provided for @jarIncomeActivity.
  ///
  /// In vi, this message translates to:
  /// **'Tiền vào hũ'**
  String get jarIncomeActivity;

  /// No description provided for @jarExpenseActivity.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu từ hũ'**
  String get jarExpenseActivity;

  /// No description provided for @jarTransferInActivity.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển vào hũ'**
  String get jarTransferInActivity;

  /// No description provided for @jarTransferOutActivity.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển khỏi hũ'**
  String get jarTransferOutActivity;

  /// No description provided for @jarTransferInFromActivity.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển từ hũ {jarName}'**
  String jarTransferInFromActivity(String jarName);

  /// No description provided for @jarTransferOutToActivity.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển đến hũ {jarName}'**
  String jarTransferOutToActivity(String jarName);

  /// No description provided for @balanceAfterActivity.
  ///
  /// In vi, this message translates to:
  /// **'Số dư sau giao dịch: {amount}'**
  String balanceAfterActivity(String amount);

  /// No description provided for @jarUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Hũ này không còn tồn tại.'**
  String get jarUnavailable;

  /// No description provided for @jarEssentials.
  ///
  /// In vi, this message translates to:
  /// **'Nhu cầu thiết yếu'**
  String get jarEssentials;

  /// No description provided for @jarEssentialsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chi cho nhà ở, điện nước, ăn uống, đi lại, bảo hiểm và y tế cơ bản.'**
  String get jarEssentialsDescription;

  /// No description provided for @jarSavingsInvestments.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm & Đầu tư'**
  String get jarSavingsInvestments;

  /// No description provided for @jarSavingsInvestmentsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tạo quỹ dự phòng, tiết kiệm mục tiêu, đầu tư dài hạn hoặc trả thêm nợ.'**
  String get jarSavingsInvestmentsDescription;

  /// No description provided for @jarEnjoyment.
  ///
  /// In vi, this message translates to:
  /// **'Hưởng thụ'**
  String get jarEnjoyment;

  /// No description provided for @jarEnjoymentDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chi cho giải trí, du lịch, ăn ngoài và những sở thích cá nhân trong giới hạn.'**
  String get jarEnjoymentDescription;

  /// No description provided for @jarEducationDevelopment.
  ///
  /// In vi, this message translates to:
  /// **'Giáo dục & Phát triển'**
  String get jarEducationDevelopment;

  /// No description provided for @jarEducationDevelopmentDescription.
  ///
  /// In vi, this message translates to:
  /// **'Đầu tư vào sách, khóa học, chứng chỉ và kỹ năng phục vụ tương lai.'**
  String get jarEducationDevelopmentDescription;

  /// No description provided for @jarLongTermSavings.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm dài hạn'**
  String get jarLongTermSavings;

  /// No description provided for @jarLongTermSavingsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Dành cho các mục tiêu lớn sẽ sử dụng trong tương lai như nhà, xe hoặc cưới hỏi.'**
  String get jarLongTermSavingsDescription;

  /// No description provided for @jarFinancialFreedom.
  ///
  /// In vi, this message translates to:
  /// **'Tự do tài chính'**
  String get jarFinancialFreedom;

  /// No description provided for @jarFinancialFreedomDescription.
  ///
  /// In vi, this message translates to:
  /// **'Xây dựng tài sản và nguồn thu nhập thụ động; không dùng cho chi tiêu thông thường.'**
  String get jarFinancialFreedomDescription;

  /// No description provided for @jarEducation.
  ///
  /// In vi, this message translates to:
  /// **'Giáo dục'**
  String get jarEducation;

  /// No description provided for @jarEducationDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chi cho việc học, sách, khóa học và nâng cao năng lực nghề nghiệp.'**
  String get jarEducationDescription;

  /// No description provided for @jarGiving.
  ///
  /// In vi, this message translates to:
  /// **'Thiện nguyện'**
  String get jarGiving;

  /// No description provided for @jarGivingDescription.
  ///
  /// In vi, this message translates to:
  /// **'Dành để làm từ thiện, giúp đỡ người thân hoặc đóng góp cho cộng đồng.'**
  String get jarGivingDescription;

  /// No description provided for @jarPersonalWants.
  ///
  /// In vi, this message translates to:
  /// **'Mong muốn cá nhân'**
  String get jarPersonalWants;

  /// No description provided for @jarPersonalWantsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chi cho ăn ngoài, giải trí, du lịch, dịch vụ đăng ký và mua sắm không thiết yếu.'**
  String get jarPersonalWantsDescription;

  /// No description provided for @categoryFood.
  ///
  /// In vi, this message translates to:
  /// **'Ăn uống'**
  String get categoryFood;

  /// No description provided for @categorySnacks.
  ///
  /// In vi, this message translates to:
  /// **'Ăn vặt'**
  String get categorySnacks;

  /// No description provided for @categoryChildren.
  ///
  /// In vi, this message translates to:
  /// **'Con cái'**
  String get categoryChildren;

  /// No description provided for @categoryShopping.
  ///
  /// In vi, this message translates to:
  /// **'Mua sắm'**
  String get categoryShopping;

  /// No description provided for @categoryCoffee.
  ///
  /// In vi, this message translates to:
  /// **'Cà phê'**
  String get categoryCoffee;

  /// No description provided for @categoryGroceries.
  ///
  /// In vi, this message translates to:
  /// **'Đi chợ'**
  String get categoryGroceries;

  /// No description provided for @categoryRent.
  ///
  /// In vi, this message translates to:
  /// **'Tiền nhà'**
  String get categoryRent;

  /// No description provided for @categoryUtilities.
  ///
  /// In vi, this message translates to:
  /// **'Điện nước'**
  String get categoryUtilities;

  /// No description provided for @categoryInternet.
  ///
  /// In vi, this message translates to:
  /// **'Internet'**
  String get categoryInternet;

  /// No description provided for @categoryPhone.
  ///
  /// In vi, this message translates to:
  /// **'Điện thoại'**
  String get categoryPhone;

  /// No description provided for @categoryFuel.
  ///
  /// In vi, this message translates to:
  /// **'Xăng xe'**
  String get categoryFuel;

  /// No description provided for @categoryTransport.
  ///
  /// In vi, this message translates to:
  /// **'Di chuyển'**
  String get categoryTransport;

  /// No description provided for @categoryHealthcare.
  ///
  /// In vi, this message translates to:
  /// **'Y tế'**
  String get categoryHealthcare;

  /// No description provided for @categoryBeauty.
  ///
  /// In vi, this message translates to:
  /// **'Làm đẹp'**
  String get categoryBeauty;

  /// No description provided for @categoryEntertainment.
  ///
  /// In vi, this message translates to:
  /// **'Giải trí'**
  String get categoryEntertainment;

  /// No description provided for @categoryHousingUtilities.
  ///
  /// In vi, this message translates to:
  /// **'Nhà cửa / Điện nước'**
  String get categoryHousingUtilities;

  /// No description provided for @categoryEssentialShopping.
  ///
  /// In vi, this message translates to:
  /// **'Mua sắm cần thiết'**
  String get categoryEssentialShopping;

  /// No description provided for @categoryBankSavings.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm ngân hàng'**
  String get categoryBankSavings;

  /// No description provided for @categoryStockInvestment.
  ///
  /// In vi, this message translates to:
  /// **'Đầu tư chứng khoán'**
  String get categoryStockInvestment;

  /// No description provided for @categoryEntertainmentCafe.
  ///
  /// In vi, this message translates to:
  /// **'Giải trí / Cafe'**
  String get categoryEntertainmentCafe;

  /// No description provided for @categoryTravel.
  ///
  /// In vi, this message translates to:
  /// **'Du lịch'**
  String get categoryTravel;

  /// No description provided for @categoryEducation.
  ///
  /// In vi, this message translates to:
  /// **'Học tập'**
  String get categoryEducation;

  /// No description provided for @categorySubscriptions.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký dịch vụ'**
  String get categorySubscriptions;

  /// No description provided for @categoryTechnology.
  ///
  /// In vi, this message translates to:
  /// **'Công nghệ'**
  String get categoryTechnology;

  /// No description provided for @categoryGifts.
  ///
  /// In vi, this message translates to:
  /// **'Quà tặng'**
  String get categoryGifts;

  /// No description provided for @categoryFamily.
  ///
  /// In vi, this message translates to:
  /// **'Gia đình'**
  String get categoryFamily;

  /// No description provided for @categoryOtherExpenses.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí khác'**
  String get categoryOtherExpenses;

  /// No description provided for @categoryCoursesBooks.
  ///
  /// In vi, this message translates to:
  /// **'Khóa học / Sách'**
  String get categoryCoursesBooks;

  /// No description provided for @categorySkillsWorkshop.
  ///
  /// In vi, this message translates to:
  /// **'Kỹ năng / Workshop'**
  String get categorySkillsWorkshop;

  /// No description provided for @incomeCategorySalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương chính'**
  String get incomeCategorySalary;

  /// No description provided for @incomeCategoryBonus.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng'**
  String get incomeCategoryBonus;

  /// No description provided for @incomeCategorySideJob.
  ///
  /// In vi, this message translates to:
  /// **'Làm thêm'**
  String get incomeCategorySideJob;

  /// No description provided for @incomeCategoryFreelance.
  ///
  /// In vi, this message translates to:
  /// **'Freelance'**
  String get incomeCategoryFreelance;

  /// No description provided for @incomeCategoryBusiness.
  ///
  /// In vi, this message translates to:
  /// **'Kinh doanh'**
  String get incomeCategoryBusiness;

  /// No description provided for @incomeCategoryInvestment.
  ///
  /// In vi, this message translates to:
  /// **'Đầu tư'**
  String get incomeCategoryInvestment;

  /// No description provided for @incomeCategoryOther.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập khác'**
  String get incomeCategoryOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
