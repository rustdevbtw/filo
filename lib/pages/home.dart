// Home Page
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:native_qr/native_qr.dart';
import 'package:webview_cef/webview_cef.dart';
import 'package:filo/globals.dart';
import 'package:filo/api/special/special.dart';
import 'package:filo/api/api.dart';
import 'package:filo/ui/theme.dart';
import 'package:filo/utils/favicon.dart';
import 'package:flutter/cupertino.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  late WebViewController _webviewController;
  String _tempUrl = initialUrl;
  final ValueNotifier<String> _title = ValueNotifier("Filo");
  final ValueNotifier<String> _faviconUrl = ValueNotifier("");
  final WebviewEventsListener _webviewListener = WebviewEventsListener();

  void onUrlChanged(String url) async {
    currentUrl.value = url;
    final Set<JavascriptChannel> jsChannels = {
      JavascriptChannel(
          name: 'sendMsg',
          onMessageReceived: (JavascriptMessage message) async {
            final p = jsonDecode(message.message) as Map<String, dynamic>;
            ApiResult r = ApiResult();
            String method = p["method"];
            List<dynamic> args = p["args"];
            if (jsFunctions[method] != null) {
              r = await jsFunctions[method]!(args);
            } else {
              r.error = "UNKNOWN_METHOD";
            }

            await _webviewController.sendJavaScriptChannelCallBack(
                r.err != null, r.out, message.callbackId, message.frameId);
          }),
    };
    //normal JavaScriptChannels
    await _webviewController.setJavaScriptChannels(jsChannels);
  }

  void onTitleChanged(String title) {
    if (title.length >= 50) {
      _title.value = '${title.substring(0, 51)}...';
    } else {
      _title.value = title;
    }
    if (isDesktop) {
      setWindowTitle('$title - Filo');
    }
  }

  void onFaviconURLChanged(String faviconUrl) {
    _faviconUrl.value = faviconUrl;
  }

  @override
  void initState() {
    _webviewController = WebviewManager().createWebView();
    initPl();
    _webviewListener.onUrlChanged = onUrlChanged;
    _webviewListener.onTitleChanged = onTitleChanged;
    _webviewListener.onFaviconURLChanged = onFaviconURLChanged;
    _webviewListener.onLoadStart = (WebViewController wvc, String? url) {
      Color text = isDarkMode.value ? frappe.text : latte.text;
      Color back = isDarkMode.value ? frappe.surface0 : latte.surface0;
      wvc.executeJavaScript("navigator.isFilo = true");
      wvc.executeJavaScript('''
      let st = document.createElement('style');
      st.innerText = '* { color: rgb(${text.r * 100}% ${text.g * 100}% ${text.b * 100}% / ${text.a * 100}%); backgroundColor: rgb(${back.r * 100}% ${back.g * 100}% ${back.b * 100}% / ${back.a * 100}%); }';
      document.body.prepend(st);
      ''');
      wvc.executeJavaScript(methods.join("\n"));
    };
    _webviewController.setWebviewListener(_webviewListener);
    super.initState();
  }

  void cleanup() {
    _webviewController.dispose();
    WebviewManager().dispose();
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }

  Future<void> initPl() async {
    await WebviewManager().initialize(userAgent: "Filo/1.0.0");
    await _webviewController.initialize(currentUrl.value);
    if (!mounted) return;
  }

  Future<void> goto() async {
    await _webviewController.loadUrl(currentUrl.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Flex(
          direction: Axis.horizontal,
          children: [
            IconButton(
              onPressed: changeTheme,
              tooltip: 'Change Theme',
              icon: Icon(isDarkMode.value ? iconLight : iconDark),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Spacer(),
            ValueListenableBuilder(
                valueListenable: _faviconUrl,
                builder: (_, i, __) {
                  return FutureBuilder(
                      future: getFavicon(i, 26),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Icon(Icons.error);
                        } else {
                          return snapshot.data!;
                        }
                      });
                }),
            SizedBox(width: 18),
            ValueListenableBuilder(
                valueListenable: _title,
                builder: (_, t, __) {
                  return Text(t);
                }),
            Spacer(),
            if (isDesktop)
              IconButton(
                onPressed: () async {
                  exit(0);
                },
                tooltip: 'Close',
                icon: Icon(Icons.close),
                color: frappe.red,
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: isMobile
          ? Center(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.tertiary,
                    boxShadow: [BoxShadow(blurRadius: 5)],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: ValueListenableBuilder<String>(
                    valueListenable: qrScanResult,
                    builder: (ctx, other, _) {
                      return Text(other);
                    },
                  )))
          : Column(children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(children: <Widget>[
                    IconButton(
                      onPressed: () async {
                        await _webviewController.goBack();
                      },
                      tooltip: 'Back',
                      icon: Icon(Icons.arrow_back_ios_sharp),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    IconButton(
                      onPressed: () async {
                        await _webviewController.reload();
                      },
                      tooltip: 'Refresh',
                      icon: Icon(Icons.refresh),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    IconButton(
                      onPressed: () async {
                        await _webviewController.goForward();
                      },
                      tooltip: 'Forward',
                      icon: Icon(Icons.arrow_forward_ios_sharp),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: currentUrl,
                            builder: (ctx, c, _) {
                              return Container(
                                  margin: const EdgeInsets.fromLTRB(8, 5, 0, 2),
                                  child: TextFormField(
                                    key: UniqueKey(),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        fontSize: 15),
                                    textAlign: TextAlign.center,
                                    cursorColor: frappe.subtext0,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(18)),
                                            borderSide: BorderSide(
                                                width: 0,
                                                style: BorderStyle.none)),
                                        hintText: "Enter the URL",
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        filled: true),
                                    initialValue: c,
                                    onFieldSubmitted: (String? v) async {
                                      currentUrl.value = _tempUrl;
                                      await goto();
                                    },
                                    onChanged: (String v) async {
                                      _tempUrl = v;
                                    },
                                  ));
                            })),
                    SizedBox(width: 3),
                    IconButton(
                        onPressed: () async {
                          currentUrl.value = _tempUrl;
                          await goto();
                        },
                        icon: Icon(CupertinoIcons.arrow_right_square_fill,
                            size: 32),
                        hoverColor: Theme.of(context).colorScheme.surface),
                    IconButton(
                      onPressed: () async {
                        await _webviewController.openDevTools();
                      },
                      tooltip: 'Open DevTools',
                      icon: Icon(Icons.developer_mode),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ])),
              ValueListenableBuilder(
                  valueListenable: _webviewController,
                  builder: (ctx, ct, _) {
                    return ct
                        ? Expanded(child: _webviewController.webviewWidget)
                        : _webviewController.loadingWidget;
                  })
            ]),
      // : Webview(url: "https://google.com"))),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () async {
                NativeQr qr = NativeQr();
                String? res = await qr.get();
                if (res != null) qrScanResult.value = res;
              },
              tooltip: 'Scan',
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              child: Icon(Icons.qr_code_scanner),
            )
          : Text(""),
    );
  }
}
