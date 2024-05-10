import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redefineerp/Screens/Contact/contacts_controller.dart';
import 'package:redefineerp/themes/textFile.dart';
import 'package:redefineerp/themes/themes.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard(
      {Key? key,
      required this.title,
      required this.value,
      required this.onTap,
    })
      : super(key: key);
  final String title;
  
  final String value;
  final VoidCallback onTap;


  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool? isActive;

  @override
  void initState() {
    try {
 
      isActive = true;
    } catch (e) {
      isActive = false;

      print(e);
    }
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put<ContactController>(ContactController());

    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          Icons.account_circle,
          color: Get.theme.kContactIconColor,
          size: 32,
        ),
        title: Row(
          children: [
            FxText.bodyLarge(
              widget.title,
              fontSize: 16,
              fontWeight: 700,
            ),
            Spacer(),
            isActive == true
                ? CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: MediaQuery.of(context).size.height * 0.006,
                  )
                : const SizedBox()
          ],
        ),
        subtitle: FxText.bodySmall(
          widget.value,
          fontSize: 11,
          fontWeight: 700,
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: Get.theme.btnTextCol.withOpacity(0.2)),
        onTap: widget.onTap,
      ),
    );
  }
}
