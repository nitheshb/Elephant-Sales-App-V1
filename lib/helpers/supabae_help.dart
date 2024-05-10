import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:redefineerp/Screens/Products/productsList.dart';
import 'package:supabase/supabase.dart';

// class DbSupa {
//   static DbSupa get instanace => DbSupa();

//   late final SupabaseClient _supabaseClient;

//   void initialize(SupabaseClient supabaseClient) {
//     _supabaseClient = supabaseClient;
//   }

class DbSupa {
  static DbSupa get instance => DbSupa._();

  late final SupabaseClient _supabaseClient;
  var supabaseClient = GetIt.instance<SupabaseClient>();

  DbSupa._();

  void initialize(SupabaseClient supabaseClient) {
    _supabaseClient = supabaseClient;
  }

  void createTask(obj) async {
    print('received obj is ${obj}');
    final client = GetIt.instance<SupabaseClient>();
    final response = await client.from('maahomes_TM_Tasks').insert({
      'created_on': obj["created_on"],
      'title': obj["task_title"],
      'by_email': obj["by_email"],
      'by_name': obj["by_name"],
      'by_uid': obj["by_uid"],
      'dept': obj["dept"],
      'due_date': obj["due_date"],
      'priority': obj["priority"],
      'status': obj["status"],
      'desc': obj["desc"],
      'to_email': obj["to_email"],
      'to_name': obj["to_name"],
      'to_uid': obj["to_uid"],
      'participantsA': obj["participantsA"]
    });

    if (response.error != null) {
      print(response);
    } else {
      print('Task inserted successfully');
    }
  }

  void saveNotification(userId, content, taskId) async {
    final response = await supabaseClient.from('taskman_notifications').insert({
      'user_id': userId,
      'content': content,
      'task_id': taskId,
    });

    print(response);

    // if (response.error != null) {
    //   print(response);
    // } else {
    //   print('Notification saved  successfully');
    // }
  }  
  
  void addVendors(userId, content, taskId) async {
    final response = await supabaseClient.from('elephant_vendors').insert({
      'name': userId,
      'phNumber': content,
      'location': taskId,
    }); 
  } 
    
   addProducts(x) async {
    // final response = await supabaseClient.from('elephant_products').insert({
    //   'product_name': userId,
    //   'size': content,
    //   'sell': taskId,
    //   'cost': taskId, 
    //   'imageUrl': taskId, 
    //   'vendors': [taskId],
    //   'type': taskId
    // });
    
      final response = await supabaseClient.from('elephant_products').insert(x);

    print(response);

    // if (response.error != null) {
    //   print(response);
    // } else {
    //   print('Notification saved  successfully');
    // }
  }

  

 streamProducts() async {
   final client = GetIt.instance<SupabaseClient>();
    final response = await client
      .from('${'elephant'}_products')
      // .stream(primaryKey: ['productId'])
      .select('*')
      .execute();
  print('Task inserted successfully ${response}');
    // return response;
 List<Map<String, dynamic>>? leadLogs = (response.data as List).cast<Map<String, dynamic>>();
    return leadLogs;

}

streamProductsNew() async {
   final client = GetIt.instance<SupabaseClient>();
    final response = await client
      .from('${'elephant'}_products')
      // .stream(primaryKey: ['productId'])
      .select('*')
      .execute();
  print('Task inserted successfully ${response}');
    // return response;

     var leadLogs = response.data.map((json) {
      // Access properties from the map
      return 
      
      Product(
      productId: json['productId'],
      product_name: json['product_name'],
      size: json['size'],
      cost: json['cost'],
      sell:json['sell'],
      quantity: 0
    );
    }).toList();
//  List<Map<String, dynamic>>? leadLogs = (response.data as List).cast<Map<String, dynamic>>();
    return leadLogs;

}
   Future<List<Map<String, dynamic>>?>  streamLeadActivityLog(uid) async {
    final client = GetIt.instance<SupabaseClient>();
   

      final response = await client
      .from('${'spark'}_lead_logs')
      .select('type, subtype, T, by, from, to')
      .eq('Luid', uid)
      .order('T', ascending: false)
      .execute();
  print('Task inserted successfully ${response}');
    
        List<Map<String, dynamic>>? leadLogs = (response.data as List).cast<Map<String, dynamic>>();
   
   print('Task inserted successfully ${leadLogs}');
    return leadLogs;
    if (response   != null) {
      print(response);
    } else {
      print('Task inserted successfully');
    }
  
  
  }
   Future<List<Map<String, dynamic>>?>  streamLeadCallActivityLog(uid) async {
    final client = GetIt.instance<SupabaseClient>();
   

      final response = await client
      .from('${'spark'}_lead_call_logs')
      .select('type, subtype, T, dailedBy, duration, payload')
      .eq('Luid', uid)
      .order('T', ascending: false)
      .execute();
  print('calls retrieved ${response}');
    
        List<Map<String, dynamic>>? leadLogs = (response.data as List).cast<Map<String, dynamic>>();
   
   print('calls retrieved  successfully ${leadLogs}');
    return leadLogs;
  }
addCallLog(orgId,leadDocId, data)async {
    final client = GetIt.instance<SupabaseClient>();
      final response = await client
      .from('${orgId}_lead_call_logs')
      .upsert([
        {
          'type': data.callType.toString().replaceAll('CallType.', ''),
          'subtype': data.callType.toString().replaceAll('CallType.', ''),
          'T': DateTime.now().millisecondsSinceEpoch,
          'Luid': leadDocId,
          'dailedBy': FirebaseAuth.instance.currentUser!.email,
          'payload': {},
          'customerNo' : data.number,
          'fromPhNo': '',
          'duration': data.duration,
          'startTime': data.timestamp!.toInt(),
        },
      ])
      .execute();
  print('Call log  inserted successfully ${response}');
  var callLog = (response.data as List).cast<Map<String, dynamic>>();
   print('call inserted successfully ${callLog}');
    return callLog;
}

 leadStatusLog(orgId,leadDocId, data) async {
    final client = GetIt.instance<SupabaseClient>();
   

      final response = await client
      .from('${orgId}_lead_logs')
      .upsert([
        {
          'type': 'sts_change',
          'subtype': data['Status'],
          'T': DateTime.now().millisecondsSinceEpoch,
          'Luid': leadDocId,
          'by': FirebaseAuth.instance.currentUser!.email,
          'payload': {'reason': data['VisitDoneReason'], 'notes': data['VisitDoneNotes']},
          'from': data['from'],
          'to': data['Status'],
        },
      ])
      .execute();
  print('Task inserted successfully ${response}');
    
        var leadLogs = (response.data as List).cast<Map<String, dynamic>>();
   
   print('Task inserted successfully ${leadLogs}');
    return leadLogs;
  }
 getLeadCallLogs(orgId,leadDocId) async {
    final client = GetIt.instance<SupabaseClient>();
      final response = await client
      .from('${orgId}_lead_call_logs')
      .select()
      .execute();

  // Get existing call logs from Supabase
  final existingCallLogs = response.data as List<dynamic>;
    print('Task inserted successfully ==> ${existingCallLogs}');
    return existingCallLogs;
  }

  
}
