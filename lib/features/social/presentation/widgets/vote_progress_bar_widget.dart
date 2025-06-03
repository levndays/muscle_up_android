// lib/features/social/presentation/widgets/vote_progress_bar_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoteProgressBarWidget extends StatelessWidget {
  final int verifyCount;
  final int disputeCount;
  final double height;
  final Color verifyColor; // Колір передається ззовні
  final Color disputeColor; // Колір передається ззовні
  final Color backgroundColor;
  final TextStyle? centerTextStyle;

  const VoteProgressBarWidget({
    super.key,
    required this.verifyCount,
    required this.disputeCount,
    this.height = 20.0,
    this.verifyColor = const Color(0xFF0A8754), // Оновлений дефолтний (хоча він буде перезаписаний)
    this.disputeColor = const Color(0xFFEF2917), // Оновлений дефолтний (хоча він буде перезаписаний)
    this.backgroundColor = Colors.black26, 
    this.centerTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final int totalVotes = verifyCount + disputeCount;
    final double verifyRatio = totalVotes > 0 ? verifyCount / totalVotes : 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                return Row(
                  children: [
                    Container(
                      width: maxWidth * verifyRatio,
                      decoration: BoxDecoration(
                        color: verifyColor, // Використовуємо переданий колір
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(height / 2),
                          bottomLeft: Radius.circular(height / 2),
                          topRight: Radius.circular(totalVotes > 0 && verifyRatio < 1.0 ? 0 : height / 2),
                          bottomRight: Radius.circular(totalVotes > 0 && verifyRatio < 1.0 ? 0 : height / 2),
                        ),
                      ),
                    ),
                    if (verifyRatio < 1.0)
                      Expanded(
                        child: Container(
                           decoration: BoxDecoration(
                            color: disputeColor, // Використовуємо переданий колір
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(height / 2),
                              bottomRight: Radius.circular(height / 2),
                              topLeft: Radius.circular(totalVotes > 0 && verifyRatio > 0.0 ? 0 : height/2),
                              bottomLeft: Radius.circular(totalVotes > 0 && verifyRatio > 0.0 ? 0 : height/2),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Center(
              child: Text(
                '$verifyCount / $disputeCount',
                style: centerTextStyle ?? const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}