import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class Currency {
  static final app_id = dotenv.env['APP_ID'];
  static Future<void> createDatabase() async {
    await Hive.openBox('Currency_Storage');
  }

  static void checkUpdateSnackbar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: (title == 'Successfull') ? Colors.green : Colors.red,
        content: Text(
          'Currency Rate Updated $title',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        )));
  }

  static Future<void> updateCurrencyRate(BuildContext context) async {
    Map<String, dynamic> allPrices = {};

    var box = Hive.box('Currency_Storage');
    try {
      final url = Uri.parse(
          'https://openexchangerates.org/api/latest.json?app_id=$app_id');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      allPrices = data['rates'];

      await box.putAll(allPrices);
      checkUpdateSnackbar(context, 'Successfull');
    } on Exception catch (e) {
      checkUpdateSnackbar(context, 'Failed');
      print('Error occured');
    }
    print(('Currency Rate Is Updated'));
    print(box.isEmpty);
  }

  static String convertAmount(
      {sourceCurrency = 'INR',
      String destinationCurrency = 'USD',
      double enteredAmount = 1}) {
    var box = Hive.box('Currency_Storage');
    final sourceCurrencyRate = box.get(sourceCurrency, defaultValue: 0.0);
    final destinationCurrencyRate =
        box.get(destinationCurrency, defaultValue: 0.0);
    final amount = enteredAmount / sourceCurrencyRate * destinationCurrencyRate;
    print(amount.toStringAsFixed(3));
    return amount.toStringAsFixed(2);
  }

  static Map<String, String> currencyIcons = {
    'DZD': '🇩🇿', // Algeria
    'NAD': '🇳🇦', // Namibia
    'GHS': '🇬🇭', // Ghana
    'EGP': '🇪🇬', // Egypt
    'BGN': '🇧🇬', // Bulgaria
    'XCD': '🇧🇧', // Barbados
    'PAB': '🇵🇦', // Panama
    'BOB': '🇧🇴', // Bolivia
    'DKK': '🇩🇰', // Denmark
    'BWP': '🇧🇼', // Botswana
    'LBP': '🇱🇧', // Lebanon
    'TZS': '🇹🇿', // Tanzania
    'VND': '🇻🇳', // Vietnam
    'AOA': '🇦🇴', // Angola
    'KHR': '🇰🇭', // Cambodia
    'MYR': '🇲🇾', // Malaysia
    'KYD': '🇰🇾', // Cayman Islands
    'LYD': '🇱🇾', // Libya
    'UAH': '🇺🇦', // Ukraine
    'JOD': '🇯🇴', // Jordan
    'AWG': '🇦🇼', // Aruba
    'SAR': '🇸🇦', // Saudi Arabia
    'XAG': '🥈', // Silver
    'HKD': '🇭🇰', // Hong Kong
    'CHF': '🇨🇭', // Switzerland
    'GIP': '🇬🇮', // Gibraltar
    'MRU': '🇲🇷', // Mauritania
    'ALL': '🇦🇱', // Albania
    'XPD': '🥉', // Palladium
    'BYN': '🇧🇾', // Belarus
    'HRK': '🇭🇷', // Croatia
    'DJF': '🇩🇯', // Djibouti
    'SZL': '🇸🇿', // Eswatini
    'THB': '🇹🇭', // Thailand
    'XAF': '🇨🇫', // Central African Republic
    'BND': '🇧🇳', // Brunei
    'ISK': '🇮🇸', // Iceland
    'UYU': '🇺🇾', // Uruguay
    'NIO': '🇳🇮', // Nicaragua
    'LAK': '🇱🇦', // Laos
    'SYP': '🇸🇾', // Syria
    'MAD': '🇲🇦', // Morocco
    'MZN': '🇲🇿', // Mozambique
    'PHP': '🇵🇭', // Philippines
    'ZAR': '🇿🇦', // South Africa
    'NPR': '🇳🇵', // Nepal
    'ZWL': '🇿🇼', // Zimbabwe
    'NGN': '🇳🇬', // Nigeria
    'CRC': '🇨🇷', // Costa Rica
    'AED': '🇦🇪', // United Arab Emirates
    'GBP': '🇬🇧', // United Kingdom
    'MWK': '🇲🇼', // Malawi
    'LKR': '🇱🇰', // Sri Lanka
    'PKR': '🇵🇰', // Pakistan
    'HUF': '🇭🇺', // Hungary
    'BMD': '🇧🇲', // Bermuda
    'LSL': '🇱🇸', // Lesotho
    'MNT': '🇲🇳', // Mongolia
    'AMD': '🇦🇲', // Armenia
    'UGX': '🇺🇬', // Uganda
    'QAR': '🇶🇦', // Qatar
    'XDR': '💰', // Special Drawing Rights (SDR)
    'STN': '🇸🇹', // Sao Tome and Principe
    'JMD': '🇯🇲', // Jamaica
    'GEL': '🇬🇪', // Georgia
    'SHP': '🇸🇭', // Saint Helena
    'AFN': '🇦🇫', // Afghanistan
    'SBD': '🇸🇧', // Solomon Islands
    'KPW': '🇰🇵', // North Korea
    'TRY': '🇹🇷', // Turkey
    'BDT': '🇧🇩', // Bangladesh
    'YER': '🇾🇪', // Yemen
    'HTG': '🇭🇹', // Haiti
    'XOF': '🇨🇯', // Comoros
    'MGA': '🇲🇬', // Madagascar
    'ANG': '🇦🇳', // Netherlands Antilles
    'LRD': '🇱🇷', // Liberia
    'RWF': '🇷🇼', // Rwanda
    'NOK': '🇳🇴', // Norway
    'MOP': '🇲🇴', // Macau
    'SSP': '🇸🇸', // South Sudan
    'INR': '🇮🇳', // India
    'MXN': '🇲🇽', // Mexico
    'CZK': '🇨🇿', // Czech Republic
    'TJS': '🇹🇯', // Tajikistan
    'BTC': '₿', // Bitcoin
    'BTN': '🇧🇹', // Bhutan
    'COP': '🇨🇴', // Colombia
    'TMT': '🇹🇲', // Turkmenistan
    'MUR': '🇲🇺', // Mauritius
    'IDR': '🇮🇩', // Indonesia
    'HNL': '🇭🇳', // Honduras
    'XPF': '🇨🇵', // French Polynesia
    'FJD': '🇫🇯', // Fiji
    'ETB': '🇪🇹', // Ethiopia
    'PEN': '🇵🇪', // Peru
    'BZD': '🇧🇿', // Belize
    'ILS': '🇮🇱', // Israel
    'DOP': '🇩🇴', // Dominican Republic
    'GGP': '🇬🇬', // Guernsey
    'MDL': '🇲🇩', // Moldova
    'XPT': '🇵🇹', // Platinum
    'BSD': '🇧🇸', // Bahamas
    'SEK': '🇸🇪', // Sweden
    'JEP': '🇯🇪', // Jersey
    'AUD': '🇦🇺', // Australia
    'SRD': '🇸🇷', // Suriname
    'CUP': '🇨🇺', // Cuba
    'CLF': '🇨🇱', // Chile
    'BBD': '🇧🇧', // Barbados
    'KMF': '🇰🇲', // Comoros
    'KRW': '🇰🇷', // South Korea
    'GMD': '🇬🇲', // Gambia
    'IMP': '🇮🇲', // Isle of Man
    'CUC': '🇨🇺', // Cuban Convertible Peso
    'CLP': '🇨🇱', // Chilean Peso
    'ZMW': '🇿🇲', // Zambia
    'EUR': '🇪🇺', // Euro
    'CDF': '🇨🇩', // Congolese Franc
    'VES': '🇻🇪', // Venezuela
    'KZT': '🇰🇿', // Kazakhstan
    'RUB': '🇷🇺', // Russia
    'TTD': '🇹🇹', // Trinidad and Tobago
    'OMR': '🇴🇲', // Oman
    'BRL': '🇧🇷', // Brazil
    'MMK': '🇲🇲', // Myanmar
    'PLN': '🇵🇱', // Poland
    'PYG': '🇵🇾', // Paraguay
    'KES': '🇰🇪', // Kenya
    'SVC': '🇸🇻', // El Salvador
    'MKD': '🇲🇰', // North Macedonia
    'AZN': '🇦🇿', // Azerbaijan
    'TOP': '🇹🇴', // Tonga
    'MVR': '🇲🇻', // Maldives
    'VUV': '🇻🇺', // Vanuatu
    'GNF': '🇬🇳', // Guinea
    'WST': '🇼🇸', // Samoa
    'IQD': '🇮🇶', // Iraq
    'ERN': '🇪🇷', // Eritrea
    'BAM': '🇧🇦', // Bosnia and Herzegovina
    'SCR': '🇸🇨', // Seychelles
    'CAD': '🇨🇦', // Canada
    'CVE': '🇨🇻', // Cape Verde
    'KWD': '🇰🇼', // Kuwait
    'BIF': '🇧🇮', // Burundi
    'PGK': '🇵🇬', // Papua New Guinea
    'SOS': '🇸🇴', // Somalia
    'TWD': '🇹🇼', // Taiwan
    'SGD': '🇸🇬', // Singapore
    'UZS': '🇺🇿', // Uzbekistan
    'STD': '🇸🇹', // Sao Tome and Principe
    'IRR': '🇮🇷', // Iran
    'CNY': '🇨🇳', // China
    'SLL': '🇸🇱', // Sierra Leone
    'TND': '🇹🇳', // Tunisia
    'GYD': '🇬🇾', // Guyana
    'NZD': '🇳🇿', // New Zealand
    'FKP': '🇫🇰', // Falkland Islands
    'USD': '🇺🇸', // United States
    'CNH': '🇨🇳', // Chinese Yuan (offshore)
    'KGS': '🇰🇬', // Kyrgyzstan
    'ARS': '🇦🇷', // Argentina
    'RON': '🇷🇴', // Romania
    'GTQ': '🇬🇹', // Guatemala
    'RSD': '🇷🇸', // Serbia
    'BHD': '🇧🇭', // Bahrain
    'JPY': '🇯🇵', // Japan
    'SDG': '🇸🇩', // Sudan
    'XAU': '🥇' // Gold
  };
  static Map<String, String> currencyMap = {
    'DZD': 'Algerian Dinar',
    'NAD': 'Namibian Dollar',
    'GHS': 'Ghanaian Cedi',
    'EGP': 'Egyptian Pound',
    'BGN': 'Bulgarian Lev',
    'XCD': 'East Caribbean Dollar',
    'PAB': 'Panamanian Balboa',
    'BOB': 'Bolivian Boliviano',
    'DKK': 'Danish Krone',
    'BWP': 'Botswana Pula',
    'LBP': 'Lebanese Pound',
    'TZS': 'Tanzanian Shilling',
    'VND': 'Vietnamese Dong',
    'AOA': 'Angolan Kwanza',
    'KHR': 'Cambodian Riel',
    'MYR': 'Malaysian Ringgit',
    'KYD': 'Cayman Islands Dollar',
    'LYD': 'Libyan Dinar',
    'UAH': 'Ukrainian Hryvnia',
    'JOD': 'Jordanian Dinar',
    'AWG': 'Aruban Florin',
    'SAR': 'Saudi Riyal',
    'XAG': 'Silver Ounce',
    'HKD': 'Hong Kong Dollar',
    'CHF': 'Swiss Franc',
    'GIP': 'Gibraltar Pound',
    'MRU': 'Mauritanian Ouguiya',
    'ALL': 'Albanian Lek',
    'XPD': 'Palladium Ounce',
    'BYN': 'Belarusian Ruble',
    'HRK': 'Croatian Kuna',
    'DJF': 'Djiboutian Franc',
    'SZL': 'Swazi Lilangeni',
    'THB': 'Thai Baht',
    'XAF': 'Central African CFA Franc',
    'BND': 'Brunei Dollar',
    'ISK': 'Icelandic Krona',
    'UYU': 'Uruguayan Peso',
    'NIO': 'Nicaraguan Cordoba',
    'LAK': 'Laotian Kip',
    'SYP': 'Syrian Pound',
    'MAD': 'Moroccan Dirham',
    'MZN': 'Mozambican Metical',
    'PHP': 'Philippine Peso',
    'ZAR': 'South African Rand',
    'NPR': 'Nepalese Rupee',
    'ZWL': 'Zimbabwean Dollar',
    'NGN': 'Nigerian Naira',
    'CRC': 'Costa Rican Colon',
    'AED': 'United Arab Emirates Dirham',
    'GBP': 'British Pound Sterling',
    'MWK': 'Malawian Kwacha',
    'LKR': 'Sri Lankan Rupee',
    'PKR': 'Pakistani Rupee',
    'HUF': 'Hungarian Forint',
    'BMD': 'Bermudan Dollar',
    'LSL': 'Lesotho Loti',
    'MNT': 'Mongolian Tugrik',
    'AMD': 'Armenian Dram',
    'UGX': 'Ugandan Shilling',
    'QAR': 'Qatari Riyal',
    'XDR': 'Special Drawing Rights',
    'STN': 'Sao Tome and Principe Dobra',
    'JMD': 'Jamaican Dollar',
    'GEL': 'Georgian Lari',
    'SHP': 'Saint Helena Pound',
    'AFN': 'Afghan Afghani',
    'SBD': 'Solomon Islands Dollar',
    'KPW': 'North Korean Won',
    'TRY': 'Turkish Lira',
    'BDT': 'Bangladeshi Taka',
    'YER': 'Yemeni Rial',
    'HTG': 'Haitian Gourde',
    'XOF': 'West African CFA Franc',
    'MGA': 'Malagasy Ariary',
    'ANG': 'Netherlands Antillean Guilder',
    'LRD': 'Liberian Dollar',
    'RWF': 'Rwandan Franc',
    'NOK': 'Norwegian Krone',
    'MOP': 'Macanese Pataca',
    'SSP': 'South Sudanese Pound',
    'INR': 'Indian Rupee',
    'MXN': 'Mexican Peso',
    'CZK': 'Czech Koruna',
    'TJS': 'Tajikistani Somoni',
    'BTC': 'Bitcoin',
    'BTN': 'Bhutanese Ngultrum',
    'COP': 'Colombian Peso',
    'TMT': 'Turkmenistan Manat',
    'MUR': 'Mauritian Rupee',
    'IDR': 'Indonesian Rupiah',
    'HNL': 'Honduran Lempira',
    'XPF': 'CFP Franc',
    'FJD': 'Fijian Dollar',
    'ETB': 'Ethiopian Birr',
    'PEN': 'Peruvian Sol',
    'BZD': 'Belize Dollar',
    'ILS': 'Israeli New Shekel',
    'DOP': 'Dominican Peso',
    'GGP': 'Guernsey Pound',
    'MDL': 'Moldovan Leu',
    'XPT': 'Platinum Ounce',
    'BSD': 'Bahamian Dollar',
    'SEK': 'Swedish Krona',
    'JEP': 'Jersey Pound',
    'AUD': 'Australian Dollar',
    'SRD': 'Surinamese Dollar',
    'CUP': 'Cuban Peso',
    'CLF': 'Chilean Unit of Account (UF)',
    'BBD': 'Barbadian Dollar',
    'KMF': 'Comorian Franc',
    'KRW': 'South Korean Won',
    'GMD': 'Gambian Dalasi',
    'IMP': 'Isle of Man Pound',
    'CUC': 'Cuban Convertible Peso',
    'CLP': 'Chilean Peso',
    'ZMW': 'Zambian Kwacha',
    'EUR': 'Euro',
    'CDF': 'Congolese Franc',
    'VES': 'Venezuelan Bolivar',
    'KZT': 'Kazakhstani Tenge',
    'RUB': 'Russian Ruble',
    'TTD': 'Trinidad and Tobago Dollar',
    'OMR': 'Omani Rial',
    'BRL': 'Brazilian Real',
    'MMK': 'Burmese Kyat',
    'PLN': 'Polish Zloty',
    'PYG': 'Paraguayan Guarani',
    'KES': 'Kenyan Shilling',
    'SVC': 'Salvadoran Colon',
    'MKD': 'Macedonian Denar',
    'AZN': 'Azerbaijani Manat',
    'TOP': 'Tongan Paanga',
    'MVR': 'Maldivian Rufiyaa',
    'VUV': 'Vanuatu Vatu',
    'GNF': 'Guinean Franc',
    'WST': 'Samoan Tala',
    'IQD': 'Iraqi Dinar',
    'ERN': 'Eritrean Nakfa',
    'BAM': 'Bosnia-Herzegovina Convertible Mark',
    'SCR': 'Seychellois Rupee',
    'CAD': 'Canadian Dollar',
    'CVE': 'Cape Verdean Escudo',
    'KWD': 'Kuwaiti Dinar',
    'BIF': 'Burundian Franc',
    'PGK': 'Papua New Guinean Kina',
    'SOS': 'Somali Shilling',
    'TWD': 'New Taiwan Dollar',
    'SGD': 'Singapore Dollar',
    'UZS': 'Uzbekistani Som',
    'STD': 'São Tomé and Príncipe Dobra',
    'IRR': 'Iranian Rial',
    'CNY': 'Chinese Yuan',
    'SLL': 'Sierra Leonean Leone',
    'TND': 'Tunisian Dinar',
    'GYD': 'Guyanese Dollar',
    'NZD': 'New Zealand Dollar',
    'FKP': 'Falkland Islands Pound',
    'USD': 'United States Dollar',
    'CNH': 'Chinese Yuan (Offshore)',
    'KGS': 'Kyrgyzstani Som',
    'ARS': 'Argentine Peso',
    'RON': 'Romanian Leu',
    'GTQ': 'Guatemalan Quetzal',
    'RSD': 'Serbian Dinar',
    'BHD': 'Bahraini Dinar',
    'JPY': 'Japanese Yen',
    'SDG': 'Sudanese Pound',
    'XAU': 'Gold Ounce',
  };
}
