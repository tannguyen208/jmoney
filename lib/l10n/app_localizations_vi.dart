// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'JMoney';

  @override
  String get navHome => 'Tổng quan';

  @override
  String get navHistory => 'Lịch sử';

  @override
  String get navStats => 'Thống kê';

  @override
  String get navManage => 'Quản lý';

  @override
  String get overview => 'Tổng quan tài chính';

  @override
  String get totalBalance => 'Tổng số dư';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get previousMonth => 'Tháng trước';

  @override
  String get nextMonth => 'Tháng sau';

  @override
  String get income => 'Thu nhập';

  @override
  String get expense => 'Chi tiêu';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String get addIncome => 'Thêm thu nhập';

  @override
  String get addExpense => 'Thêm chi tiêu';

  @override
  String get moneyOut => 'Tiền ra';

  @override
  String get moneyIn => 'Tiền vào';

  @override
  String get chooseExpenseCategory => 'Chọn danh mục để ghi khoản chi.';

  @override
  String get chooseIncomeCategory => 'Chọn nguồn của khoản thu.';

  @override
  String get incomeCategory => 'Nguồn thu nhập';

  @override
  String get noIncomeCategories => 'Chưa có nguồn thu nhập';

  @override
  String get noIncomeCategoriesBody =>
      'Cần có ít nhất một nguồn thu nhập để ghi khoản thu.';

  @override
  String get incomeAllocationJars => 'Các hũ nhận tiền';

  @override
  String get chooseSourceJar => 'Chọn hũ nguồn để chuyển tiền.';

  @override
  String get notEnoughJars => 'Cần thêm hũ';

  @override
  String get notEnoughJarsBody => 'Cần ít nhất hai hũ để chuyển tiền.';

  @override
  String get yourJars => 'Các hũ của bạn';

  @override
  String get manageJars => 'Quản lý hũ';

  @override
  String get recentTransactions => 'Giao dịch gần đây';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get noTransactions => 'Chưa có giao dịch';

  @override
  String get noTransactionsBody =>
      'Thêm khoản thu đầu tiên để bắt đầu phân bổ tiền vào các hũ.';

  @override
  String get retry => 'Thử lại';

  @override
  String get somethingWentWrong => 'Không thể tải dữ liệu. Hãy thử lại.';

  @override
  String get amount => 'Số tiền';

  @override
  String get amountHint => '0 ₫';

  @override
  String get date => 'Ngày giao dịch';

  @override
  String get note => 'Ghi chú';

  @override
  String get noteHint => 'Mô tả ngắn cho giao dịch';

  @override
  String get optional => 'Không bắt buộc';

  @override
  String get selectJar => 'Chọn hũ';

  @override
  String get selectCategory => 'Chọn danh mục';

  @override
  String get saveIncome => 'Lưu khoản thu';

  @override
  String get saveExpense => 'Lưu khoản chi';

  @override
  String get invalidAmount => 'Nhập số tiền lớn hơn 0';

  @override
  String get requiredField => 'Thông tin này là bắt buộc';

  @override
  String get incomeDistributionHint =>
      'Khoản thu sẽ được chia tự động theo tỷ lệ hiện tại của các hũ.';

  @override
  String get distributionPreview => 'Phân bổ dự kiến';

  @override
  String normalizedFromTotal(String value) {
    return 'Đã chuẩn hóa từ tổng tỷ lệ $value%';
  }

  @override
  String get invalidJarAllocation =>
      'Không thể chia thu nhập vì tổng tỷ lệ các hũ đang bằng 0%. Hãy chỉnh tỷ lệ hũ trước khi lưu.';

  @override
  String availableBalance(String amount) {
    return 'Số dư hiện tại: $amount';
  }

  @override
  String get savedSuccessfully => 'Đã lưu giao dịch';

  @override
  String get saveFailed => 'Không thể lưu. Hãy kiểm tra thông tin và thử lại.';

  @override
  String get historyTitle => 'Lịch sử';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterIncome => 'Khoản thu';

  @override
  String get filterExpense => 'Khoản chi';

  @override
  String get delete => 'Xóa';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirmDelete => 'Xóa giao dịch?';

  @override
  String get deleteTransactionMessage =>
      'Số dư các hũ sẽ được hoàn tác theo giao dịch này.';

  @override
  String get transactionDeleted => 'Đã xóa giao dịch';

  @override
  String get statsTitle => 'Thống kê';

  @override
  String get totalSpent => 'Tổng đã chi';

  @override
  String get total => 'Tổng';

  @override
  String get spendingByCategory => 'Theo danh mục';

  @override
  String get noStats => 'Chưa có dữ liệu chi tiêu';

  @override
  String get noStatsBody =>
      'Thống kê sẽ xuất hiện sau khi bạn ghi nhận khoản chi đầu tiên.';

  @override
  String get manageTitle => 'Quản lý';

  @override
  String get jarsSettings => 'Hũ tài chính';

  @override
  String get categoriesSettings => 'Danh mục chi tiêu';

  @override
  String get localStorageBody =>
      'Toàn bộ dữ liệu được lưu cục bộ bằng MMKV trong vùng riêng của ứng dụng và không gửi lên máy chủ.';

  @override
  String get jarsTitle => 'Quản lý hũ';

  @override
  String allocationTotal(String value) {
    return 'Tổng tỷ lệ: $value%';
  }

  @override
  String get allocationBalanced => 'Tỷ lệ đã cân bằng';

  @override
  String get allocationMismatch =>
      'Nên điều chỉnh tổng tỷ lệ về 100%. Thu nhập vẫn được chuẩn hóa theo tỷ lệ hiện tại.';

  @override
  String get addJar => 'Thêm hũ';

  @override
  String get editJar => 'Sửa hũ';

  @override
  String get jarName => 'Tên hũ';

  @override
  String get jarDescription => 'Mô tả công dụng';

  @override
  String get percentage => 'Tỷ lệ (%)';

  @override
  String get color => 'Màu nhận diện';

  @override
  String get save => 'Lưu';

  @override
  String get deleteJarTitle => 'Xóa hũ này?';

  @override
  String get deleteJarMessage =>
      'Danh mục và giao dịch cũ sẽ không còn gắn với hũ. Thao tác này không thể hoàn tác.';

  @override
  String get cannotDeleteLastJar => 'Cần giữ lại ít nhất một hũ.';

  @override
  String get cannotDeleteJarWithHistory =>
      'Không thể xóa hũ đã có giao dịch. Hãy giữ hũ để bảo toàn số dư và lịch sử phân bổ.';

  @override
  String get jarSaved => 'Đã lưu hũ';

  @override
  String get jarDeleted => 'Đã xóa hũ';

  @override
  String get categoriesTitle => 'Danh mục chi tiêu';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get editCategory => 'Sửa danh mục';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get categoryIcon => 'Biểu tượng';

  @override
  String get categoryIconHint => 'Chọn biểu tượng phù hợp với danh mục.';

  @override
  String get categoryJar => 'Hũ áp dụng';

  @override
  String get allJars => 'Dùng chung cho mọi hũ';

  @override
  String categoryCount(int count) {
    return '$count danh mục';
  }

  @override
  String get deleteCategoryTitle => 'Xóa danh mục này?';

  @override
  String get deleteCategoryMessage =>
      'Các giao dịch cũ sẽ được giữ lại nhưng không còn gắn với danh mục.';

  @override
  String get categorySaved => 'Đã lưu danh mục';

  @override
  String get categoryDeleted => 'Đã xóa danh mục';

  @override
  String get noCategories => 'Chưa có danh mục';

  @override
  String get noCategoriesBody =>
      'Tạo danh mục để mô tả chi tiết các khoản chi.';

  @override
  String get incomeTransaction => 'Thu nhập';

  @override
  String get expenseTransaction => 'Chi tiêu';

  @override
  String get automaticAllocation => 'Tự động chia vào các hũ';

  @override
  String get unknownCategory => 'Danh mục đã xóa';

  @override
  String get unknownJar => 'Hũ đã xóa';

  @override
  String get today => 'Hôm nay';

  @override
  String get pickDate => 'Chọn ngày';

  @override
  String get close => 'Đóng';

  @override
  String get edit => 'Sửa';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get budgetSettings => 'Kế hoạch ngân sách';

  @override
  String get goalsSettings => 'Mục tiêu & quỹ dự phòng';

  @override
  String get recurringSettings => 'Giao dịch định kỳ';

  @override
  String get dataSettings => 'Sao lưu & khôi phục';

  @override
  String get iconsByKoboyo => 'Biểu tượng bởi Koboyo';

  @override
  String get cannotOpenLink => 'Không thể mở liên kết.';

  @override
  String get dangerZone => 'Vùng nguy hiểm';

  @override
  String get resetAllData => 'Đặt lại toàn bộ dữ liệu';

  @override
  String get resetAllDataTitle => 'Đặt lại JMoney?';

  @override
  String get resetAllDataMessage =>
      'Toàn bộ giao dịch, số dư, mục tiêu, hạn mức, lịch định kỳ, tùy chỉnh và bản sao lưu cục bộ sẽ bị xóa. 4 hũ JMoney cùng danh mục mặc định sẽ được tạo lại. Thao tác này không thể hoàn tác.';

  @override
  String get resetAllDataConfirm => 'Xóa và đặt lại';

  @override
  String get resetAllDataSuccess => 'Đã đặt lại toàn bộ dữ liệu';

  @override
  String get resetAllDataFailed =>
      'Không thể hoàn tất việc đặt lại dữ liệu. Hãy thử lại.';

  @override
  String get budgetTitle => 'Kế hoạch ngân sách';

  @override
  String get budgetMethod => 'Phương pháp chia thu nhập';

  @override
  String currentPlan(String name) {
    return 'Đang áp dụng: $name';
  }

  @override
  String get fourJarsPlan => '4 hũ JMoney';

  @override
  String get fourJarsPlanBody =>
      'Ưu tiên các nhu cầu cần thiết, đồng thời duy trì tích lũy, hưởng thụ và phát triển bản thân.';

  @override
  String get fourJarsRatio => '55% · 25% · 10% · 10%';

  @override
  String get sixJarsPlan => 'Quy tắc 6 hũ';

  @override
  String get sixJarsPlanBody =>
      'Tách thu nhập theo sáu mục đích để cân bằng chi tiêu, tích lũy, đầu tư, học tập và sẻ chia.';

  @override
  String get sixJarsRatio => '55% · 10% · 10% · 10% · 10% · 5%';

  @override
  String get fiftyPlan => 'Quy tắc 50/20/30';

  @override
  String get fiftyPlanBody =>
      'Cách chia đơn giản giữa nhu cầu thiết yếu, mục tiêu tài chính và mong muốn cá nhân.';

  @override
  String get fiftyPlanRatio => '50% · 20% · 30%';

  @override
  String get jarMethodDetails => 'Chi tiết các hũ';

  @override
  String jarAllocationDetail(String percentage, String name) {
    return '$percentage% · $name';
  }

  @override
  String get customPlan => 'Tùy chỉnh';

  @override
  String get applyPlan => 'Áp dụng phương pháp';

  @override
  String get planApplied => 'Đã áp dụng phương pháp mới';

  @override
  String get templateWarning =>
      'Template sẽ cập nhật tên, tỷ lệ, màu và thứ tự; mô tả tự nhập vẫn được giữ. Hũ cũ có lịch sử không bị xóa.';

  @override
  String get monthlyBudgets => 'Hạn mức tháng này';

  @override
  String get noBudgets => 'Chưa đặt hạn mức';

  @override
  String get noBudgetsBody =>
      'Đặt hạn mức cho từng hũ để theo dõi kế hoạch và mức nên chi mỗi ngày.';

  @override
  String get addBudget => 'Thêm hạn mức';

  @override
  String get editBudget => 'Sửa hạn mức';

  @override
  String get budgetJar => 'Hũ áp dụng';

  @override
  String get wholeJar => 'Toàn bộ hũ';

  @override
  String get plannedAmount => 'Số tiền dự kiến';

  @override
  String get budgetSaved => 'Đã lưu hạn mức';

  @override
  String get deleteBudgetTitle => 'Xóa hạn mức này?';

  @override
  String get deleteBudgetMessage =>
      'Theo dõi chi tiêu tháng hiện tại cho hạn mức này sẽ bị xóa. Giao dịch không bị ảnh hưởng.';

  @override
  String get budgetDeleted => 'Đã xóa hạn mức';

  @override
  String get copyPreviousMonth => 'Sao chép ngân sách tháng trước';

  @override
  String get includeRollover => 'Cộng phần ngân sách chưa dùng';

  @override
  String get budgetsCopied => 'Đã tạo ngân sách từ tháng trước';

  @override
  String get planned => 'Kế hoạch';

  @override
  String get spent => 'Đã chi';

  @override
  String get remaining => 'Còn lại';

  @override
  String dailyAllowance(String amount) {
    return 'Nên chi mỗi ngày: $amount';
  }

  @override
  String get overBudget => 'Đã vượt hạn mức';

  @override
  String get budgetWarning70 => 'Đã dùng hơn 70% hạn mức';

  @override
  String get budgetWarning90 => 'Sắp hết ngân sách tháng';

  @override
  String get transferMoney => 'Chuyển tiền giữa hũ';

  @override
  String get sourceJar => 'Hũ nguồn';

  @override
  String get destinationJar => 'Hũ nhận';

  @override
  String get transferSaved => 'Đã chuyển tiền';

  @override
  String get sameJarError => 'Hũ nguồn và hũ nhận phải khác nhau';

  @override
  String get filterTransfer => 'Chuyển hũ';

  @override
  String get searchTransactions => 'Tìm theo ghi chú hoặc nguồn tiền';

  @override
  String get transactionUpdated => 'Đã cập nhật giao dịch';

  @override
  String get transferTransaction => 'Chuyển hũ';

  @override
  String fromTo(String source, String destination) {
    return '$source → $destination';
  }

  @override
  String get accountSource => 'Nguồn tiền';

  @override
  String get accountSourceHint => 'Tiền mặt, ngân hàng hoặc ví điện tử';

  @override
  String get distributionMode => 'Cách chia thu nhập';

  @override
  String get automatic => 'Theo tỷ lệ';

  @override
  String get equal => 'Chia đều';

  @override
  String get manual => 'Thủ công';

  @override
  String get selectedJars => 'Hũ nhận tiền';

  @override
  String get splitAmount => 'Số tiền vào hũ';

  @override
  String get allocationMustMatch => 'Tổng phân bổ phải bằng đúng khoản thu.';

  @override
  String get selectAtLeastOneJar => 'Chọn ít nhất một hũ nhận tiền.';

  @override
  String get budgetOverview => 'Kế hoạch tháng';

  @override
  String dueReminders(int count) {
    return '$count khoản định kỳ đang chờ xác nhận';
  }

  @override
  String get reviewNow => 'Xem ngay';

  @override
  String get goalsProgress => 'Tiến độ mục tiêu';

  @override
  String get goalsTitle => 'Mục tiêu tài chính';

  @override
  String get noGoals => 'Chưa có mục tiêu';

  @override
  String get noGoalsBody =>
      'Tạo một mục tiêu để biết mỗi tháng bạn cần dành ra bao nhiêu.';

  @override
  String get addGoal => 'Thêm mục tiêu';

  @override
  String get editGoal => 'Sửa mục tiêu';

  @override
  String get goalName => 'Tên mục tiêu';

  @override
  String get targetAmount => 'Số tiền mục tiêu';

  @override
  String get currentAmount => 'Đã tích lũy';

  @override
  String get deadline => 'Hạn hoàn thành';

  @override
  String get priority => 'Mức ưu tiên';

  @override
  String get isEmergencyFund => 'Đây là quỹ dự phòng';

  @override
  String emergencySuggestion(String amount) {
    return 'Gợi ý theo 6 tháng chi thiết yếu: $amount';
  }

  @override
  String get goalSaved => 'Đã lưu mục tiêu';

  @override
  String get addContribution => 'Góp thêm';

  @override
  String get contribution => 'Số tiền đóng góp';

  @override
  String get goalCompleted => 'Đã đạt mục tiêu';

  @override
  String monthlyContributionNeeded(String amount) {
    return 'Cần góp khoảng $amount/tháng';
  }

  @override
  String get deleteGoalTitle => 'Xóa mục tiêu?';

  @override
  String get deleteGoalMessage =>
      'Lịch sử đóng góp của mục tiêu cũng sẽ bị xóa.';

  @override
  String get recurringTitle => 'Giao dịch định kỳ';

  @override
  String get noRecurring => 'Chưa có lịch định kỳ';

  @override
  String get noRecurringBody =>
      'Tạo lịch cho lương, hóa đơn hoặc chuyển tiền giữa các hũ.';

  @override
  String get addRecurring => 'Thêm lịch';

  @override
  String get editRecurring => 'Sửa lịch';

  @override
  String get ruleName => 'Tên lịch';

  @override
  String get transactionType => 'Loại giao dịch';

  @override
  String get frequency => 'Chu kỳ';

  @override
  String get weekly => 'Hàng tuần';

  @override
  String get monthly => 'Hàng tháng';

  @override
  String get quarterly => 'Hàng quý';

  @override
  String get yearly => 'Hàng năm';

  @override
  String get nextRun => 'Kỳ tiếp theo';

  @override
  String get endDate => 'Ngày kết thúc';

  @override
  String get autoPost => 'Tự động ghi giao dịch';

  @override
  String get autoPostHint =>
      'Nếu tắt, giao dịch sẽ chờ bạn xác nhận trong app.';

  @override
  String get ruleSaved => 'Đã lưu lịch định kỳ';

  @override
  String get deleteRuleTitle => 'Xóa lịch định kỳ?';

  @override
  String get deleteRuleMessage =>
      'Các kỳ chưa ghi sẽ bị hủy. Giao dịch đã ghi vẫn được giữ lại.';

  @override
  String get ruleDeleted => 'Đã xóa lịch định kỳ';

  @override
  String get pendingTasks => 'Đang chờ xác nhận';

  @override
  String get confirmPost => 'Ghi giao dịch';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get enabled => 'Đang hoạt động';

  @override
  String get occurrenceCompleted => 'Đã ghi giao dịch định kỳ';

  @override
  String get dataTitle => 'Sao lưu & khôi phục';

  @override
  String get exportData => 'Xuất dữ liệu';

  @override
  String get importData => 'Nhập dữ liệu';

  @override
  String get copyBackup => 'Sao chép JSON';

  @override
  String get pasteJson => 'Dán snapshot JSON vào đây';

  @override
  String get dataExported => 'Đã sao chép dữ liệu vào clipboard';

  @override
  String get dataImported => 'Đã khôi phục dữ liệu';

  @override
  String get invalidBackup => 'Snapshot không hợp lệ hoặc không được hỗ trợ.';

  @override
  String get restoreWarning =>
      'Dữ liệu hiện tại sẽ được sao lưu trước khi khôi phục snapshot này.';

  @override
  String get latestBackup => 'Bản sao lưu gần nhất';

  @override
  String get noBackupAvailable => 'Chưa có bản sao lưu nào trên thiết bị.';

  @override
  String get backupRequired => 'Cần có snapshot JSON để khôi phục.';

  @override
  String get hideBalance => 'Ẩn số dư';

  @override
  String get showBalance => 'Hiện số dư';

  @override
  String get storageStartupTitle => 'Không thể mở dữ liệu trên thiết bị';

  @override
  String get storageStartupBody =>
      'Hãy đóng và mở lại ứng dụng. Nếu lỗi vẫn còn, kiểm tra quyền lưu trữ của ứng dụng.';

  @override
  String notificationDue(String amount) {
    return 'Đến hạn $amount';
  }

  @override
  String get recurringChannelName => 'Giao dịch định kỳ';

  @override
  String get recurringChannelDescription =>
      'Nhắc các khoản thu, chi và chuyển hũ đến hạn';

  @override
  String get otherCategory => 'Khác';

  @override
  String get depositToJar => 'Nạp tiền vào hũ';

  @override
  String get currentBalance => 'Số dư hiện tại';

  @override
  String directDepositHint(String jarName) {
    return 'Khoản tiền này được nạp 100% vào hũ $jarName.';
  }

  @override
  String get jarActivity => 'Biến động số dư';

  @override
  String get noJarActivity => 'Chưa có biến động';

  @override
  String get noJarActivityBody =>
      'Các khoản nạp, chi tiêu và chuyển hũ sẽ xuất hiện tại đây.';

  @override
  String get jarIncomeActivity => 'Tiền vào hũ';

  @override
  String get jarExpenseActivity => 'Chi tiêu từ hũ';

  @override
  String get jarTransferInActivity => 'Chuyển vào hũ';

  @override
  String get jarTransferOutActivity => 'Chuyển khỏi hũ';

  @override
  String jarTransferInFromActivity(String jarName) {
    return 'Chuyển từ hũ $jarName';
  }

  @override
  String jarTransferOutToActivity(String jarName) {
    return 'Chuyển đến hũ $jarName';
  }

  @override
  String balanceAfterActivity(String amount) {
    return 'Số dư sau giao dịch: $amount';
  }

  @override
  String get jarUnavailable => 'Hũ này không còn tồn tại.';

  @override
  String get jarEssentials => 'Nhu cầu thiết yếu';

  @override
  String get jarEssentialsDescription =>
      'Chi cho nhà ở, điện nước, ăn uống, đi lại, bảo hiểm và y tế cơ bản.';

  @override
  String get jarSavingsInvestments => 'Tiết kiệm & Đầu tư';

  @override
  String get jarSavingsInvestmentsDescription =>
      'Tạo quỹ dự phòng, tiết kiệm mục tiêu, đầu tư dài hạn hoặc trả thêm nợ.';

  @override
  String get jarEnjoyment => 'Hưởng thụ';

  @override
  String get jarEnjoymentDescription =>
      'Chi cho giải trí, du lịch, ăn ngoài và những sở thích cá nhân trong giới hạn.';

  @override
  String get jarEducationDevelopment => 'Giáo dục & Phát triển';

  @override
  String get jarEducationDevelopmentDescription =>
      'Đầu tư vào sách, khóa học, chứng chỉ và kỹ năng phục vụ tương lai.';

  @override
  String get jarLongTermSavings => 'Tiết kiệm dài hạn';

  @override
  String get jarLongTermSavingsDescription =>
      'Dành cho các mục tiêu lớn sẽ sử dụng trong tương lai như nhà, xe hoặc cưới hỏi.';

  @override
  String get jarFinancialFreedom => 'Tự do tài chính';

  @override
  String get jarFinancialFreedomDescription =>
      'Xây dựng tài sản và nguồn thu nhập thụ động; không dùng cho chi tiêu thông thường.';

  @override
  String get jarEducation => 'Giáo dục';

  @override
  String get jarEducationDescription =>
      'Chi cho việc học, sách, khóa học và nâng cao năng lực nghề nghiệp.';

  @override
  String get jarGiving => 'Thiện nguyện';

  @override
  String get jarGivingDescription =>
      'Dành để làm từ thiện, giúp đỡ người thân hoặc đóng góp cho cộng đồng.';

  @override
  String get jarPersonalWants => 'Mong muốn cá nhân';

  @override
  String get jarPersonalWantsDescription =>
      'Chi cho ăn ngoài, giải trí, du lịch, dịch vụ đăng ký và mua sắm không thiết yếu.';

  @override
  String get categoryFood => 'Ăn uống';

  @override
  String get categorySnacks => 'Ăn vặt';

  @override
  String get categoryChildren => 'Con cái';

  @override
  String get categoryShopping => 'Mua sắm';

  @override
  String get categoryCoffee => 'Cà phê';

  @override
  String get categoryGroceries => 'Đi chợ';

  @override
  String get categoryRent => 'Tiền nhà';

  @override
  String get categoryUtilities => 'Điện nước';

  @override
  String get categoryInternet => 'Internet';

  @override
  String get categoryPhone => 'Điện thoại';

  @override
  String get categoryFuel => 'Xăng xe';

  @override
  String get categoryTransport => 'Di chuyển';

  @override
  String get categoryHealthcare => 'Y tế';

  @override
  String get categoryBeauty => 'Làm đẹp';

  @override
  String get categoryEntertainment => 'Giải trí';

  @override
  String get categoryHousingUtilities => 'Nhà cửa / Điện nước';

  @override
  String get categoryEssentialShopping => 'Mua sắm cần thiết';

  @override
  String get categoryBankSavings => 'Tiết kiệm ngân hàng';

  @override
  String get categoryStockInvestment => 'Đầu tư chứng khoán';

  @override
  String get categoryEntertainmentCafe => 'Giải trí / Cafe';

  @override
  String get categoryTravel => 'Du lịch';

  @override
  String get categoryEducation => 'Học tập';

  @override
  String get categorySubscriptions => 'Đăng ký dịch vụ';

  @override
  String get categoryTechnology => 'Công nghệ';

  @override
  String get categoryGifts => 'Quà tặng';

  @override
  String get categoryFamily => 'Gia đình';

  @override
  String get categoryOtherExpenses => 'Chi phí khác';

  @override
  String get categoryCoursesBooks => 'Khóa học / Sách';

  @override
  String get categorySkillsWorkshop => 'Kỹ năng / Workshop';

  @override
  String get incomeCategorySalary => 'Lương chính';

  @override
  String get incomeCategoryBonus => 'Thưởng';

  @override
  String get incomeCategorySideJob => 'Làm thêm';

  @override
  String get incomeCategoryFreelance => 'Freelance';

  @override
  String get incomeCategoryBusiness => 'Kinh doanh';

  @override
  String get incomeCategoryInvestment => 'Đầu tư';

  @override
  String get incomeCategoryOther => 'Thu nhập khác';
}
