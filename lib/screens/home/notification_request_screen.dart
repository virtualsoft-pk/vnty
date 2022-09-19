import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/notification_model.dart';
import '../../services/services.dart';

class NotificationRequestScreen extends StatefulWidget {
  const NotificationRequestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationRequestScreen> createState() =>
      _NotificationRequestScreenState();
}

class _NotificationRequestScreenState extends State<NotificationRequestScreen> {
  NotificationModel get _notificationModel => context.read<NotificationModel>();

  void _onTapAccept() async {
    await _notificationModel.enableNotification();
    _gotoNextScreen();
  }

  void _onTapDecline() {
    _notificationModel.disableNotification();
    _gotoNextScreen();
  }

  void _gotoNextScreen() {
    if (Services().widget.isRequiredLogin) {
      Navigator.of(context).pushReplacementNamed(RouteList.login);
      return;
    }
    if (kAdvanceConfig.gdprConfig.showPrivacyPolicyFirstTime) {
      Navigator.of(context).pushReplacementNamed(RouteList.privacyTerms);
    } else {
      Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _onTapAccept,
              child: Text(S.current.allow.toUpperCase(),style: const TextStyle(color: Colors.white,),),
            ),
            OutlinedButton(
              onPressed: _onTapDecline,
              child: Text(S.current.decline.toUpperCase()),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(
                child: Icon(CupertinoIcons.bell, size: 120),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.current.notifyLatestOffer,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Text(S.current.weWillSendYouNotification),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
