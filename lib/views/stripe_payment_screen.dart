import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../repository/stripe_repository.dart';

class StripePaymentScreen extends StatefulWidget {
  final int soTien;
  const StripePaymentScreen({super.key, required this.soTien});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Gọi tự động khi vào màn hình
    Future.microtask(payWithStripe);
  }

  Future<void> payWithStripe() async {
    setState(() => isLoading = true);

    final repo = StripeRepository();
    final clientSecret = await repo.createPaymentIntent(widget.soTien, 'vnd');
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
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thanh toán thất bại')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán thẻ')),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
      ),
    );
  }
}
