import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const Iterable<Locale> supportedLocales = [
  Locale('ar'),
];