import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/payment_provider.dart';
import 'screens/cash_payment_screen.dart';
import 'screens/payment_confirm_screen.dart';
import 'screens/payment_list_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/transfer_payment_screen.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/shop_viewmodel.dart';
import 'views/cart_view.dart';
import 'views/checkout_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ShopViewModel()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'App Coqui',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC63D2F)),
          scaffoldBackgroundColor: const Color(0xFFFFF7EF),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SessionGate(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartView(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutView(),
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentListScreen(),
    ),
    GoRoute(
      path: '/payments/method',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return PaymentMethodScreen(
          orderId: extra['orderId'] as int? ?? 0,
          amount: (extra['amount'] as num?)?.toDouble() ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/payments/transfer',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return TransferPaymentScreen(
          orderId: extra['orderId'] as int? ?? 0,
          amount: (extra['amount'] as num?)?.toDouble() ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/payments/cash',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return CashPaymentScreen(
          orderId: extra['orderId'] as int? ?? 0,
          amount: (extra['amount'] as num?)?.toDouble() ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/payments/confirm/:id',
      builder: (context, state) {
        final paymentId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return PaymentConfirmScreen(paymentId: paymentId);
      },
    ),
  ],
);

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late Future<bool> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = context.read<AuthViewModel>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomeView();
        }

        return const LoginView();
      },
    );
  }
}
