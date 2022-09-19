import 'package:flutter/material.dart';

import '../models/cart/cart_model.dart';
import '../services/index.dart';
import 'entities/payment_method.dart';
import 'entities/shipping_method.dart';

class PaymentMethodModel extends ChangeNotifier {
  final Services _service = Services();
  late List<PaymentMethod> paymentMethods;
  bool isLoading = true;
  String? message;

  Future<void> getPaymentMethods(
      {CartModel? cartModel,
      ShippingMethod? shippingMethod,
      String? token,
      required String? langCode}) async {
    try {
      paymentMethods = await _service.api.getPaymentMethods(
          cartModel: cartModel,
          shippingMethod: shippingMethod,
          token: token,
          langCode: langCode)!;
      isLoading = false;
      message = null;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message =
          'There is an issue with the app during request the data, please contact admin for fixing the issues $err';
      notifyListeners();
    }
  }
}
