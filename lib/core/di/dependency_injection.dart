import 'package:get_it/get_it.dart';

import 'injection_container.dart';

Future<void> initDependencyInjection() async {
  await configureDependencies();
}

GetIt get serviceLocator => sl;
