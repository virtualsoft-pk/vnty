import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http_auth/http_auth.dart';

class makePayment extends StatefulWidget {
  @override
  _makePaymentState createState() => _makePaymentState();
}

class _makePaymentState extends State<makePayment> {
  TextStyle style = TextStyle(fontFamily: 'Open Sans', fontSize: 15.0);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45.0),
        child: new AppBar(
          backgroundColor: Colors.white,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Paypal Payment Example',
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Open Sans'),
              ),
            ],
          ),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // make PayPal payment

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => PaypalPayment(
                          onFinish: (number) async {
                            // payment done
                            print('order id: ' + number);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Pay with Paypal',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class PaypalPayment extends StatefulWidget {
  final Function onFinish;

  PaypalPayment({required this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var checkoutUrl;
  var executeUrl;
  var accessToken;
  PaypalServices services = PaypalServices();

  // you can change default currency according to your need
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "USD ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD"
  };

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();
        print("accessToken is $checkoutUrl");

        final transactions = getOrderParams();
        final res =
            await services.createPaypalPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];
          });
        }
      } catch (e) {
        print('exception: ' + e.toString());
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
              Navigator.pop(context);
            },
          ),
        );
        // ignore: deprecated_member_use
        _scaffoldKey.currentState!.showSnackBar(snackBar);
      }
    });
  }

  // item name, price and quantity
  String itemName = 'iPhone X';
  String itemPrice = '1.99';
  int quantity = 1;

  Map<String, dynamic> getOrderParams() {
    List items = [
      {
        "name": itemName,
        "quantity": quantity,
        "price": itemPrice,
        "currency": defaultCurrency["currency"]
      }
    ];

    // checkout invoice details
    String totalAmount = '1.99';
    String subTotalAmount = '1.99';
    String shippingCost = '0';
    int shippingDiscountCost = 0;
    String userFirstName = 'Gulshan';
    String userLastName = 'Yadav';
    String addressCity = 'Delhi';
    String addressStreet = 'Mathura Road';
    String addressZipCode = '110014';
    String addressCountry = 'India';
    String addressState = 'Delhi';
    String addressPhoneNumber = '+919990119091';

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": subTotalAmount,
              "shipping": shippingCost,
              "shipping_discount": ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
            if (isEnableShipping && isEnableAddress)
              "shipping_address": {
                "recipient_name": userFirstName + " " + userLastName,
                "line1": addressStreet,
                "line2": "",
                "city": addressCity,
                "country_code": addressCountry,
                "postal_code": addressZipCode,
                "phone": addressPhoneNumber,
                "state": addressState
              },
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    print("checkOut url $checkoutUrl");

    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              final payerID = uri.queryParameters['PayerID'];
              if (payerID != null) {
                services
                    .executePayment(executeUrl, payerID, accessToken)
                    .then((id) {
                  widget.onFinish(id);
                  Navigator.of(context).pop();
                });
              } else {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pop();
            }
            if (request.url.contains(cancelURL)) {
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: Center(child: Container(child: CircularProgressIndicator())),
      );
    }
  }
}

class PaypalServices {
  String domain = "https://api.sandbox.paypal.com"; // for sandbox mode
//  String domain = "https://api.paypal.com"; // for production mode

  // change clientId and secret with your own, provided by paypal
  String clientId =
      'Ab4vS4vmfQFgUuQMH49F9Uy3L1FdNHtfGrASCyjNijm_EkHWCFM96ex0la-YFbwavw41R3rTKU3k_Bbm';
  String secret =
      'EDjvPfYgTYqdYWR2BfOiBW4dz_jeeuadqH7Z98pZMDvY33PcViiooqYFWVPFSGbfKBfNOb3LnroSI1hv';

  // for getting the access token from Paypal
  Future<String> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      print("clinet is ${client.username}");
      var response = await client.post(
          Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return body["access_token"];
      }
      return "0";
    } catch (e) {
      rethrow;
    }
  }

  // for creating the payment request with Paypal
  Future<Map<String, String>> createPaypalPayment(
      transactions, accessToken) async {
    try {
      var response = await http.post(Uri.parse("$domain/v1/payments/payment"),
          body: convert.jsonEncode(transactions),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];

          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approval_url",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute",
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
        throw Exception("0");
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  // for executing the payment transaction
  Future<String> executePayment(url, payerId, accessToken) async {
    try {
      var response = await http.post(url,
          body: convert.jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body["id"];
      }
      return "0";
    } catch (e) {
      rethrow;
    }
  }
}
