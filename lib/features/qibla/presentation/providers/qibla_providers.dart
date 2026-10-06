import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/compass_heading_data_source.dart';

final compassHeadingDataSourceProvider = Provider<CompassHeadingDataSource>(
  (ref) => const CompassHeadingDataSource(),
);

final compassHeadingProvider = StreamProvider.autoDispose<double?>((ref) {
  return ref.watch(compassHeadingDataSourceProvider).headings;
});
