import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../repository/stripe_repository.dart';

class StripePaymentScreen extends StatefulWidget {
  final int amount; // số tiền (VND)
  const StripePaymentScreen({super.key, required this.amount});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  bool isLoading = false;

  Future<void> payWithStripe() async {
    setState(() => isLoading = true);

    final repo = StripeRepository();
    final clientSecret = await repo.createPaymentIntent(widget.amount, 'vnd');
    if (clientSecret == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tạo được payment intent')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Luxe Silver',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thanh toán thành công!')));
      Navigator.pop(context, true); // Trả về true nếu muốn
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thanh toán thất bại: $e')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán Stripe')),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: payWithStripe,
                  child: const Text('Thanh toán test với Stripe'),
                ),
      ),
    );
  }
}
