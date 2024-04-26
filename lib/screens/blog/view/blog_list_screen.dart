import 'package:raco_ksa/main.dart';
import 'package:raco_ksa/screens/blog/blog_repository.dart';
import 'package:raco_ksa/screens/blog/component/blog_item_component.dart';
import 'package:raco_ksa/screens/blog/model/blog_response_model.dart';
import 'package:raco_ksa/screens/blog/shimmer/blog_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/base_scaffold_widget.dart';
import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../../../utils/constant.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  Future<List<BlogData>>? future;

  List<BlogData> blogList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getBlogListAPI(
      blogData: blogList,
      page: page,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.blogs,
        textColor: white,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 0.0,
        color: context.primaryColor,
        showBack: false,
        // actions: [
        //   IconButton(
        //     icon: ic_setting.iconImage(color: white, size: 20),
        //     onPressed: () async {
        //       SettingScreen().launch(context);
        //     },
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<BlogData>>(
            initialData: cachedBlogList,
            future: future,
            loadingWidget: BlogShimmer(),
            onSuccess: (snap) {
              return AnimatedListView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: snap.length,
                emptyWidget: NoDataWidget(
                    title: language.noBlogsFound,
                    imageWidget: EmptyStateWidget()),
                shrinkWrap: true,
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                disposeScrollController: true,
                itemBuilder: (BuildContext context, index) {
                  return BlogItemComponent(blogData: snap[index]);
                },
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
