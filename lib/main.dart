import 'package:conference_2023/app.dart';
import 'package:conference_2023/model/messaging.dart';
import 'package:conference_2023/model/remote_config.dart';
import 'package:conference_2023/model/shared_preferences.dart';
import 'package:conference_2023/util/font_lisence.dart';
import 'package:conference_2023/util/web/firebase_options_web.dart';
import 'package:conference_2023/util/web/path_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // runApp が呼ばれる前の初期化処理
  WidgetsFlutterBinding.ensureInitialized();
  // Flutter のパスをURLのパスにする。
  // Web だけ動作する処理
  updatePathStrategy();
  await Firebase.initializeApp(
    options: firebaseOptionsWeb,
  );

  // Firebase Crashlytics で例外を送信する
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };

  /// initialize firebase apps
  await initFirebaseRemoteConfig();
  await initFirebaseMessaging();
  // ライセンス表示のカスタマイズ
  fontLicenses();
  // 設定の取得
  final pref = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        /// This is a trick to get instances of SharedPreferences synchronously.
        /// Note: Because of this trick, [sharedPreferencesProvider] behaves
        /// differently from a normal [Provider].
        sharedPreferencesProvider.overrideWithValue(pref),
      ],
      child: const App(),
    ),
  );
}
