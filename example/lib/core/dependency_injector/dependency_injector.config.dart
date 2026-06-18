// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/account-info/bloc/account_info_bloc.dart' as _i785;
import '../../features/auth/login/bloc/login_bloc.dart' as _i475;
import '../../features/auth/register/bloc/register_bloc.dart' as _i38;
import '../../features/filter_view/bloc/filter_bloc.dart' as _i55;
import '../../features/hotel_details/childs/facilities_list/bloc/facilities_list_bloc.dart'
    as _i981;
import '../../features/hotel_details/childs/hotel_booking/bloc/hotel_booking_bloc.dart'
    as _i305;
import '../../features/hotel_details/childs/hotel_booking/childs/checkout/bloc/checkout_bloc.dart'
    as _i737;
import '../../features/hotel_details/hotel_details/bloc/hotel_details_bloc.dart'
    as _i785;
import '../../features/main_app/bloc/main_app_bloc.dart' as _i257;
import '../../features/onboarding/bloc/onboarding_bloc.dart' as _i327;
import '../../features/splash/bloc/splash_bloc.dart' as _i480;
import '../../features/tab/childs/booking/bloc/booking_bloc.dart' as _i638;
import '../../features/tab/childs/home/bloc/home_bloc.dart' as _i487;
import '../../features/tab/childs/home/childs/popular_items/bloc/popular_items_bloc.dart'
    as _i920;
import '../../features/tab/childs/home/childs/search/bloc/search_bloc.dart'
    as _i997;
import '../../features/tab/childs/setting/bloc/settings_bloc.dart' as _i1023;
import '../../features/tab/tab/bloc/tab_bloc.dart' as _i69;
import '../../services/app_token_refresh_handler.dart' as _i93;
import '../../services/client/auth_client.dart' as _i125;
import '../../services/client/common_client.dart' as _i270;
import '../../services/client/hotel_client.dart' as _i1048;
import '../../services/models/hotels/hotel_model.dart' as _i499;
import '../../services/models/hotels/hotel_requests.dart' as _i9;
import '../../utilities/constants/image_constants.dart' as _i207;
import '../../utilities/l10n/app_language_manager.dart' as _i104;
import '../location_services/location_manager.dart' as _i791;
import '../preferences/app_preferences.dart' as _i597;
import '../router/app_router.dart' as _i81;
import '../storage_services/hive_storage.dart' as _i739;
import '../storage_services/hive_storage_client.dart' as _i350;
import '../storage_services/models/booking.dart' as _i45;
import '../theme/theme_factory.dart' as _i332;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i791.LocationManager>(() => _i791.LocationManager());
    await gh.singletonAsync<_i597.AppPreferences>(
      () => _i597.AppPreferences.create(),
      preResolve: true,
    );
    gh.singleton<_i81.AppRouter>(() => _i81.AppRouter());
    gh.singleton<_i332.ThemeFactory>(() => _i332.ThemeFactory());
    gh.singleton<_i104.AppLanguageManager>(() => _i104.AppLanguageManager());
    gh.lazySingleton<_i350.HiveStorageClient>(() => _i350.HiveStorageClient());
    gh.lazySingleton<_i125.AuthClient>(() => _i125.AuthClient());
    gh.lazySingleton<_i1048.HotelClient>(() => _i1048.HotelClient());
    gh.lazySingleton<_i207.ImageConstants>(() => _i207.ImageConstants());
    gh.factoryParam<_i305.HotelBookingBloc, _i499.Hotel, dynamic>((
      hotel,
      _,
    ) =>
        _i305.HotelBookingBloc(hotel));
    gh.factory<_i785.AccountInfoBloc>(() => _i785.AccountInfoBloc(
          gh<_i597.AppPreferences>(),
          gh<_i125.AuthClient>(),
        ));
    gh.factory<_i475.LoginBloc>(() => _i475.LoginBloc(
          gh<_i597.AppPreferences>(),
          gh<_i125.AuthClient>(),
        ));
    gh.factory<_i38.RegisterBloc>(() => _i38.RegisterBloc(
          gh<_i597.AppPreferences>(),
          gh<_i125.AuthClient>(),
        ));
    gh.singleton<_i93.AppTokenRefreshHandler>(() => _i93.AppTokenRefreshHandler(
          gh<_i597.AppPreferences>(),
          gh<_i125.AuthClient>(),
        ));
    gh.factoryParam<_i55.FilterBloc, _i9.FilterHotelsRequest?, dynamic>((
      initialRequest,
      _,
    ) =>
        _i55.FilterBloc(
          gh<_i597.AppPreferences>(),
          initialRequest,
        ));
    gh.factoryParam<_i981.FacilitiesListBloc, List<_i499.Facility>, dynamic>((
      facilities,
      _,
    ) =>
        _i981.FacilitiesListBloc(facilities));
    gh.factory<_i257.MainAppBloc>(
        () => _i257.MainAppBloc(gh<_i597.AppPreferences>()));
    gh.factory<_i327.OnboardingBloc>(
        () => _i327.OnboardingBloc(gh<_i597.AppPreferences>()));
    gh.lazySingleton<_i270.CommonClient>(
        () => _i270.CommonClient(gh<_i597.AppPreferences>()));
    gh.factory<_i638.BookingBloc>(() => _i638.BookingBloc(
          gh<_i597.AppPreferences>(),
          gh<_i739.HiveStorageClient>(),
        ));
    gh.factory<_i487.HomeBloc>(() => _i487.HomeBloc(
          gh<_i1048.HotelClient>(),
          gh<_i125.AuthClient>(),
          gh<_i597.AppPreferences>(),
          gh<_i791.LocationManager>(),
        ));
    gh.factory<_i69.TabBloc>(
        () => _i69.TabBloc(pref: gh<_i597.AppPreferences>()));
    gh.factory<_i920.PopularItemsBloc>(() => _i920.PopularItemsBloc(
          gh<_i1048.HotelClient>(),
          gh<_i597.AppPreferences>(),
        ));
    gh.factory<_i997.SearchBloc>(() => _i997.SearchBloc(
          gh<_i1048.HotelClient>(),
          gh<_i597.AppPreferences>(),
        ));
    gh.factoryParam<_i785.HotelDetailsBloc, _i499.Hotel, dynamic>((
      hotel,
      _,
    ) =>
        _i785.HotelDetailsBloc(
          hotel,
          gh<_i597.AppPreferences>(),
          gh<_i1048.HotelClient>(),
        ));
    gh.factoryParam<_i737.CheckoutBloc, _i45.BookingModel, dynamic>((
      booking,
      _,
    ) =>
        _i737.CheckoutBloc(
          booking,
          gh<_i739.HiveStorageClient>(),
        ));
    gh.factory<_i1023.SettingsBloc>(() => _i1023.SettingsBloc(
          gh<_i597.AppPreferences>(),
          gh<_i270.CommonClient>(),
          gh<_i125.AuthClient>(),
          gh<_i350.HiveStorageClient>(),
        ));
    gh.factory<_i480.SplashBloc>(() => _i480.SplashBloc(
          pref: gh<_i597.AppPreferences>(),
          commonClient: gh<_i270.CommonClient>(),
        ));
    return this;
  }
}
