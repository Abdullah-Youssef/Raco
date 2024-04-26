import 'package:raco_ksa/app_theme.dart';
import 'package:raco_ksa/locale/app_localizations.dart';
import 'package:raco_ksa/locale/language_en.dart';
import 'package:raco_ksa/locale/languages.dart';
import 'package:raco_ksa/model/booking_detail_model.dart';
import 'package:raco_ksa/model/get_my_post_job_list_response.dart';
import 'package:raco_ksa/model/material_you_model.dart';
import 'package:raco_ksa/model/notification_model.dart';
import 'package:raco_ksa/model/provider_info_response.dart';
import 'package:raco_ksa/model/remote_config_data_model.dart';
import 'package:raco_ksa/model/service_data_model.dart';
import 'package:raco_ksa/model/service_detail_response.dart';
import 'package:raco_ksa/model/user_data_model.dart';
import 'package:raco_ksa/model/user_wallet_history.dart';
import 'package:raco_ksa/screens/blog/model/blog_detail_response.dart';
import 'package:raco_ksa/screens/blog/model/blog_response_model.dart';
import 'package:raco_ksa/screens/splash_screen.dart';
import 'package:raco_ksa/services/auth_services.dart';
import 'package:raco_ksa/services/chat_services.dart';
import 'package:raco_ksa/services/user_services.dart';
import 'package:raco_ksa/store/app_configuration_store.dart';
import 'package:raco_ksa/store/app_store.dart';
import 'package:raco_ksa/store/filter_store.dart';
import 'package:raco_ksa/utils/colors.dart';
import 'package:raco_ksa/utils/common.dart';
import 'package:raco_ksa/utils/configs.dart';
import 'package:raco_ksa/utils/constant.dart';
import 'package:raco_ksa/utils/firebase_messaging_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'model/booking_data_model.dart';
import 'model/booking_status_model.dart';
import 'model/category_model.dart';
import 'model/coupon_list_model.dart';
import 'model/dashboard_model.dart';

//region Mobx Stores
AppStore appStore = AppStore();
FilterStore filterStore = FilterStore();
AppConfigurationStore appConfigurationStore = AppConfigurationStore();
//endregion

//region Global Variables
BaseLanguage language = LanguageEn();
//endregion

//region Services
UserService userService = UserService();
AuthService authService = AuthService();
ChatServices chatServices = ChatServices();
RemoteConfigDataModel remoteConfigDataModel = RemoteConfigDataModel();
//endregion

//region Cached Response Variables for Dashboard Tabs
DashboardResponse? cachedDashboardResponse;
List<BookingData>? cachedBookingList;
List<CategoryData>? cachedCategoryList;
List<BookingStatusResponse>? cachedBookingStatusDropdown;
List<PostJobData>? cachedPostJobList;
List<WalletDataElement>? cachedWalletHistoryList;

List<ServiceData>? cachedServiceFavList;
List<UserData>? cachedProviderFavList;
List<BlogData>? cachedBlogList;
List<RatingData>? cachedRatingList;
List<NotificationData>? cachedNotificationList;
CouponListResponse? cachedCouponListResponse;
List<(int blogId, BlogDetailResponse list)?> cachedBlogDetail = [];
List<(int serviceId, ServiceDetailResponse list)?> listOfCachedData = [];
List<(int providerId, ProviderInfoResponse list)?> cachedProviderList = [];
List<(int categoryId, List<CategoryData> list)?> cachedSubcategoryList = [];
List<(int bookingId, BookingDetailResponse list)?> cachedBookingDetailList = [];
//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  passwordLengthGlobal = 6;
  appButtonBackgroundColorGlobal = primaryColor;
  defaultAppButtonTextColorGlobal = Colors.white;
  defaultRadius = 12;
  defaultBlurRadius = 0;
  defaultSpreadRadius = 0;
  textSecondaryColorGlobal = appTextPrimaryColor;
  textPrimaryColorGlobal = appTextSecondaryColor;
  defaultAppButtonElevation = 0;
  pageRouteTransitionDurationGlobal = 400.milliseconds;
  textBoldSizeGlobal = 14;
  textPrimarySizeGlobal = 14;
  textSecondarySizeGlobal = 12;

  await initialize();
  localeLanguageList = languageList();

  await Firebase.initializeApp().then((value) {
    /// Firebase Notification
    initFirebaseMessaging();
    if (kReleaseMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    setupFirebaseRemoteConfig();
  });

  int themeModeIndex =
      getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
  if (themeModeIndex == THEME_MODE_LIGHT) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == THEME_MODE_DARK) {
    appStore.setDarkMode(true);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Observer(
        builder: (_) => FutureBuilder<Color>(
          future: getMaterialYouData(),
          builder: (_, snap) {
            return Observer(
              builder: (_) => MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                home: SplashScreen(),
                theme: AppTheme.lightTheme(color: snap.data),
                darkTheme: AppTheme.darkTheme(color: snap.data),
                themeMode:
                    appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                title: APP_NAME,
                supportedLocales: LanguageDataModel.languageLocales(),
                localizationsDelegates: [
                  AppLocalizations(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                localeResolutionCallback: (locale, supportedLocales) => locale,
                locale: Locale(appStore.selectedLanguageCode),
              ),
            );
          },
        ),
      ),
    );
  }
}
