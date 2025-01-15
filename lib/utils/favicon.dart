import 'package:filo/services/navigator_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

Future<Widget> getFavicon(String url, double size) async {
  try {
    final response = await http.head(Uri.parse(url));
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];

      if (contentType != null && contentType.contains('image/svg+xml')) {
        return SvgPicture.network(url,
            width: size,
            height: size,
            color: Theme.of(NavigatorService.navigatorKey.currentContext!)
                .colorScheme
                .onSurface);
      } else {
        return Image.network(url, width: size, height: size);
      }
    } else {
      return Icon(CupertinoIcons.globe,
          color: Theme.of(NavigatorService.navigatorKey.currentContext!)
              .colorScheme
              .onSurface);
    }
  } catch (e) {
    return Icon(CupertinoIcons.globe,
        color: Theme.of(NavigatorService.navigatorKey.currentContext!)
            .colorScheme
            .onSurface);
  }
}
