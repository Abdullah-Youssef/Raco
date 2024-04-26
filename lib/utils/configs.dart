import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

const APP_NAME = 'Raco Care';
const APP_NAME_TAG_LINE = 'Services App';
var defaultPrimaryColor = Color(0xFF5F60B9);

// Don't add slash at the end of the url
const DOMAIN_URL =
    'https://catalog.raco-ksa.com'; // Don't add slash at the end of the url
const BASE_URL = '$DOMAIN_URL/api/';

const DEFAULT_LANGUAGE = 'ar';

/// You can change this to your Provider App package name
/// This will be used in Registered As Partner in Sign In Screen where your users can redirect to the Play/App Store for Provider App
/// You can specify in Admin Panel, These will be used if you don't specify in Admin Panel
const PROVIDER_PACKAGE_NAME = '';
const IOS_LINK_FOR_PARTNER = "";

const IOS_LINK_FOR_USER = '';

const DASHBOARD_AUTO_SLIDER_SECOND = 5;

const TERMS_CONDITION_URL = 'https://catalog.raco-ksa.com/term-conditions/';
const PRIVACY_POLICY_URL = 'https://catalog.raco-ksa.com/privacy-policy/';
const HELP_AND_SUPPORT_URL = 'https://catalog.raco-ksa.com/help-support/';
const REFUND_POLICY_URL = 'https://catalog.raco-ksa.com/refund-policy/';
const INQUIRY_SUPPORT_EMAIL = 'appracoksa@gmail.com';

/// You can add help line number here for contact. It's demo number
const HELP_LINE_NUMBER = '+01234567890';

//Airtel Money Payments
///It Supports ["UGX", "NGN", "TZS", "KES", "RWF", "ZMW", "CFA", "XOF", "XAF", "CDF", "USD", "XAF", "SCR", "MGA", "MWK"]
const AIRTEL_CURRENCY_CODE = "MWK";
const AIRTEL_COUNTRY_CODE = "MW";
const AIRTEL_TEST_BASE_URL = 'https://openapiuat.airtel.africa/'; //Test Url
const AIRTEL_LIVE_BASE_URL = 'https://openapi.airtel.africa/'; // Live Url

/// PAYSTACK PAYMENT DETAIL
const PAYSTACK_CURRENCY_CODE = 'NGN';

/// Nigeria Currency

/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
const STRIPE_CURRENCY_CODE = 'INR';

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

/// PAYPAL PAYMENT DETAIL
const PAYPAL_CURRENCY_CODE = 'USD';

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

DateTime todayDate = DateTime(2022, 8, 24);

Country defaultCountry() {
  return Country(
    phoneCode: '966',
    countryCode: 'SA',
    e164Sc: 966,
    geographic: true,
    level: 1,
    name: 'Saudi Arabia',
    example: '966123456789',
    displayName: 'Saudi Arabia (SA) [+966]',
    displayNameNoCountryCode: 'Saudi Arabia (SA)',
    e164Key: '966-SA-0',
    fullExampleWithPlusSign: '+966123456789',
  );
}

// Country defaultCountry() {
//   return Country(
//     phoneCode: '20',
//     countryCode: 'EG',
//     e164Sc: 20,
//     geographic: true,
//     level: 1,
//     name: 'Egypt',
//     example: '20123456789',
//     displayName: 'Egypt (EG) [+20]',
//     displayNameNoCountryCode: 'Egypt (EG)',
//     e164Key: '20-EG-0',
//     fullExampleWithPlusSign: '+20123456789',
//   );
// }

//Chat Module File Upload Configs
const chatFilesAllowedExtensions = [
  'jpg', 'jpeg', 'png', 'gif', 'webp', // Images
  'pdf', 'txt', // Documents
  'mkv', 'mp4', // Video
  'mp3', // Audio
];

const max_acceptable_file_size = 5; //Size in Mb
