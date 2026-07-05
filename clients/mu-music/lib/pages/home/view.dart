/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-23 13:13:54
 * @LastEditTime: 2025-10-04 17:06:21
 * @FilePath: /mu-music/lib/pages/home/view.dart
 * @Description: 首页视图
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mu_music/common/index.dart';
import 'package:mu_music/pages/home/widgets/buildSection.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'index.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _HomeViewGetX();
  }
}

class _HomeViewGetX extends GetView<HomeController> {
  _HomeViewGetX();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      id: "home",
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.appBg,

          /// 头部搜索
          appBar: AppBar(
            backgroundColor: AppColors.navigationBg,
            leading: Image.asset(AssetsImages.logoPng),
            title: Padding(
              padding: EdgeInsets.only(top: 2, bottom: 2, left: 0),
              child: GestureDetector(
                onTap: () {
                  Get.toNamed('/search_page');
                },
                child: Container(
                  height: 35,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 1,
                      color: AppColors.borderColor,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Image.asset(AssetsImages.searchPng)),
                      Text("搜索歌曲、歌手、专辑",
                          style: TextStyle(color: Colors.grey, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: controller.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: AppColors.primaryBtn,
                        size: 30,
                      ),
                    ],
                  ),
                )
              : ListView(children: [
                  // 推荐歌曲 section
                  SizedBox(
                    height: 265,
                    child: ListView(
                      padding: EdgeInsets.all(8),
                      // 设置为水平方向
                      scrollDirection: Axis.horizontal,
                      // 每个item的宽度
                      itemExtent: 190,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: buildRecommendSection(
                                controller.recommendListModel)),
                        // 私人雷达
                        if (controller.playlistPrivateModel.isNotEmpty &&
                            controller.playlistPrivateModel['name'] != null &&
                            controller.playlistPrivateModel['coverImgUrl'] !=
                                null)
                          Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: buildCard(
                                  controller.playlistPrivateModel['name'],
                                  controller
                                      .playlistPrivateModel['coverImgUrl'],
                                  controller.playlistPrivateModel['id'])),
                        // 时光雷达
                        if (controller.playlistTimeModel.isNotEmpty &&
                            controller.playlistTimeModel['name'] != null &&
                            controller.playlistTimeModel['coverImgUrl'] != null)
                          Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: buildCard(
                                  controller.playlistTimeModel['name'],
                                  controller.playlistTimeModel['coverImgUrl'],
                                  controller.playlistTimeModel['id'])),
                        // 新歌雷达
                        if (controller.playlistNewModel.isNotEmpty &&
                            controller.playlistNewModel['name'] != null &&
                            controller.playlistNewModel['coverImgUrl'] != null)
                          buildCard(
                              controller.playlistNewModel['name'],
                              controller.playlistNewModel['coverImgUrl'],
                              controller.playlistNewModel['id']),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/recommend', arguments: {'tabIndex': 0});
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      color: Colors.red.withValues(alpha: 0),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('推荐歌单',
                              style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.secondaryText,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 推荐歌单
                  SizedBox(
                    height: 265,
                    child: ListView.builder(
                      itemCount: controller.personalizedListModel.length,
                      padding: EdgeInsets.all(8),
                      scrollDirection: Axis.horizontal,
                      itemExtent: 190,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: buildCard(
                              controller.personalizedListModel[index]['name'],
                              controller.personalizedListModel[index]['picUrl'],
                              controller.personalizedListModel[index]['id']),
                        );
                      },
                    ),
                  ),
                  // 热门歌手
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/recommend', arguments: {'tabIndex': 1});
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      color: Colors.red.withValues(alpha: 0),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('热门歌手',
                              style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.secondaryText,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      scrollDirection: Axis.horizontal,
                      itemExtent: 120,
                      itemCount: controller.singersListModel.length,
                      itemBuilder: (context, index) {
                        return buildSingerCard(
                            controller.singersListModel[index]['id'],
                            controller.singersListModel[index]['name'],
                            controller.singersListModel[index]['picUrl'],
                            controller.singersListModel[index]['musicSize']);
                      },
                    ),
                  ),
                ]),
        );
      },
    );
  }
}
