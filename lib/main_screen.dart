import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool pop = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('나만의 웹브라우저'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _controller.loadRequest(Uri.parse(value));
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'https://www.google.com',
                child: Text('구글'),
              ),
              const PopupMenuItem<String>(
                value: 'https://www.naver.com',
                child: Text('네이버'),
              ),
              const PopupMenuItem<String>(
                value: 'https://www.kakao.com',
                child: Text('카카오'),
              ),
            ],
          ),
        ],
      ),
      body: PopScope(
        canPop: pop,
        onPopInvoked: ((didPop) async {
          if (await _controller.canGoBack()) {
            await _controller.goBack();
            return;
          }
          setState(() {
            pop = true;
          });
          await _controller.goBack();
          //_showBackDialog(pop);
        }),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
      ),
    );
  }

  void _showBackDialog(pop) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('페이지 이동'),
          content: const Text(
            '현재 페이지를 나가시겠습니까?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('네'),
              onPressed: () async {
                await _controller.goBack();
                _controller.goBack();
                Navigator.pop(context);
                bool can = await _controller.canGoBack();
                print(can);
                if (!await _controller.canGoBack()) {
                  setState(() {
                    pop = true;
                    print(pop);
                    _controller.goBack();
                  });
                }
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('아니오'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("기타"),
            )
          ],
        );
      },
    );
  }
}
