import 'package:raco_ksa/main.dart';
import 'package:raco_ksa/utils/colors.dart';
import 'package:raco_ksa/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/app_configuration.dart';

class PriceWidget extends StatelessWidget {
  final num price;
  final num discount;
  final double? size;
  final Color? color;
  final Color? hourlyTextColor;
  final bool isBoldText;
  final bool isLineThroughEnabled;
  final bool isDiscountedPrice;
  final bool isHourlyService;
  final bool isFreeService;
  final int? decimalPoint;

  PriceWidget({
    required this.price,
    this.size = 16.0,
    this.color,
    this.hourlyTextColor,
    this.isLineThroughEnabled = false,
    this.isBoldText = true,
    this.isDiscountedPrice = false,
    this.isHourlyService = false,
    this.isFreeService = false,
    this.decimalPoint,
    this.discount = 0,
  });

  @override
  Widget build(BuildContext context) {
    TextDecoration? textDecoration() =>
        isLineThroughEnabled ? TextDecoration.lineThrough : null;

    TextStyle _textStyle({int? aSize}) {
      return isBoldText
          ? boldTextStyle(
              size: aSize ?? size!.toInt(),
              color: color != null ? color : primaryColor,
              decoration: textDecoration(),
            )
          : secondaryTextStyle(
              size: aSize ?? size!.toInt(),
              color: color != null ? color : primaryColor,
              decoration: textDecoration(),
            );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Text(
        //   "${isDiscountedPrice ? ' -' : ''}",
        //   style: _textStyle(),
        // ),
        Row(
          children: [
            if (isFreeService)
              Text(language.lblFree, style: _textStyle())
            else if (discount != 0)
              // Text(
              //   "${isCurrencyPositionLeft ? appStore.currencySymbol : ''}${price.validate().toStringAsFixed(decimalPoint ?? DECIMAL_POINT).formatNumberWithComma()}${isCurrencyPositionRight ? appStore.currencySymbol : ''}",
              //   style: _textStyle()
              //       .copyWith(decoration: TextDecoration.lineThrough),
              // )
              Text.rich(
                  TextSpan(
                    // text: 'This item costs ',
                    children: <TextSpan>[
                      new TextSpan(
                        text:
                            "${isCurrencyPositionLeft ? appConfigurationStore.currencySymbol : ''}${price.validate().toStringAsFixed(decimalPoint ?? DECIMAL_POINT).formatNumberWithComma()}${isCurrencyPositionRight ? appConfigurationStore.currencySymbol : ''}",
                        style: new TextStyle(
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.025),
                      ),
                      new TextSpan(
                          text:
                              " ${isCurrencyPositionLeft ? appConfigurationStore.currencySymbol : ''}${(price.validate() - (discount / 100 * price).validate()).toStringAsFixed(decimalPoint ?? DECIMAL_POINT).formatNumberWithComma()}${isCurrencyPositionRight ? appConfigurationStore.currencySymbol : ''}",
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04)),
                    ],
                  ),
                  style: _textStyle())
            else
              Text(
                "${isCurrencyPositionLeft ? appConfigurationStore.currencySymbol : ''}${price.validate().toStringAsFixed(decimalPoint ?? DECIMAL_POINT).formatNumberWithComma()}${isCurrencyPositionRight ? appConfigurationStore.currencySymbol : ''}",
                style: _textStyle(
                    aSize: (MediaQuery.of(context).size.width * 0.04).round()),
              ),
            if (isHourlyService)
              Text(
                '/${language.lblHr}',
                style: secondaryTextStyle(color: hourlyTextColor, size: 12),
              ),
          ],
        ),
      ],
    );
  }
}
