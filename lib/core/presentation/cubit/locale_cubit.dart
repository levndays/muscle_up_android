// lib/core/presentation/cubit/locale_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

const String _languageCodeKey = 'appLanguageCode';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(super.initialState);

  Future<void> setLocale(Locale newLocale) async {
    developer.log("Setting locale to ${newLocale.languageCode}", name: "LocaleCubit");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, newLocale.languageCode);
      emit(newLocale);
    } catch (e) {
      developer.log("Failed to save locale: $e", name: "LocaleCubit");
      // Still emit the change for the current session even if saving fails
      emit(newLocale);
    }
  }
}