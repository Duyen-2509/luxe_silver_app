import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class StripeRepository {
  final String baseUrl = ApiService().baseUrl;

  /// Tạo PaymentIntent trên server và trả về clientSecret
  Future<String?> createPaymentIntent(int amount, String currency) async {
    print('Stripe request##########: amount=$amount, currency=$currency');
    final response = await http.post(
      Uri.parse('${baseUrl}stripe/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount, 'currency': currency}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['clientSecret'];
    }
    return null;
  }
}
