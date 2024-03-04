import 'package:get/get.dart';
import 'package:redefineerp/Utilities/dummyData.dart';
import 'package:redefineerp/themes/constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardController extends GetxController {
  late List<String> filterTime = [
     "Today",
    "Yesterday",
    "This week",
    "7 days ago",
    "All time",
  ];

  RxList day1 = [].obs;
  RxList day2 = [].obs;
  RxList day3 = [].obs;
  RxList day4 = [].obs;
  RxList day5 = [].obs;
  RxList day6 = [].obs;
  RxList day7 = [].obs;

  late String time = "Today";
  late TooltipBehavior tooltipBehavior;
  late List<ChartSampleData> chartData;

  void initTime() {
    time = time = filterTime.first; // initializing the time field
    initChartData();
  }

  void initState() {
    // time = filterTime.first;
    initChartData();
  }

  initChartData() {
    tooltipBehavior =
        TooltipBehavior(enable: true, header: '', canShowMarker: false);

    chartData = <ChartSampleData>[
      ChartSampleData(
          x: '1', y: 10, pointColor: Constant.softColors.blue.color),
      ChartSampleData(
        x: '2',
        y: 8,
        pointColor: Constant.softColors.violet.color,
      ),
      ChartSampleData(
        x: '3',
        y: 16,
        pointColor: Constant.softColors.orange.color,
      ),
      ChartSampleData(
        x: '4',
        y: 24,
        pointColor: Constant.softColors.blue.color,
      ),
      ChartSampleData(
        x: '5',
        y: 32,
        pointColor: Constant.softColors.orange.color,
      ),
      ChartSampleData(
        x: '6',
        y: 30,
        pointColor: Constant.softColors.blue.color,
      ),
      ChartSampleData(
        x: '7',
        y: 25,
        pointColor: Constant.softColors.violet.color,
      ),
    ];
  }

  void changeFilter(String time) {
    this.time = time;
    update();
  }

  @override
  String getTag() {
    return "shopping_login_controller";
  }
}
