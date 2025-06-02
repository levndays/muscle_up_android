// FILE: lib/features/dashboard/presentation/widgets/upcoming_schedule_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../cubit/upcoming_schedule_cubit.dart';

class UpcomingScheduleWidget extends StatelessWidget {
  const UpcomingScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat dayFormatter = DateFormat('EEE'); // Пн, Вт
    final DateFormat dateFormatter = DateFormat('d MMM'); // 10 Січ

    return BlocBuilder<UpcomingScheduleCubit, UpcomingScheduleState>(
      builder: (context, state) {
        if (state is UpcomingScheduleLoading) {
          return Container(
            height: 120,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        } else if (state is UpcomingScheduleError) {
          return Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200)
            ),
            alignment: Alignment.center,
            child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red.shade700)),
          );
        } else if (state is UpcomingScheduleEmpty) {
           return Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey.shade100)
            ),
            alignment: Alignment.center,
            child: Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey.shade700)),
          );
        } else if (state is UpcomingScheduleLoaded) {
          final scheduleEntries = state.schedule.entries.toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UPCOMING SCHEDULE (NEXT 7 DAYS)',
                style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.bodyLarge?.color, // Використовуємо колір тексту теми
                      fontFamily: 'IBMPlexMono',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110, // Адаптуйте висоту за потребою
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: scheduleEntries.length,
                  itemBuilder: (ctx, index) {
                    final entry = scheduleEntries[index];
                    final date = entry.key;
                    final routinesForDay = entry.value;
                    bool isToday = date.year == DateTime.now().year &&
                                   date.month == DateTime.now().month &&
                                   date.day == DateTime.now().day;

                    return Card(
                      elevation: isToday ? 3 : 1.5,
                      margin: const EdgeInsets.only(right: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isToday ? theme.colorScheme.primary : Colors.grey.shade300,
                          width: isToday ? 1.5 : 0.8,
                        ),
                      ),
                      child: Container(
                        width: 120, // Адаптуйте ширину
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayFormatter.format(date).toUpperCase(),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isToday ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              dateFormatter.format(date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: routinesForDay.isEmpty
                                  ? Center(
                                      child: Text(
                                      'Rest Day',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade500,
                                      ),
                                    ))
                                  : ListView( // Щоб вмістити кілька рутин, якщо потрібно
                                      shrinkWrap: true,
                                      children: routinesForDay.map((routineName) => Text(
                                        routineName,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )).toList(),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink(); // Початковий стан або невизначений
      },
    );
  }
}