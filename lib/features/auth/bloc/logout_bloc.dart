// lib/features/auth/bloc/logout_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';

// Events
abstract class LogoutEvent {}

class LogoutRequested extends LogoutEvent {}

// States
abstract class LogoutState {}

class LogoutInitial extends LogoutState {}

class LogoutLoading extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String error;
  LogoutFailure(this.error);
}

// BLoC
class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final FirebaseAuth _auth;

  LogoutBloc({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      super(LogoutInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LogoutState> emit,
  ) async {
    try {
      emit(LogoutLoading());

      // Log analytics
      AnalyticsService.logEvent('logout', {'method': 'menu_drawer'});

      // Sign out
      await _auth.signOut();

      // Small delay to ensure sign out is complete
      await Future.delayed(const Duration(milliseconds: 300));

      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutFailure(e.toString()));
    }
  }
}
