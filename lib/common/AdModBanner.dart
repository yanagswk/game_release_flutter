import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdModBanner extends StatefulWidget {
  const AdModBanner({super.key});

  @override
  State<AdModBanner> createState() => _AdModBannerState();
}

class _AdModBannerState extends State<AdModBanner> {

  // バナー広告をインスタンス化
  BannerAd myBanner = BannerAd(
    // adUnitId: getTestAdBannerUnitId(),
    // adUnitId: "ca-app-pub-3940256099942544/2934735716", // テストIOS用
    adUnitId: "ca-app-pub-5120399662467556/3935570145", // 本番IOS用
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener()
  );

  // TODO: DeviceInfoクラスへ移行
  // プラットフォーム（iOS / Android）に合わせてデモ用広告IDを返す
  // String getTestAdBannerUnitId() {
  //   String testBannerUnitId = "";
  //   if (Platform.isAndroid) {
  //     // Android のとき
  //     testBannerUnitId = "ca-app-pub-3940256099942544/6300978111"; // Androidのデモ用バナー広告ID
  //   } else if (Platform.isIOS) {
  //     // iOSのとき
  //     testBannerUnitId = "ca-app-pub-3940256099942544/2934735716"; // iOSのデモ用バナー広告ID
  //   }
  //   return testBannerUnitId;
  // }

  @override
  Widget build(BuildContext context) {

    // バナー広告の読み込み
    myBanner.load();

    return Container(
      color: Colors.white,
      height: 50.0,
      width: double.infinity,
      child: AdWidget(ad: myBanner),
    );
  }
}
