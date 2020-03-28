import 'package:flutter/material.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:ozbargain/views/app.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
          ChangeNotifierProvider(create: (context)=> ThemeModel()),
        ],
      child: OzBargainApp()));

