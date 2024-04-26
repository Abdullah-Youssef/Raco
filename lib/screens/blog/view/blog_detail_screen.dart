import 'package:raco_ksa/component/base_scaffold_widget.dart';
import 'package:raco_ksa/main.dart';
import 'package:raco_ksa/screens/blog/blog_repository.dart';
import 'package:raco_ksa/screens/blog/component/blog_detail_header_component.dart';
import 'package:raco_ksa/screens/blog/model/blog_detail_response.dart';
import 'package:raco_ksa/utils/extensions/string_extentions.dart';
import 'package:raco_ksa/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/empty_error_state_widget.dart';
import '../../../component/image_border_component.dart';
import '../../../utils/common.dart';
import '../shimmer/blog_detail_shimmer.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  BlogDetailScreen({required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  Future<BlogDetailResponse>? future;
  int page = 1;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
    init();
  }

  void init() async {
    future = getBlogDetailAPI({BlogKey.blogId: widget.blogId.validate()});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SnapHelperWidget<BlogDetailResponse>(
        future: future,
        initialData: cachedBlogDetail
            .firstWhere((element) => element?.$1 == widget.blogId.validate(),
                orElse: () => null)
            ?.$2,
        loadingWidget: BlogDetailShimmer(),
        onSuccess: (data) {
          return AnimatedScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            padding: EdgeInsets.only(bottom: 120),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlogDetailHeaderComponent(blogData: data.blogDetail!),
              16.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    // margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: context.dividerColor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.blogDetail!.title.validate(),
                            style: boldTextStyle(size: 20)),
                        16.height,
                        Row(
                          children: [
                            Row(
                              children: [
                                Text(data.blogDetail!.publishDate.validate(),
                                    style: secondaryTextStyle(size: 14)),
                                // ImageBorder(
                                //   src: widget.blogData!.authorImage.validate(),
                                //   height: 30,
                                // ),
                                // 8.width,
                                // Column(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     Text(widget.blogData!.authorName.validate(),
                                //         style: primaryTextStyle(size: 14),
                                //         maxLines: 1,
                                //         overflow: TextOverflow.ellipsis),
                                //     2.height,
                                //     Text(widget.blogData!.publishDate.validate(),
                                //         style: secondaryTextStyle(size: 10)),
                                //   ],
                                // ).expand(),
                              ],
                            ).expand(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.remove_red_eye,
                                    size: 14, color: context.iconColor),
                                4.width,
                                Text(
                                    '${data.blogDetail!.totalViews.validate()} ',
                                    style: secondaryTextStyle(size: 14)),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Html(data: data.blogDetail!.description.validate())
                ],
              ).paddingSymmetric(horizontal: 16),
            ],
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
    );
  }
}
