import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:get/get.dart';

import 'secure/api_key.dart';

void main() {
  runApp(GanapatiWallpaperApp());
}

class GanapatiWallpaperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      
      title: 'Ganapati Wallpaper App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: WallpaperScreen(),
    );
  }
}

class WallpaperController extends GetxController {
  static const _pageSize = 19;
  final PagingController<int, String> pagingController = PagingController(firstPageKey: 1);
  bool isEndOfList = false;
  var selectedOption = 'Ganapati'.obs;

  @override
  void onInit() {
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    super.onInit();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      if (!isEndOfList) {
        final newItems = await fetchImages(selectedOption.value, pageKey);
        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          pagingController.appendPage(newItems, nextPageKey);
        }
        isEndOfList = true;
      } else {
        pagingController.addStatusListener((status) async {
          if (status == PagingStatus.completed) {
            final newItems = await fetchImages(selectedOption.value, pageKey);
            final isLastPage = newItems.length < _pageSize;
            if (isLastPage) {
              pagingController.appendLastPage(newItems);
            } else {
              final nextPageKey = pageKey + 1;
              pagingController.appendPage(newItems, nextPageKey);
            }
            isEndOfList = true;
          }
        });
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  Future<List<String>> fetchImages(String query, int page) async {
    final String apiKey = api_key;
<<<<<<< HEAD
=======
    // print("api key is: $apiKey");
>>>>>>> 1fcdce1c9d33ad286b4c931f8ccc226966896b6e
    final response = await http.get(
      Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=$_pageSize&page=$page'),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return (data['photos'] as List).map((item) => item['src']['large'] as String).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<void> downloadImage(String url) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        Directory? downloadsDir = await getDownloadsDirectory();
        String savePath = '${downloadsDir!.path}/${url.split('/').last}';
        await Dio().download(url, savePath);
        Get.snackbar('Success', 'Image downloaded successfully',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 2));
      } catch (e) {
        Get.snackbar('Error', 'Failed to download image',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 2));
      }
    } else {
      Get.snackbar('Error', 'Permission denied',
        snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 2));
    }
  }

  Future<void> setWallpaper(String url) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        var file = await downloadImageForWallpaper(url);
        final bool result = await WallpaperManager.setWallpaperFromFile(file.path, WallpaperManager.HOME_SCREEN);
        if (result) {
          Get.snackbar('Success', 'Wallpaper set successfully',
            snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 2));
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to set wallpaper',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 2));
      }
    } else {
      Get.snackbar('Error', 'Permission denied',
        snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 2));
    }
  }

  Future<File> downloadImageForWallpaper(String url) async {
    Directory? downloadsDir = await getDownloadsDirectory();
    String savePath = '${downloadsDir!.path}/${url.split('/').last}';
    await Dio().download(url, savePath);
    return File(savePath);
  }

  void changeOption(String option) {
    selectedOption.value = option;
    isEndOfList = false;
    pagingController.refresh();
  }
}


class WallpaperScreen extends StatelessWidget {
  final WallpaperController controller = Get.put(WallpaperController());
  final List<String> options = [
    'Ganapati', 'Chintamani','Ganesha', 'Vinayaka', 'chaturthi' ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Ganapati Wallpapers 2024', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          
          Container(
            height: 50,
            margin: EdgeInsets.only(top: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  return GestureDetector(
                    onTap: () {
                      controller.changeOption(options[index]);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: controller.selectedOption.value == options[index] ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Center(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            color: controller.selectedOption.value == options[index] ? Colors.white : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                controller.isEndOfList = false;
                controller.pagingController.refresh();
              },
              child: PagedGridView<int, String>(
                pagingController: controller.pagingController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 0.75,
                ),
                builderDelegate: PagedChildBuilderDelegate<String>(
                  itemBuilder: (context, item, index) => GestureDetector(
                    onTap: () {
                      _showOptionsBottomSheet(context, item);
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: item,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (context) {
                    return Center(
                      child: Text(
                        controller.isEndOfList ? 'You have reached the end of all images' : 'Loading...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 300,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.download),
                label: Text('Download'),
                onPressed: () {
                  controller.downloadImage(imageUrl);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.wallpaper),
                label: Text('Set Wallpaper'),
                onPressed: () {
                  controller.setWallpaper(imageUrl);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
