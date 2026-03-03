import 'package:assignment_news/core/local_storage/database_helper.dart';
import 'package:assignment_news/core/network/api_client.dart';
import 'package:assignment_news/features/news/data/datasources/news_local_data_source.dart';
import 'package:assignment_news/features/news/data/datasources/news_remote_data_source.dart';
import 'package:assignment_news/features/news/data/repositories/news_repository_impl.dart';
import 'package:assignment_news/features/news/domain/repositories/news_repository.dart';
import 'package:assignment_news/features/news/domain/usecases/get_news_usecase.dart';
import 'package:assignment_news/features/news/presentation/bloc/news_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => NewsBloc(getNewsUseCase: sl()));

  sl.registerLazySingleton(() => GetNewsUseCase(sl()));

  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(db: sl()),
  );

  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => DatabaseHelper.instance);
}
