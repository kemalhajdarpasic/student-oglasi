import 'package:flutter/material.dart';
import 'package:studentoglasi_mobile/providers/payment_provider.dart';

class PaymentHandler {
  static Future<void> handlePayment(BuildContext context, double totalPrice,
      PaymentProvider paymentProvider, Function confirmReservation) async {
    try {
      await paymentProvider.createPaymentIntent(totalPrice);
      await paymentProvider.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uplata je uspješno izvršena!')),
      );
      confirmReservation();
    } catch (e) {
      print('Payment failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uplata nije uspjela')),
      );
    }
  }
}
