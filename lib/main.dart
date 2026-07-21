import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/data/database_factory_config.dart';

void main() {
  configureDatabaseFactory();
  runApp(const AssetManagementApp());
}
