import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/provider_application_model.dart';
import 'auth_service.dart';



class ProviderApplicationResult{

final bool success;
final String message;
final dynamic data;


ProviderApplicationResult({
required this.success,
this.message="",
this.data
});

}



class ProviderApplicationService {



static Future<ProviderApplicationResult>
applyProvider({

required String name,
required String email,
required String phone,
required List<String> categories, // multi-select ab list hai
required String interestReason,

}) async {


try{


final token =
await AuthService.getToken();



final response =
await http.post(

Uri.parse(ApiConstants.applyProvider),

headers:{

"Content-Type":"application/json",

"Authorization":"Bearer $token"

},


body:jsonEncode({

"name":name,
"email":email,
"phone":phone,
"category":categories,
"interestReason":interestReason


})

);



final body=jsonDecode(response.body);



return ProviderApplicationResult(

success:
response.statusCode==201 &&
body["success"]==true,


message:
body["message"] ?? ""

);



}

catch(e){

return ProviderApplicationResult(
success:false,
message:"Network error"
);

}



}






// ADMIN GET


static Future<ProviderApplicationResult>
getApplications() async{


try{


final token=
await AuthService.getToken();



final response=
await http.get(

Uri.parse(
ApiConstants.adminProviderApplications
),

headers:{

"Authorization":"Bearer $token"

}

);



final body=jsonDecode(response.body);



if(response.statusCode==200){

final list =
(body["data"] as List)
.map((e)=>
ProviderApplicationModel.fromJson(e))
.toList();


return ProviderApplicationResult(

success:true,

data:list

);


}


return ProviderApplicationResult(

success:false,
message:body["message"]

);



}

catch(e){

return ProviderApplicationResult(
success:false,
message:"Network error"
);

}


}






// UPDATE STATUS


static Future<ProviderApplicationResult>
updateStatus(
String id,
String status
) async{


try{


final token=
await AuthService.getToken();



final response=
await http.put(

Uri.parse(
ApiConstants
.updateProviderApplicationStatus(id)
),

headers:{

"Content-Type":"application/json",

"Authorization":"Bearer $token"

},


body:jsonEncode({

"status":status

})

);



final body=jsonDecode(response.body);



return ProviderApplicationResult(

success:
response.statusCode==200,

message:
body["message"] ?? ""

);



}

catch(e){

return ProviderApplicationResult(
success:false,
message:"Network error"
);

}


}






// ADMIN DELETE


static Future<ProviderApplicationResult>
deleteApplication(
String id
) async{


try{


final token=
await AuthService.getToken();



final response=
await http.delete(

Uri.parse(
ApiConstants
.deleteProviderApplication(id)
),

headers:{

"Authorization":"Bearer $token"

}

);



final body=jsonDecode(response.body);



return ProviderApplicationResult(

success:
response.statusCode==200,

message:
body["message"] ?? ""

);



}

catch(e){

return ProviderApplicationResult(
success:false,
message:"Network error"
);

}


}



}