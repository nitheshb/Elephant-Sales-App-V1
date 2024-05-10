// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as FlutterDateTimePicker;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redefineerp/Screens/Auth/auth_controller.dart';
import 'package:redefineerp/Screens/Auth/login_page.dart';
import 'package:redefineerp/Screens/Contact/contact_list_dialog.dart';
import 'package:redefineerp/Screens/Contact/contact_list_page.dart';
import 'package:redefineerp/Screens/Contact/contacts_controller.dart';
import 'package:redefineerp/Screens/Home/homepage2.dart';

import 'package:redefineerp/Screens/Home/homepage_gradient.dart';
import 'package:redefineerp/Screens/Leads/LeadsDetails.dart';
import 'package:redefineerp/Screens/Notification/notification_pages.dart';
import 'package:redefineerp/Screens/ProductListCategoryPopUp/product_category_list.dart';
import 'package:redefineerp/Screens/ProductListCategoryPopUp/product_category_list_controler.dart';
import 'package:redefineerp/Screens/Products/productList_Controller.dart';
import 'package:redefineerp/Screens/Profile/profile_page.dart';
import 'package:redefineerp/Screens/Report/report_page.dart';
import 'package:redefineerp/Screens/Report/slim_team_stats.dart';
import 'package:redefineerp/Screens/Report/team_stats.dart';
import 'package:redefineerp/Screens/Search/search_controller.dart';
import 'package:redefineerp/Screens/Search/search_task.dart';
import 'package:redefineerp/Screens/Task/create_task.dart';
import 'package:redefineerp/Screens/Task/task_controller.dart';
import 'package:redefineerp/Screens/Widgets/ShimmerCard.dart';
import 'package:redefineerp/Screens/projectDetails/project_units_screen.dart';
import 'package:redefineerp/Utilities/basicdialog.dart';
import 'package:redefineerp/Utilities/bottomsheet.dart';
import 'package:redefineerp/Utilities/custom_sizebox.dart';
import 'package:redefineerp/Utilities/snackbar.dart';
import 'package:redefineerp/Widgets/FxCard.dart';
import 'package:redefineerp/Widgets/checkboxlisttile.dart';
import 'package:redefineerp/Widgets/datewidget.dart';
import 'package:redefineerp/Widgets/headerbg.dart';
import 'package:redefineerp/Widgets/minimsg.dart';
import 'package:redefineerp/Widgets/task_sheet_widget.dart';
import 'package:redefineerp/helpers/firebase_help.dart';
import 'package:redefineerp/helpers/supabae_help.dart';
import 'package:redefineerp/themes/container.dart';
import 'package:redefineerp/themes/customTheme.dart';
import 'package:redefineerp/themes/spacing.dart';
import 'package:redefineerp/themes/textFile.dart';
import 'package:redefineerp/themes/themes.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/streams.dart';
import 'package:call_log/call_log.dart';
import 'package:workmanager/workmanager.dart';

import '../Search/search_controller.dart';

void callbackDispatcher() {
  Workmanager().executeTask((dynamic task, dynamic inputData) async {
    print('Background Services are Working!');
    try {
      final Iterable<CallLogEntry> cLog = await CallLog.get();
      print('Queried call log entries');
      for (CallLogEntry entry in cLog) {
        print('-------------------------------------');
        print('F. NUMBER  : ${entry.formattedNumber}');
        print('C.M. NUMBER: ${entry.cachedMatchedNumber}');
        print('NUMBER     : ${entry.number}');
        print('NAME       : ${entry.name}');
        print('TYPE       : ${entry.callType}');
        print(
            'DATE       : ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!.toInt())}');
        print('DURATION   : ${entry.duration}');
        print('ACCOUNT ID : ${entry.phoneAccountId}');
        print('ACCOUNT ID : ${entry.phoneAccountId}');
        print('SIM NAME   : ${entry.simDisplayName}');
        print('-------------------------------------');
      }
      return true;
    } on PlatformException catch (e, s) {
      print(e);
      print(s);
      return true;
    }
  });
}

class ProductsPage extends StatefulWidget {
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  //  late CustomTheme customTheme;
  //   late ThemeData theme;
  Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];

  final storageReference =
      FirebaseStorage.instance.ref().child('images/image.jpg');

  ImagePicker picker = ImagePicker();
var products = [];
  XFile? image;
  @override
  void initState() {
    super.initState();
    fetchProducts();
    call();
  }
  void fetchProducts() async {
    final response = await DbSupa.instance.streamProductsNew();
    print('my value is x ${response}');
    setState(() {
      products = response;
      // products = response.map((json) => Product.fromJson(json)).toList();
    });
  }

  void updateQuantity(Product product, int newQuantity) async {
    // Update quantity of the product in Supabase
    // final response = await widget.supabase.from('products').update({'quantity': newQuantity}).eq('id', product.id).execute();
    // if (response.error != null) {
    //   // Handle error
    //   print('Error updating quantity: ${response.error}');
    //   return;
    // }
    setState(() {
      product.quantity = newQuantity;
    });
  }
  void call() async {
    // Firestore to fetch recent record
    final controller2 = Get.put<AuthController>(AuthController());

    // FirebaseFirestore.instance
    //         .collection("${controller2.currentUserObj['orgId']}_leads").
    Future<List<Map<String, dynamic>>> getDataFromFirestore() async {
      List<Map<String, dynamic>> dataList = [];

      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection("${controller2.currentUserObj['orgId']}_leads")
                .get();
        print("data in");
        dataList = querySnapshot.docs
            .map((DocumentSnapshot<Map<String, dynamic>> doc) {
          print("data ${doc.data()}");
          return doc.data()!;
        }).toList();
      } catch (e) {
        print("Error getting data: $e");
      }

      return dataList;
    }

    void fetchData() async {
      String collectionName = 'your_collection_name';
      List<Map<String, dynamic>> data = await getDataFromFirestore();

      // Do something with the retrieved data
      print(data);
    }

// to get call log and will prints the calls afte the recent
    var recent = 1710002876688;
    final Iterable<CallLogEntry> result = await CallLog.query();

    setState(() {
      _callLogEntries = result;

      fetchData();
      for (CallLogEntry entry in _callLogEntries) {
        if (entry.timestamp! > recent) {
          print("F.Number: ${entry.formattedNumber}");
          print('-------------------------------------');
          print('F. NUMBER  : ${entry.formattedNumber}');
          print('C.M. NUMBER: ${entry.cachedMatchedNumber}');
          print('NUMBER     : ${entry.number}');
          print('NAME       : ${entry.name}');
          print('TYPE       : ${entry.callType}');
          print('DATE       : ${entry.timestamp}');
          print('DURATION   : ${entry.duration}');
          print('ACCOUNT ID : ${entry.phoneAccountId}');
          print('ACCOUNT ID : ${entry.phoneAccountId}');
          print('SIM NAME   : ${entry.simDisplayName}');
          print('-------------------------------------');
        } else {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Iterable<CallLogEntry> callLogEntries = <CallLogEntry>[];
    // call();
    // for (CallLogEntry entry in callLogEntries) {
    //   print("F.Number: ${entry.formattedNumber}");
    //   print('-------------------------------------');
    //   print('F. NUMBER  : ${entry.formattedNumber}');
    //   print('C.M. NUMBER: ${entry.cachedMatchedNumber}');
    //   print('NUMBER     : ${entry.number}');
    //   print('NAME       : ${entry.name}');
    //   print('TYPE       : ${entry.callType}');
    //   print(
    //       'DATE       : ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!.toInt())}');
    //   print('DURATION   : ${entry.duration}');
    //   print('ACCOUNT ID : ${entry.phoneAccountId}');
    //   print('ACCOUNT ID : ${entry.phoneAccountId}');
    //   print('SIM NAME   : ${entry.simDisplayName}');
    //   print('-------------------------------------');
    // }
    final controller = Get.put<ProductListPageController>(ProductListPageController());
    final productCategoryController = Get.put<ProductCategoryListPageController>(ProductCategoryListPageController());
    final controller2 = Get.put<AuthController>(AuthController());
    final controller1 = Get.put<ContactController>(ContactController());
    // MySearchController searchController =
    // Get.put<MySearchController>(SearchController());
    // TaskController controller1 = Get.put<TaskController>(TaskController());
    debugPrint("home called ${FirebaseAuth.instance.currentUser}");
    debugPrint("home calledc ${controller2.currentUserObj}");
    // Set the system status bar color
// Create two streams for each query
    final stream1 = FirebaseFirestore.instance
        .collection('maahomes_projects')
        // .where("due_date",
        //     isLessThanOrEqualTo: DateTime.now().microsecondsSinceEpoch)
        .where("status", isEqualTo: "ongoing")
        // .where("particpantsIdA", arrayContains: FirebaseAuth.instance.currentUser!.uid)
        // .where("to_uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        // .where("by_uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)

        // .orWhere("by_uid", isEqualTo:  FirebaseAuth.instance.currentUser!.uid)

        .snapshots();

// Combine the two streams using the RxCombineLatestStream from the rxdart package
// final combinedStream = RxCombineLatestStream<QuerySnapshot>([stream1, stream2]);
// final combinedStream = rxdart.CombineLatestStream( [stream1, stream2]);

    return Obx(() => Scaffold(
          backgroundColor: const Color(0xff0D0D0D),  
          appBar: AppBar(
            backgroundColor: const Color(0xff0D0D0D),
            systemOverlayStyle: const SystemUiOverlayStyle(
              // Status bar color
              statusBarColor: Color(0xff0D0D0D),

              // Status bar brightness (optional)
              statusBarIconBrightness:
                  Brightness.light, // For Android (dark icons)
              statusBarBrightness: Brightness.light, // For iOS (dark icons)
            ),
            elevation: 0.0,
            title: controller.expande.value == true
                ? TextField(
                    controller: controller.searchText,
                    onChanged: (v) {
                      if (v == '') {
                        // MySearchController.searchResultsWidget.value =
                        //     MySearchController.searchResults('');
                        controller.search.value = false;
                      } else {
                        controller.search.value = true;
                      }
                      // MySearchController.searchResultsWidget.value =
                      //     MySearchController.searchResults(v);

                      // print(MySearchController.searchResultsWidget.value);
                    },
                    decoration: InputDecoration(
                        prefixIcon: IconButton(
                            onPressed: () {
                              controller.search.value = false;
                              controller.expande.value = false;
                            },
                            icon: Icon(Icons.arrow_back)),
                        hintText: 'Search'),
                  )
                : titleRow(),
            actions: controller.expande.value == true
                ? []
                : [
                    IconButton(
                      icon: Icon(Icons.search,
                          color: Get.theme.btnTextCol.withOpacity(0.3)),
                      onPressed: () {
                        // Get.to(() => const SearchPage());
                        controller.expande.value = true;
                        print(controller.expande.value);
                      },
                    ),
                    IconButton(
                        onPressed: () =>
                            {Get.to(() => const NotificationPage())},
                        icon: const Icon(Icons.notifications),
                        color: Get.theme.btnTextCol.withOpacity(0.3)),
                  ],
          ),
            floatingActionButton: FloatingActionButton.extended(
            onPressed: () => {
              showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(9.0))),
                  backgroundColor: Colors.white,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 14.0,
                          right: 14.0,
                          top: 10.0),
                      child: Form(
                        key: controller.taskKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              validator: controller.validateTaskTitle,
                              controller: controller.productTitle,
                              onChanged: controller.validateTaskTitle,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                   labelText: 'Product name',
                                  hintText: 'Product name...'),
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w500),
                              autofocus: true,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                       controller: controller.productSize,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Size',
                                        hintText: 'Size'),
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w400),
                                    onSubmitted: (value) {
                                      Navigator.pop(context);
                                      var currentDate = DateTime.now();
                                    },
                                    autofocus: true,
                                  ),
                                ),
                                  Expanded(
                                  child: TextField(
                                       controller: controller.costPrice,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Cost Price',
                                        hintText: 'Cost Price'),
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w400),
                                    autofocus: true,
                                  ),
                                ),
                                 Expanded(
                                  child: TextField(
                                       controller: controller.sellPrice,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Sell Price',
                                        hintText: 'Sell Price'),
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w400),
                                    onSubmitted: (value) {
                                      Navigator.pop(context);
                                      var currentDate = DateTime.now();
                          
                                    },
                                    autofocus: true,
                                  ),
                                ),
                              ],
                            ),
                        
                                SizedBox(height: 14,),
                                 Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // assign to

                                  InkWell(
                                    onTap: () => {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: ProductCategoryListPage()))
                                    },
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Get.theme.colorPrimaryDark,
                                              radius: 17,
                                              child: Text(
                                                  '${controller.assignedUserName.value.substring(0, 2)}',
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                        Obx(() => Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, bottom: 4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 16,
                                                    child: Text(
                                                      'Category',
                                                      style: Get.theme.kSubTitle
                                                          .copyWith(
                                                              color: Get.theme
                                                                  .kLightGrayColor),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 22,
                                                    child: Text(
                                                      productCategoryController
                                                          .category
                                                          .value,
                                                      style: Get.theme
                                                          .kPrimaryTxtStyle
                                                          .copyWith(
                                                              color: Get.theme
                                                                  .kBadgeColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),

                                  // Due Date

                                  InkWell(
                                    onTap: () => {
                    
                                    },
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          child: Material(
                                              type: MaterialType.transparency,
                                              child: DottedBorder(
                                                borderType: BorderType.Circle,
                                                color:
                                                    Get.theme.kLightGrayColor,
                                                radius:
                                                    const Radius.circular(27.0),
                                                dashPattern: [3, 3],
                                                strokeWidth: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons
                                                        .calendar_month_outlined,
                                                    size: 18,
                                                    color: Get
                                                        .theme.kLightGrayColor,
                                                  ),
                                                ),
                                              )
                                       
                                              ),
                                        ),
                                        Obx(() => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0, bottom: 4),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 16,
                                                        child: Text(
                                                          'Sub Category',
                                                          style: Get
                                                              .theme.kSubTitle
                                                              .copyWith(
                                                                  color: Get
                                                                      .theme
                                                                      .kLightGrayColor),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 22,
                                                        child: Text(
                                                            controller
                                                                .selectedDateTime
                                                                .value,
                                                            style: Get.theme
                                                                .kNormalStyle
                                                                .copyWith(
                                                                    color: Get
                                                                        .theme
                                                                        .kBadgeColor)),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                       
                                            ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                           
                           
                           SizedBox(height: 14,),
                        
                            const SizedBox(
                              height: 8,
                            ),

                          
                            SizedBox(
                              // height: 20,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Process',
                                    style: Get.theme.kSubTitle.copyWith(
                                        color: const Color(0xff707070),
                                        fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    child: Row(
                                      children: [
                                        // Generator.buildOverlaysProfile(
                                        //     images: [
                                        //       'assets/images/icon.jpg',
                                        //       'assets/images/icon.jpg',
                                        //     ],
                                        //     enabledOverlayBorder: true,
                                        //     overlayBorderColor: Color(0xfff0f0f0),
                                        //     overlayBorderThickness: 1.7,
                                        //     leftFraction: 0.72,
                                        //     size: 26),
                            
                                        InkWell(
                                            onTap: () => {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                              context) =>
                                                          const ContactListDialogPage())
                                                },
                                            child: DottedBorder(
                                              borderType: BorderType.Circle,
                                              color:
                                                  Get.theme.kLightGrayColor,
                                              radius:
                                                  const Radius.circular(27.0),
                                              dashPattern: [3, 3],
                                              strokeWidth: 1,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 15,
                                                  color: Get
                                                      .theme.kLightGrayColor,
                                                ),
                                              ),
                                            )),
                            
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Obx(
                                          () => SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.720,
                                            child: ListView.builder(
                                              itemCount: controller
                                                  .ComponentsANew
                                                  .value
                                                  .length,
                                              scrollDirection:
                                                  Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 3.0),
                                                  child: SizedBox(
                                                    child: Material(
                                                      type: MaterialType
                                                          .transparency,
                                                      child: CircleAvatar(
                                                        backgroundColor: Get
                                                            .theme
                                                            .colorPrimaryDark,
                                                        radius: 14,
                                                        child: Text(
                                                            '${controller.ComponentsANew[index]['name'].substring(0, 2)}',
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    10)),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Visibility(
                                        visible: (controller
                                                .assignedUserName.value ==
                                            "Assign someone"),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () => {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child:
                                                                ContactListPage()))
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    color: Get
                                                        .theme.kLightGrayColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20.0,
                                            ),
                                            InkWell(
                                              onTap: () => {
                                              
                                              },
                                              child: Icon(
                                                Icons.calendar_month_outlined,
                                                color:
                                                    Get.theme.kLightGrayColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                     InkWell(
                                        onTap: () => {
                              
                                        },
                                        child: Icon(
                                          Icons.flag_outlined,
                                          color: Get.theme.kLightGrayColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20.0,
                                      ),
                                      Visibility(
                                        visible: (!controller1
                                            .participants.value.isNotEmpty),
                                        child: InkWell(
                                          onTap: () => {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    const ContactListDialogPage())
                                          },
                                          child: Icon(
                                            Icons.people_alt_outlined,
                                            color: Get.theme.kLightGrayColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                    onTap: () => {
                                          controller.validationSuccess.value =
                                              false,
                                          // print(
                                          //     controller.validationSuccess.value),
                                          controller.checkTaskValidation()
                                        },

                                    // {controller.createNewTask()},
                                    child: Obx(
                                      () => CircleAvatar(
                                        radius:
                                            MediaQuery.of(context).size.height *
                                                0.030,
                                        backgroundColor: controller
                                                    .validationSuccess.value ==
                                                true
                                            ? Get.theme.primaryContainer
                                            : Colors.grey,
                                        child: Icon(
                                          Icons.send,
                                          color: controller.validationSuccess
                                                      .value ==
                                                  true
                                              ? Colors.blue
                                              : const Color.fromARGB(
                                                  255, 62, 62, 62),
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      )))
            },

            backgroundColor: Color(0xffBDA1EF),
            label: Text('Add Product'),
            icon: const Icon(
              Icons.add,
              // color: Color(0xff33264b),
            ),
            // child: Row(
            //   children: [
            //     Text('Aedd Task'),
            //     const Icon(
            //       Icons.add,
            //       color: Color(0xff33264b),
            //     ),
            //   ],
            // ),
          ),
      
          body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: Color(0xff0D0D0D),
                    snap: false,
                    pinned: true,
                    floating: true,
                    flexibleSpace: Obx(() => FlexibleSpaceBar(
                            background: SlimTeamStats(
                            controller.flipMode,
                            controller.businessMode.value,
                            controller.numOfTodayTasks,
                            controller.myBusinessTotal))),
                    expandedHeight: 170,
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(48.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Obx(
                          () => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                               
                              if (!controller.businessMode.value) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6.0, right: 4.0),
                                  child: ActionChip(
                                      elevation: 0,
                                      padding:
                                          const EdgeInsets.fromLTRB(6, 1, 6, 1),
                                      backgroundColor: 0 == 0
                                          ? Get.theme.primaryContainer
                                          : Colors.transparent,
                                      label: FxText.bodySmall(
                                        "New",
                                        fontSize: 11,
                                        fontWeight: 700,
                                        color: 0 == 0
                                            ? Get.theme.onPrimaryContainer
                                            : Get
                                                .theme.colorScheme.onBackground,
                                      ),
                                      onPressed: () => {print('hello')}),
                                ),
                                Visibility(
                                  visible: false,
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, right: 4.0),
                                    child: ActionChip(
                                        elevation: 0,
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 1, 6, 1),
                                        backgroundColor: 0 == 0
                                            ? Get.theme.primaryContainer
                                            : Colors.transparent,
                                        label: FxText.bodySmall(
                                          "My Tasks adfafafaf adffafafafdas adfafafaf adfadfafafafaff",
                                          fontSize: 11,
                                          fontWeight: 700,
                                          color: 0 == 0
                                              ? Get.theme.onPrimaryContainer
                                              : Get.theme.colorScheme
                                                  .onBackground,
                                        ),
                                        onPressed: () => {print('hello')}),
                                  ),
                                ),
                              ] else ...[
                                
StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
      .collection("${controller2.currentUserObj['orgId']}_customers")
      .where("Status", whereIn: [
        'new',
        'followup',
        'visitfixed',
        'visitdone',
        'negotiation'
        'inprogress'

      ])
      .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // return CircularProgressIndicator(); // Loading indicator while fetching data
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      final data = snapshot.data?.docs ?? [];
      return Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var item in [
              {'label': 'All', 'value': 'new'},
              {'label': 'Pillars', 'value': 'pillar'},
              {'label': 'Beams', 'value': 'beam'},
              {'label': 'Corner Boxes', 'value': 'cornerbox'},
              {'label': 'Chain Blocks', 'value': 'chainblock'},
              {'label': 'Chain Pulleys', 'value': 'chainpulley'},
              {'label': 'Hinges', 'value': 'hinges'},       
              {'label': 'Hammers', 'value': 'hammers'},
              {'label': 'Lighting Clamps', 'value': 'clamps'},

              {'label': 'Ms Bases', 'value': 'bases'},
              {'label': 'Ms Half Bullets', 'value': 'mshalfbullets'},
              {'label': 'R-pins', 'value': 'rpins'},

              {'label': 'Support Rods', 'value': 'supportrod'},
           
              {'label': 'Tapper Pins & Connectors', 'value': 'tapperpinsconnectors'},
                 
            
             
            ])
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                child: InkWell(
                  onTap: () =>                       controller.setTaskTypeFun(item['value']),

                  child: Container(
                           
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    color:
                        controller.myLeadStatusCategory.value == item['value']
                            ? Color(0xff58423B)
                            : Color(0xff1C1C1E),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                           FxText.bodySmall(
                          '${_getStatusCount(data, item['value']!)}',
                          fontSize: 11,
                          fontWeight: 700,
                          color: controller.myLeadStatusCategory.value == item['value']
                              ? Get.theme.onPrimary
                              : Colors.white,
                        ),
                        FxText.bodySmall(
                          '${item['label']}',
                          fontSize: 11,
                          fontWeight: 700,
                          letterSpacing: 1.5,
                          color: controller.myLeadStatusCategory.value == item['value']
                              ? Get.theme.onPrimary
                              : Get.theme.onBackground,
                        ),
                      ],
                    ),
                   
                  ),
                ),
              ),
          ],
        ),
      );
    },
  ),


                                Obx(
                                  () => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, right: 4.0),
                                    child: ActionChip(
                                        elevation: 0,
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 1, 6, 1),
                                        backgroundColor:
                                            controller.myLeadStatusCategory ==
                                                    'projects'
                                                ? Get.theme.primaryContainer
                                                : Colors.transparent,
                                        label: FxText.bodySmall(
                                          "Projects",
                                          fontSize: 11,
                                          fontWeight: 700,
                                          color:
                                              controller.myLeadStatusCategory ==
                                                      'projects'
                                                  ? Get.theme.onPrimaryContainer
                                                  : Get.theme.onBackground,
                                        ),
                                        onPressed: () => {
                                              print('hello'),
                                              controller
                                                  .setTaskTypeFun('projects'),
                                              print(controller
                                                  .showingLists.length)
                                            }),
                                  ),
                                ),
                                Obx(
                                  () => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, right: 4.0),
                                    child: ActionChip(
                                        elevation: 0,
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 1, 6, 1),
                                        backgroundColor:
                                            controller.myLeadStatusCategory ==
                                                    'participants'
                                                ? Get.theme.primaryContainer
                                                : Colors.transparent,
                                        label: FxText.bodySmall(
                                          "Participants ",
                                          fontSize: 11,
                                          fontWeight: 700,
                                          color:
                                              controller.myLeadStatusCategory ==
                                                      'participants'
                                                  ? Get.theme.onPrimaryContainer
                                                  : Get.theme.onBackground,
                                        ),
                                        onPressed: () => {
                                              controller.setTaskTypeFun(
                                                  'participants'),
                                              print(
                                                  'hello ${controller.myLeadStatusCategory == 'participants'}'),
                                            }),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              // body: controller.streamToday()
              body: Center(child: () {

                if(controller.myLeadStatusCategory.value == 'all'){
     
                    return _LeadsTasksList(context, controller2);
                }else if(['all','pillar','beam','cornerbox','chainblock', 'chainpulley','hinges', 'hammers','clamps','bases','mshalfbullets', 'rpins', 'supportrod', 'tapperpinsconnectors'].contains(controller.myLeadStatusCategory.value)){
                               return _LeadsListNew(context, controller, controller2);
                    return _LeadsList(context, controller, controller2);
                }
                switch (controller.myLeadStatusCategory.value) {
                  case 'projects':
                    return _projectsBody(context, controller2);
                  default:
                    return Text('Invalid selection');
                }
              }()),

              // body: TabBarView(
              //   children: [
              //       controller.streamToday(),
              //       controller.streamUpdates(),
              //       controller.streamCreated(),
              //     ],
              // ),

              // backgroundColor: const Color(0xffBDA1EF),
              // child: const Icon(
              //   Icons.add,
              //   color: Color(0xff33264b),
              // ),
            ),
            // floatingActionButtonLocation:
            //     FloatingActionButtonLocation.,

            //   body: DefaultTabController(
            //     length: 3,
            //     child: NestedScrollView(
            //         headerSliverBuilder:
            //             (BuildContext context, bool innerBoxIsScrolled) {
            //           return <Widget>[
            //             Obx(
            //               () => SliverAppBar(
            //                 backgroundColor: const Color(0xffffffff),
            //                 snap: false,
            //                 pinned: true,
            //                 floating: true,
            //                 flexibleSpace: FlexibleSpaceBar(
            //                     background: controller.expande.value == true
            //                         ? controller.search.value == true
            //                             ? SizedBox()
            //                             : Wrap(
            //                                 children: [
            //                                   _filterChip(0,
            //                                       title: 'All',
            //                                       controller: MySearchController,
            //                                       onTap: () => {
            //                                             MySearchController
            //                                                 .selectedIndex.value = 0,
            //                                           }),
            //                                   _filterChip(1,
            //                                       title: 'Done',
            //                                       controller: MySearchController,
            //                                       onTap: () => {
            //                                             MySearchController
            //                                                 .selectedIndex.value = 1,
            //                                           }),
            //                                   _filterChip(2,
            //                                       title: 'Pending',
            //                                       controller: MySearchController,
            //                                       onTap: () => {
            //                                             MySearchController
            //                                                 .selectedIndex.value = 2,
            //                                           }),
            //                                   _filterChip(3,
            //                                       title: 'Created',
            //                                       controller: MySearchController,
            //                                       onTap: () => {
            //                                             MySearchController
            //                                                 .selectedIndex.value = 3,
            //                                           }),
            //                                   _filterChip(4,
            //                                       title: 'Today',
            //                                       controller: MySearchController,
            //                                       onTap: () => {
            //                                             MySearchController
            //                                                 .selectedIndex.value = 4,
            //                                           }),
            //                                 ],
            //                               )
            //                         : SlimTeamStats(() => {})),
            //                 expandedHeight: controller.search.value == true
            //                     ? 10
            //                     : controller.expande.value == true
            //                         ? 69
            //                         : 190,
            //                 bottom: PreferredSize(
            //                   preferredSize: const Size.fromHeight(48.0),
            //                   child: controller.expande.value == true
            //                       ? SizedBox()
            //                       : SingleChildScrollView(
            //                           physics: const BouncingScrollPhysics(),
            //                           scrollDirection: Axis.horizontal,
            //                           child: Row(
            //                             crossAxisAlignment: CrossAxisAlignment.start,
            //                             mainAxisAlignment: MainAxisAlignment.start,
            //                             children: [
            //                               Padding(
            //                                 padding: const EdgeInsets.only(
            //                                     left: 2.0, right: 4.0),
            //                                 child: ActionChip(
            //                                     elevation: 0,
            //                                     padding: const EdgeInsets.fromLTRB(
            //                                         6, 1, 6, 1),
            //                                     backgroundColor: 0 == 0
            //                                         ? Get.theme.primaryContainer
            //                                         : Colors.transparent,
            //                                     label: FxText.bodySmall(
            //                                       "All Tasks",
            //                                       fontSize: 11,
            //                                       fontWeight: 700,
            //                                       color: 0 == 0
            //                                           ? Get.theme.onPrimaryContainer
            //                                           : Get.theme.colorScheme
            //                                               .onBackground,
            //                                     ),
            //                                     onPressed: () => {print('hello')}),
            //                               ),
            //                               Padding(
            //                                 padding: const EdgeInsets.only(
            //                                     left: 2.0, right: 4.0),
            //                                 child: ActionChip(
            //                                     elevation: 0,
            //                                     padding: const EdgeInsets.fromLTRB(
            //                                         6, 1, 6, 1),
            //                                     backgroundColor: 1 == 0
            //                                         ? Get.theme.primaryContainer
            //                                         : Colors.transparent,
            //                                     label: FxText.bodySmall(
            //                                       "Personal",
            //                                       fontSize: 11,
            //                                       fontWeight: 700,
            //                                       color: 1 == 0
            //                                           ? Get.theme.onPrimaryContainer
            //                                           : Get.theme.onBackground,
            //                                     ),
            //                                     onPressed: () => {print('hello')}),
            //                               ),
            //                               Padding(
            //                                 padding: const EdgeInsets.only(
            //                                     left: 2.0, right: 4.0),
            //                                 child: ActionChip(
            //                                     elevation: 0,
            //                                     padding: const EdgeInsets.fromLTRB(
            //                                         6, 1, 6, 1),
            //                                     backgroundColor: 1 == 0
            //                                         ? Get.theme.primaryContainer
            //                                         : Colors.transparent,
            //                                     label: FxText.bodySmall(
            //                                       "Business",
            //                                       fontSize: 11,
            //                                       fontWeight: 700,
            //                                       color: 1 == 0
            //                                           ? Get.theme.onPrimaryContainer
            //                                           : Get.theme.onBackground,
            //                                     ),
            //                                     onPressed: () => {print('hello')}),
            //                               ),
            //                               Padding(
            //                                 padding: const EdgeInsets.only(
            //                                     left: 2.0, right: 4.0),
            //                                 child: ActionChip(
            //                                     elevation: 0,
            //                                     padding: const EdgeInsets.fromLTRB(
            //                                         6, 1, 6, 1),
            //                                     backgroundColor: 1 == 0
            //                                         ? Get.theme.primaryContainer
            //                                         : Colors.transparent,
            //                                     label: FxText.bodySmall(
            //                                       "Participants",
            //                                       fontSize: 11,
            //                                       fontWeight: 700,
            //                                       color: 1 == 0
            //                                           ? Get.theme.onPrimaryContainer
            //                                           : Get.theme.onBackground,
            //                                     ),
            //                                     onPressed: () => {print('hello')}),
            //                               ),
            //                             ],
            //                           ),
            //                         ),
            //                 ),
            //               ),
            //             )
            //           ];
            //         },
            //         body: controller.expande.value == true
            //             ? SizedBox(
            //                 height: MediaQuery.of(context).size.height * 0.89,
            //                 child:
            //                     Obx(() => MySearchController.searchResultsWidget.value),
            //               )
            //             : controller.streamToday()
            //         // body: TabBarView(
            //         //   children: [
            //         //       controller.streamToday(),
            //         //       controller.streamUpdates(),
            //         //       controller.streamCreated(),
            //         //     ],
            //         // ),
            //         ),
            //   ),
          ),
        ));
  }

  Widget _projectsBody(context, controller2) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("${controller2.currentUserObj['orgId']}_projects")
            // .where("status", isEqualTo: "ongoing")
            .snapshots(),
        // stream: DbQuery.instanace.getStreamCombineTasks(),
        builder: (context, snapshot) {
          //     if (!snapshot.hasData) {
          //   return CircularProgressIndicator();
          // }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong! 😣..."),
            );
          } else if (snapshot.hasData) {
            // lets seperate between business vs personal

            var TotalTasks = snapshot.data!.docs.toList();

            print('pub dev is ${TotalTasks}');
            print('pub dev isx ${controller2.currentUserObj['orgId']}');

            // particpantsIdA

            // return Text('Full Data');
            return Column(
              children: [
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, i) {
                            var projData = snapshot.data?.docs[i];
                            var unitCounts;
                            try {
                              unitCounts = projData?['totalUnitCount'] ?? 0;
                            } catch (e) {
                              unitCounts = 'NA';
                            }

                            return _buildSingleHouse(context, projData);
                          }),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Text('No Data');
          }
        });
  }

  Widget _buildSingleHouse(context, projData) {
    String totalUnitCount =
        projData?.data()?.containsKey('totalUnitCount') == true
            ? projData['totalUnitCount'].toString()
            : '0';
    String soldUnitCount =
        projData?.data()?.containsKey('soldUnitCount') == true
            ? projData!['soldUnitCount'].toString()
            : '0';
    return FxCard(
      onTap: () {
        Get.to(() => ProjectUnitScreen(projectDetails: projData));
      },
      margin: FxSpacing.nTop(24),
      paddingAll: 0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderRadiusAll: 16,
      child: Column(
        children: [
          // Image(
          //   image: AssetImage("assets/images/room.png"),
          //   fit: BoxFit.fitWidth,
          // ),
          FxContainer(
            paddingAll: 16,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FxText.bodyMedium(
                      projData?['projectName'],
                      fontWeight: 700,
                    ),
                    FxText.bodyMedium(
                      projData!['projectType']?['name'],
                      fontWeight: 600,
                      color: appGreenTheme.secondary,
                    ),
                  ],
                ),
                FxSpacing.height(4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.withAlpha(180),
                    ),
                    FxSpacing.width(4),
                    FxText.bodySmall(
                      projData!['location'],
                      xMuted: true,
                    ),
                  ],
                ),
                FxSpacing.height(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.king_bed,
                            size: 16,
                            color: Colors.grey.withAlpha(180),
                          ),
                          FxSpacing.width(4),
                          FxText.bodySmall(
                            totalUnitCount,
                            xMuted: true,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bathtub,
                            size: 16,
                            color: Colors.grey.withAlpha(180),
                          ),
                          FxSpacing.width(4),
                          FxText.bodySmall(
                            '${projData!['area']}',
                            xMuted: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FxSpacing.height(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.square_foot,
                            size: 16,
                            color: Colors.grey.withAlpha(180),
                          ),
                          FxSpacing.width(4),
                          FxText.bodySmall(
                            soldUnitCount,
                            xMuted: true,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.aspect_ratio,
                            size: 16,
                            color: Colors.grey.withAlpha(180),
                          ),
                          FxSpacing.width(4),
                          FxText.bodySmall(
                            '${projData!['area']}',
                            xMuted: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 Widget _LeadsListNew(context,controller, controller2) {
     return   Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 22),
                Row(
                  children: [
                    SizedBox(width: 5,),
                    Text('you have ${controller.myLeadStatusCategory.value} ',style: appLightTheme.bodyHigh,),
                    Text('${products.length} due events',style: appLightTheme.bodyHigh.copyWith(color: Color(0xffE7A166)),),
                  ],
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (context, i) {
                            var projData = products[i];
                            return _buildLeadsCard(context,controller,  projData);
                          }),
                    ),
                  ),
                ),
              ],
            );
  return  ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
       
          
          return ListTile(
            title: Text(product.product_name),
            subtitle: Text('Price: \$${product.size}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Quantity: ${product.quantity}'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    updateQuantity(product, product.quantity + 1);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    // if (product.size > 0) {
                    //   // updateQuantity(product, product.quantity - 1);
                    // }
                  },
                ),
              ],
            ),
          );
        },
      );
 }
  Widget _LeadsList(context,controller, controller2) {
    return StreamBuilder<List<Map<String, dynamic>>?>(
        stream: DbSupa.instance.streamProducts().asStream(),

    
        // stream: DbQuery.instanace.getStreamCombineTasks(),
        builder: (context, snapshot) {
          //     if (!snapshot.hasData) {
          //   return CircularProgressIndicator();
          // }
       if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No lead activity logs found.');
        } else {
        List<Map<String, dynamic>> fullData = snapshot.data!;
         var productData = fullData.where((data)=> data['cat'] == controller.myLeadStatusCategory.value).toList();
             print('value is ==> ${productData}');
productData = productData.map((data) {
  data['quantity'] = 0;
  return data;
}).toList();
       
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 22),
                Row(
                  children: [
                    SizedBox(width: 5,),
                    Text('you have ${controller.myLeadStatusCategory.value} ',style: appLightTheme.bodyHigh,),
                    Text('${productData.length} due events',style: appLightTheme.bodyHigh.copyWith(color: Color(0xffE7A166)),),
                  ],
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: productData.length,
                          itemBuilder: (context, i) {
                            var projData = productData[i];
                            return _buildLeadsCard(context,controller,  projData);
                          }),
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  Widget _buildLeadsCard(context, controller, product) {
    print('data is ${product.product_name} ${product}');

    // String lead_Remarks = _list?.containsKey('Remarks') == true
    //     ? _list!['Remarks']
    //     : 'NA';

    //      var sell = _list?.containsKey('sell') == true
    //     ? _list!['sell']
    //     : 0; 
    //     var cost = _list?.containsKey('cost') == true
    //     ? _list!['cost']
    //     : 0;

    // String lead_Name =
    //     _list?.containsKey('product_name') == true ? _list.product_name: 'NA';

    // String size =
    //     _list?.containsKey('size') == true ? _list!['size'] : 'NA';
    // String lead_Mobile =
    //     _list?.containsKey('Mobile') == true ? _list!['Mobile'] : 'NA';



    return Container(
      margin: FxSpacing.only(left:8, right: 8, bottom: 0, top: 8),
      color: Color(0xff1E1E1E),
      child: Padding(
        padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
        child: InkWell(
          onTap: () async {
            //_showBottomSheet(context);
            final Iterable<CallLogEntry> result = await CallLog.query();
            setState(() {
              _callLogEntries = result;
            });
            Get.to(() => LeadsDetailsScreen(
                  leadDetails: product,
                  callLogEntries: _callLogEntries,
                ));
          },
          child: Row(
            children: <Widget>[
              // ClipRRect(
              //   borderRadius: BorderRadius.all(Radius.circular(24)),
              //   child: Image(
              //     image: AssetImage('./assets/images/profile/avatar_2.jpg'),
              //     height: 48,
              //     width: 48,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              Expanded(
                child: Container(
                  margin: FxSpacing.left(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${product.product_name}(${product.size})'!, style:appLightTheme.bodyMedium.copyWith(fontSize: 14,  letterSpacing: 1.25,)),
                    
                      
                      Row(
                        children: [
                        FxText.bodySmall(
                          color: Color(0xffD2D2D2),
                                  
                          '${product.cost}',
                            fontSize: 12,
                            muted: true,
                            letterSpacing: 1.25,
                            fontWeight: 500,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  // _callNumber(lead_Mobile);
                  print('res iss ');
        
                  // setState(() {
                  //   // _list[index] = !_list[index];
                  // });
                },
                child: Container(
                         margin: FxSpacing.right(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                        Text('₹ ${product.sell}', style:appLightTheme.kTitleStyle.copyWith(fontSize: 16)),
                         Row(
                        children: [
                            InkWell(
                    onTap: () {
               if (product.quantity > 0) {
                      updateQuantity(product, product.quantity - 1);
                    }
                    },
                    child: FxContainer.rounded(
                      color: Color(0xff58423B),
                      paddingAll: 8,
                      child: Icon(
                        Icons.remove,
                        color: Get.theme.onPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                        Text('${product.quantity}', style:appLightTheme.kTitleStyle.copyWith(fontSize: 16)),

                     InkWell(
                    onTap: () {
                  // setState(() {
                  //     _list['quantity'] = 10;
                  //   });
                    //  controller.increment(_list);
                     updateQuantity(product, product.quantity + 1);
                    },
                    child: FxContainer.rounded(
                      color: Color(0xff58423B),
                      paddingAll: 8,
                      child: Icon(
                        Icons.add,
                        color: Get.theme.onPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                        ],
                      ),
                   
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _callNumber(lead_Mobile) async {
    print('res issx ');
    var number = '91$lead_Mobile'; //set the number here
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
    print('res is ${res}');
  }

  Widget _LeadsTasksList(context, controller2) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("${controller2.currentUserObj['orgId']}_leads_sch")
            // .where("assignedTo", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("staA",
                arrayContainsAny: ['pending', 'overdue']).snapshots(),
        // stream: DbQuery.instanace.getStreamCombineTasks(),
        builder: (context, snapshot) {
          //     if (!snapshot.hasData) {
          //   return CircularProgressIndicator();
          // }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong! 😣..."),
            );
          } else if (snapshot.hasData) {
            //     List<dynamic> processedDocs = [];
            // for (var docSnapshot in snapshot.data!.docs) {
            //   var docData = docSnapshot.data() as Map<String, dynamic>;
            //   var staDA = docData['staDA'];
            //   if (staDA != null && staDA.isNotEmpty) {
            //     docData['uid'] = docSnapshot.id;
            //     // Assuming getLeadbyId1 returns a Future:
            //     var leadUser =  DbQuery.instanace.getLeadbyId1(controller2.currentUserObj['orgId'], docData['uid']);
            //     docData['leadUser'] = await leadUser;
            //     processedDocs.add(docData);
            //   }
            // }

            return Column(
              children: [
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var docSnapshot = snapshot.data!.docs[index];
                            var docData =
                                docSnapshot.data() as Map<String, dynamic>;
                            // var projData = processedDocs[i];
                            // Return a FutureBuilder for each item
                            return FutureBuilder(
                              future: DbQuery.instanace.getLeadbyId1(
                                  controller2.currentUserObj['orgId'],
                                  docData['uid']),
                              builder: (context, asyncSnapshot) {
                                if (asyncSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SkeletonCard(); // Or a placeholder widget
                                }

                                if (asyncSnapshot.hasError) {
                                  return const Text(
                                      "Failed to load additional data");
                                }

                                // Assuming asyncSnapshot.data contains the lead user data
                                docData['leadUser'] = asyncSnapshot.data;
                                // Now, you can use docData including the fetched leadUser data to build your widget
                                return _buildLeadTasksCard(context, docData);
                              },
                            );

//return _buildLeadTasksCard(context, projData);
                          }),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Text('No Data');
          }
        });
  }

  Widget _buildLeadTasksCard(context, _list) {
    //   String lead_Remarks = _list?.data()?.containsKey('Remarks') == true
    // ? _list!['Remarks']
    // : 'NA';
    String lead_Remarks = '';
    print('task data is ${_list}');
// return Text('${_list[_list['staDA'][0]]}');
    return Container(
      margin: FxSpacing.top(16),
      child: InkWell(
        onTap: () {
          //_showBottomSheet(context);

          Get.to(() => LeadsDetailsScreen(
                leadDetails: _list,
                callLogEntries: _callLogEntries,
              ));
        },
        child: Row(
          children: <Widget>[
            // ClipRRect(
            //   borderRadius: BorderRadius.all(Radius.circular(24)),
            //   child: Image(
            //     image: AssetImage('./assets/images/profile/avatar_2.jpg'),
            //     height: 48,
            //     width: 48,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            Expanded(
              child: Container(
                margin: FxSpacing.left(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FxText.bodyMedium("${_list['leadUser'][0]['Name']}",
                        letterSpacing: 0, fontWeight: 600),
                    FxText.bodySmall(
                      _list['leadUser'][0]['Name'],
                      letterSpacing: 0,
                      xMuted: true,
                      fontWeight: 600,
                      fontSize: 12,
                    ),
                    FxText.bodySmall(
                      _list['leadUser'][0]['Status'],
                      fontSize: 12,
                      muted: true,
                      letterSpacing: 0,
                      fontWeight: 500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  // _list[index] = !_list[index];
                });
              },
              child: FxContainer(
                margin: FxSpacing.right(16),
                padding: FxSpacing.fromLTRB(16, 8, 16, 8),
                bordered: false,
                borderRadiusAll: 4,
                border: Border.all(color: Colors.grey, width: 1),
                color: false ? Colors.transparent : appLightTheme.primaryColor,
                child: FxText.bodySmall("Call",
                    color: false
                        ? appLightTheme.colorScheme.onBackground
                        : appLightTheme.colorScheme.onPrimary,
                    fontWeight: 600,
                    letterSpacing: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(int index,
      {required String title,
      required MySearchController controller,
      required VoidCallback onTap}) {
    return Padding(
      padding: index == 0
          ? const EdgeInsets.only(left: 20, right: 5, top: 8, bottom: 8)
          : const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Obx(
        () => ActionChip(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            shape: index != controller.selectedIndex.value
                ? const StadiumBorder(side: BorderSide(color: Colors.black26))
                : null,
            backgroundColor: index == controller.selectedIndex.value
                ? Get.theme.colorPrimaryDark
                : Colors.white,
            label: Text(
              title,
              style: Get.theme.kSubTitle.copyWith(
                color: controller.selectedIndex.value == index
                    ? Colors.white
                    : Get.theme.kBadgeColor,
              ),
            ),
            onPressed: onTap),
      ),
    );
  }

  Widget titleRow() {
    return Row(
      children: [
        // FxContainer(
        //   width: 10,
        //   height: 24,
        //   color: Get.theme.primaryContainer,
        //   borderRadiusAll: 2,
        // ),
        // FxSpacing.width(8),
 
         Text(
                                "Products List",
                            
                                 style: TextStyle(
                            fontFamily: 'SpaceGrotesk', // Use the font family you declared
                               fontSize: 20, // Set font size to 24
                                  fontWeight: FontWeight.w700, // Set font weight to 700 (bold)
                                  color: Color(0xffCFD0D0),
                                  letterSpacing: 0.8,
                          ),
                                
                              ),
      ],
    );
  }

  Widget _bottomSheet(ScrollController controller) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      controller: controller,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            headerBg(
                title: 'Gif Design for page loading',
                createdOn: 'Created: 12 August | 11:00 PM',
                taskPriority: 1,
                taskPriorityNum: 2),
            miniMessage('Marked as done, pending for review'),
            DateWidget('Due Tommorow'),
          ],
        ),
      ),
    );
  }
  int _getStatusCount( data, String status) {
  return data.where((lead) => lead['Status'] == status).length;
}
}

class Product {
  final String productId;
  final String product_name;
  final String size;
  // final double sell;
  int cost;
  int sell;
  int quantity;

  // ignore: non_constant_identifier_names
  Product({required this.productId, required this.product_name, required this.size, required this.cost,required this.sell,  required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      product_name: json['product_name'],
      size: json['size'],
      cost: json['cost'],
      sell: json['sell'],
      quantity: 0
    );
  }
}
