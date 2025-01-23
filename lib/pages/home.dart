// Home Page
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veil/veil.dart';
import 'package:window_size/window_size.dart';
import 'package:native_qr/native_qr.dart';
import 'package:webview_cef/webview_cef.dart';
import 'package:filo/globals.dart';
import 'package:filo/api/special/special.dart';
import 'package:filo/api/api.dart';
import 'package:filo/ui/theme.dart';
import 'package:filo/utils/favicon.dart';
import 'package:flutter/cupertino.dart';
import 'package:filo/utils/overlay.dart';

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
      wvc.executeJavaScript("navigator.isFilo = true");
      wvc.executeJavaScript('''
      let st = document.createElement('style');
      st.innerText = '* { backgroundColor: white; }';
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
    return VlPage(
      appBar: VlAppBar(
        leftWidgets: <Widget>[
          if (isMobile)
            VlButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                icon: Icon(CupertinoIcons.back)),
          VlButton(
            onPressed: changeTheme,
            tooltip: 'Change Theme',
            icon:
                Icon((currentTheme.value == darkTheme) ? iconDark : iconLight),
          ),
        ],
        centerWidgets: <Widget>[
          if (isDesktop)
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
        ],
        rightWidgets: <Widget>[
          if (isDesktop)
            VlButton(
              onPressed: () async {
                exit(0);
              },
              tooltip: 'Close',
              icon: Icon(Icons.close),
              color: frappe.red,
            ),
        ],
      ),
      body: isMobile
          ? Center(
              child: ValueListenableBuilder(
                  valueListenable: qrScanResult,
                  builder: (ctx, q, _) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(ctx).colorScheme.secondary),
                      child: Text(q),
                    );
                  }),
            )
          : Column(children: <Widget>[
            Container(margin: EdgeInsets.all(18), child: VlBar(
              leftWidgets: <Widget>[
                VlButton(
                  onPressed: () async {
                    print("UNIMPLEMENTED!");
                  },
                  tooltip: "Open Sidebar",
                  icon: Icon(CupertinoIcons.sidebar_left),
                ),
                VlButton(
                  onPressed: () async {
                    await _webviewController.goBack();
                  },
                  tooltip: 'Back',
                  icon: Icon(CupertinoIcons.back),
                ),
                VlButton(
                  onPressed: () async {
                    await _webviewController.reload();
                  },
                  tooltip: 'Refresh',
                  icon: Icon(CupertinoIcons.refresh),
                ),
                VlButton(
                  onPressed: () async {
                    await _webviewController.goForward();
                  },
                  tooltip: 'Forward',
                  icon: Icon(CupertinoIcons.forward),
                ),
              ],
              center: MouseRegion(
                        cursor: SystemMouseCursors.text,
                        child: ValueListenableBuilder(
                            valueListenable: currentUrl,
                            builder: (ctx, c, _) {
                              return GestureDetector(
                                onTap: () async {
                                  FocusNode focusNode = FocusNode();
                                  FocusScope.of(context)
                                      .requestFocus(focusNode);
                                  late OverlayEntry overlayEntry;
                                  overlayEntry = await openOverlay(
                                      context: context,
                                      child: Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              8, 5, 0, 2),
                                          padding: EdgeInsets.all(20),
                                          child: TextFormField(
                                            autofocus: true,
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
                                                    borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(
                                                            12)),
                                                    borderSide: BorderSide(
                                                        width: 0,
                                                        style: BorderStyle
                                                            .none)),
                                                hintText: "Enter the URL",
                                                fillColor: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                filled: true,
                                                suffixIcon: Icon(
                                                    CupertinoIcons
                                                        .right_chevron)),
                                            initialValue: currentUrl.value,
                                            onFieldSubmitted:
                                                (String? v) async {
                                              currentUrl.value = _tempUrl;
                                              await goto();
                                              overlayEntry.remove();
                                            },
                                            onChanged: (String v) async {
                                              _tempUrl = v;
                                            },
                                          )));
                                },
                                child: Container(
                                  margin:
                                  const EdgeInsets.fromLTRB(8, 5, 0, 2),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                    Theme.of(ctx).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Theme.of(ctx)
                                            .colorScheme
                                            .onSurface,
                                        width: 0.5),
                                  ),
                                  child:
                                  Text(c, textAlign: TextAlign.center),
                                ),
                              );
                            })),
              rightWidgets: <Widget>[
                VlButton(
                  onPressed: () {
                    print("UNIMPLEMENTED");
                  },
                  icon: Icon(CupertinoIcons.star),
                  tooltip: "Bookmark this page",
                ),
                VlButton(
                  onPressed: () async {
                    await _webviewController.openDevTools();
                  },
                  tooltip: 'Open DevTools',
                  icon: Icon(Icons.developer_mode_outlined),
                ),
              ],
            )),
              ValueListenableBuilder(
                  valueListenable: _webviewController,
                  builder: (ctx, ct, _) {
                    return ct
                        ? Expanded(child: _webviewController.webviewWidget)
                        : _webviewController.loadingWidget;
                  })
            ]),
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
