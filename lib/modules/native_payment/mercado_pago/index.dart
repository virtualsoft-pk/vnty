import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/index.dart' show AppModel, CartModel, Product;
import 'services.dart';

class MercadoPagoPayment extends StatefulWidget {
  final Function? onFinish;

  const MercadoPagoPayment({this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return MercadoPagoPaymentState();
  }
}

class MercadoPagoPaymentState extends State<MercadoPagoPayment> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final MercadoPagoServices _services = MercadoPagoServices();
  String? url;
  String? id = '';
  final kReturnSuccessUrl = serverConfig['url'] + '/success';

  Map<String, dynamic> getOrderParams() {
    var cartModel = Provider.of<CartModel>(context, listen: false);
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    List items = cartModel.productsInCart.keys.map(
      (key) {
        var productId = Product.cleanProductID(key);

        final product = cartModel.getProductById(productId);
        final variation = cartModel.getProductVariationById(key);
        final price = variation != null ? variation.price! : product!.price!;

        return {
          'title': product!.name,
          'description': '',
          'quantity': cartModel.productsInCart[key],
          'unit_price': double.parse(price),
          'currency_id': currency
        };
      },
    ).toList();

    var temp = <String, dynamic>{
      'items': items,
      'back_urls': {'success': kReturnSuccessUrl},
    };

    return temp;
  }

  Future<void> customWebViewListener(WebViewController controller) async {
    var currentUrl = await (controller.currentUrl() as Future<String>);
    if (currentUrl.contains(kReturnSuccessUrl) ||
        currentUrl.contains('congrats/approved')) {
      widget.onFinish!(id);
      Navigator.of(context).pop();
    } else {
      await Future.delayed(const Duration(seconds: 2))
          .then((value) => customWebViewListener(controller));
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var map = await _services.getPaymentUrl(getOrderParams());
      url = map['paymentUrl'];
      id = map['orderId'];
      if (url == null) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          leading: GestureDetector(
            onTap: () {
              widget.onFinish!(null);
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: WebView(
          initialUrl: url,
          onWebViewCreated: customWebViewListener,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains(kReturnSuccessUrl) ||
                request.url.contains('congrats/approved')) {
              widget.onFinish!(id);
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    }
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                widget.onFinish!(null);
                Navigator.of(context).pop();
              }),
          backgroundColor: kGrey200,
          elevation: 0.0,
        ),
        body: Container(child: kLoadingWidget(context)),
      ),
    );
  }
}
