/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-12 07:40:48
 * @LastEditTime: 2025-10-10 14:01:51
 * @FilePath: /mu-music/lib/main.dart
 * @Description: 沐音APP - 入口文件
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mu_music/common/index.dart';
import 'package:mu_music/pages/desktop_music_home.dart';
import 'package:mu_music/pages/index.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  Get.put(UserStore());
  Get.put(TokenStore());
  Get.put(PlaylistStore());
  Get.put(GlobalPlayerStore());
  Get.put(GlobalMusicController());
  Get.put(ThemeStore());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  // 创建状态
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 底部菜单列表
  final List<Widget> _navigationItem = [
    Image.asset(AssetsImages.homePng),
    Image.asset(AssetsImages.myPng),
  ];

  /// 底部菜单页面列表
  final List<Widget> _navigationPage = [
    HomePage(),
    UserPage(),
  ];

  static int indexNow = 0;
  // 构建UI
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeStore>(
      builder: (themeStore) {
        return GetMaterialApp(
          getPages: RoutePages.list,
          title: '沐音',
          theme: ThemeData(
            brightness:
                themeStore.darkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: AppColors.appBg,
            primaryColor: AppColors.primaryBtn,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBtn,
              primary: AppColors.primaryBtn,
              brightness:
                  themeStore.darkMode ? Brightness.dark : Brightness.light,
            ),
            fontFamily: 'CustomFont',
            useMaterial3: false,
          ),
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (_useDesktopLayout(constraints.maxWidth)) {
                  return DesktopMusicHome();
                }
                return Scaffold(
                  extendBodyBehindAppBar: true,
                  backgroundColor: AppColors.appBg,
                  body: IndexedStack(
                    index: indexNow,
                    children: _navigationPage,
                  ),
                  bottomNavigationBar: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 12, bottom: 6),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ThemeToggleButton(),
                        ),
                      ),
                      // 底部播放栏
                      BottomPlayerBar(),
                      // 底部导航栏
                      CurvedNavigationBar(
                        color: AppColors.navigationBg,
                        backgroundColor: Colors.transparent,
                        animationDuration: Duration(milliseconds: 300),
                        items: _navigationItem,
                        onTap: (index) {
                          setState(() {
                            indexNow = index;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  bool _useDesktopLayout(double width) {
    return width >= 900 ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
}
