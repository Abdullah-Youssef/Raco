import 'package:raco_ksa/component/view_all_label_component.dart';
import 'package:raco_ksa/main.dart';
import 'package:raco_ksa/model/category_model.dart';
import 'package:raco_ksa/screens/category/category_screen.dart';
import 'package:raco_ksa/screens/dashboard/component/category_widget.dart';
import 'package:raco_ksa/screens/service/view_all_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryComponent extends StatefulWidget {
  final List<CategoryData>? categoryList;

  CategoryComponent({this.categoryList});

  @override
  CategoryComponentState createState() => CategoryComponentState();
}

class CategoryComponentState extends State<CategoryComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryList.validate().isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: language.category,
          list: widget.categoryList!,
          onTap: () {
            CategoryScreen().launch(context).then((value) {
              setStatusBarColor(Colors.transparent);
            });
          },
        ).paddingSymmetric(horizontal: 16),
        HorizontalList(
          itemCount: widget.categoryList.validate().length,
          padding: EdgeInsets.only(left: 16, right: 16),
          runSpacing: 8,
          spacing: 12,
          itemBuilder: (_, i) {
            CategoryData data = widget.categoryList![i];
            return GestureDetector(
              onTap: () {
                ViewAllServiceScreen(
                        categoryId: data.id.validate(),
                        categoryName: data.name,
                        isFromCategory: true)
                    .launch(context);
              },
              child: CategoryWidget(categoryData: data),
            );
          },
        ),
      ],
    );
  }
}
