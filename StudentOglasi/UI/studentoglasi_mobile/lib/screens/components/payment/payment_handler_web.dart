import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';
import 'package:studentoglasi_mobile/providers/payment_provider.dart';

class PaymentHandler {
  static Future<void> handlePayment(BuildContext context, double totalPrice,
      PaymentProvider paymentProvider, Function confirmReservation) async {
    try {
      final String? paymentIntentSecret =
          await paymentProvider.createPaymentIntentWeb(totalPrice);

      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PaymentElement(
                autofocus: true,
                enablePostalCode: true,
                clientSecret: paymentIntentSecret??'',
                onCardChanged: (_) {},
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    await WebStripe.instance.confirmPaymentElement(
                      ConfirmPaymentElementOptions(
                        redirect: PaymentConfirmationRedirect.ifRequired,
                        confirmParams:
                            ConfirmPaymentParams(return_url: ''), // Add if needed
                      ),
                    );
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
                },
                child: Text('Potvrdi'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Payment failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uplata nije uspjela')),
      );
    }
  }
}
