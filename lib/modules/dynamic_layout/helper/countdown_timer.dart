import 'package:flutter/material.dart';

class CountDownTimer extends StatelessWidget {
  final Duration countdownDuration;
  final VoidCallback? onEnd;

  const CountDownTimer(this.countdownDuration, {Key? key, this.onEnd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const size = 22.0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: TweenAnimationBuilder<Duration>(
        duration: countdownDuration,
        tween: Tween(begin: countdownDuration, end: Duration.zero),
        onEnd: () {
          /// Timer ended
          if (onEnd != null) {
            onEnd!();
          }
        },
        builder: (BuildContext context, Duration value, Widget? child) {
          if (value.inMilliseconds == 0) {
            return const SizedBox();
          }
          final seconds = value.inSeconds % 60;
          final minutes = value.inMinutes % 60;
          final hours = value.inHours;
          final days = value.inDays;
          var listView = [hours, ':', minutes, ':', seconds];
          if (hours > 24) {
            listView = [days, ':', '24', ':', minutes, ':', seconds];
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: listView
                .map(
                  (item) => item == ':'
                      ? Container(
                          alignment: Alignment.center,
                          height: size,
                          child: Text(
                            '$item',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 1.0,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: size,
                            minHeight: size,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 6.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColorLight
                                .withOpacity(0.7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '$item'.toString().padLeft(2, '0'),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
