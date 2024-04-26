import 'package:raco_ksa/main.dart';
import 'package:raco_ksa/model/dashboard_model.dart';
import 'package:raco_ksa/network/rest_apis.dart';
import 'package:raco_ksa/screens/dashboard/component/category_component.dart';
import 'package:raco_ksa/screens/dashboard/component/featured_service_list_component.dart';
import 'package:raco_ksa/screens/dashboard/component/service_list_component.dart';
import 'package:raco_ksa/screens/dashboard/component/slider_and_location_component.dart';
import 'package:raco_ksa/screens/dashboard/shimmer/dashboard_shimmer.dart';
import 'package:raco_ksa/utils/configs.dart';
import 'package:raco_ksa/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:raco_ksa/utils/string_extensions.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../../../utils/images.dart';
import '../../notification/notification_screen.dart';
import '../component/booking_confirmed_component.dart';
import '../component/new_job_request_component.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init();

    setStatusBarColor(transparentColor, delayInMilliSeconds: 800);

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      init();
      appStore.setLoading(true);

      setState(() {});
    });
  }

  void init() async {
    future = userDashboard(
        isCurrentLocation: appStore.isCurrentLocation,
        lat: getDoubleAsync(LATITUDE),
        long: getDoubleAsync(LONGITUDE));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.width * 0.15,
        ),
        child: appBarWidget(
          APP_NAME,
          textColor: white,
          textSize: APP_BAR_TEXT_SIZE,
          elevation: 0.0,
          // center: true,
          titleWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                APP_NAME,
                style: TextStyle(
                    color: white,
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              Image.asset(
                appIcon,
                height: MediaQuery.of(context).size.width * 0.15,
              ),
            ],
          ),
          color: context.primaryColor,
          showBack: false,
          // actions: [
          //   if (appStore.isLoggedIn)
          //     IconButton(
          //       icon: Icon(Icons.notifications, color: white, size: 24),
          //       onPressed: () async {
          //         NotificationScreen().launch(context);
          //       },
          //     ),
          // ],
        ),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<DashboardResponse>(
            initialData: cachedDashboardResponse,
            future: future,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  appStore.setLoading(true);
                  init();

                  setState(() {});
                },
              );
            },
            loadingWidget: DashboardShimmer(),
            onSuccess: (snap) {
              return Observer(builder: (context) {
                return AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  onSwipeRefresh: () async {
                    appStore.setLoading(true);

                    setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                    init();
                    setState(() {});

                    return await 2.seconds.delay;
                  },
                  children: [
                    SliderLocationComponent(
                      sliderList: snap.slider.validate(),
                      featuredList: snap.featuredServices.validate(),
                      callback: () async {
                        appStore.setLoading(true);

                        init();
                        setState(() {});
                      },
                    ),
                    // 30.height,
                    // PendingBookingComponent(
                    //     upcomingConfirmedBooking: snap.upcomingData),
                    // CategoryComponent(categoryList: snap.category.validate()),
                    // 16.height,
                    // FeaturedServiceListComponent(
                    //     serviceList: snap.featuredServices.validate()),
                    ServiceListComponent(serviceList: snap.service.validate()),
                    // 16.height,
                    // if (appConfigurationStore.jobRequestStatus)
                    //   NewJobRequestComponent(),
                  ],
                );
              });
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
