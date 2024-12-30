import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class PaymentProvider {
  late http.Client _httpClient;
  late String _baseUrl;

  PaymentProvider() {
    if (kIsWeb) {
      _httpClient = http.Client();
      _baseUrl = 'https://localhost:7198';
    } else {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      _httpClient = IOClient(httpClient);
      _baseUrl = 'https://10.0.2.2:7198';
    }
  }

  Future<void> createPaymentIntent(double amount) async {
    final paymentIntentRes = await _httpClient.post(
      Uri.parse('$_baseUrl/Payment/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': amount,
        'currency': 'bam',
      }),
    );

    final paymentIntentData = json.decode(paymentIntentRes.body);

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData['clientSecret'],
        merchantDisplayName: 'StudentOglasi',
      ),
    );
  }

  Future<void> presentPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet();
  }
}
