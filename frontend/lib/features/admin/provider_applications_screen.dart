import 'package:flutter/material.dart';

import 'package:my_app/core/models/provider_application_model.dart';
import 'package:my_app/core/services/provider_application_service.dart';


class ProviderApplicationsScreen extends StatefulWidget {

  const ProviderApplicationsScreen({
    super.key
  });


  @override
  State<ProviderApplicationsScreen> createState() =>
      _ProviderApplicationsScreenState();

}




class _ProviderApplicationsScreenState
    extends State<ProviderApplicationsScreen> {



List<ProviderApplicationModel> applications=[];


bool loading=true;




@override
void initState(){

super.initState();

_loadApplications();

}





// ================= GET APPLICATIONS =================


Future<void> _loadApplications() async{


setState((){

loading=true;

});



final result =
await ProviderApplicationService
.getApplications();



if(!mounted)return;



if(result.success){


setState((){


applications=result.data;

loading=false;


});


}

else{


setState((){

loading=false;

});


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text(result.message)

)

);



}



}






// ================= UPDATE STATUS =================


Future<void> _updateStatus(
String id,
String status
) async{



final result =
await ProviderApplicationService
.updateStatus(
id,
status
);



if(!mounted)return;



if(result.success){



ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text(
"Application $status"
),

backgroundColor:
Colors.green,

)

);



_loadApplications();



}

else{


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text(result.message),

backgroundColor:
Colors.red,

)

);



}


}






// ================= DELETE =================


Future<void> _confirmDelete(
String id,
String name
) async{


final confirm =
await showDialog<bool>(

context:context,

builder:(context){

return AlertDialog(

title:
const Text("Delete Application"),

content:
Text(
"Are you sure you want to delete $name's application? This action cannot be undone."
),

actions:[

TextButton(
onPressed:()=>
Navigator.pop(context,false),
child:
const Text("Cancel"),
),

TextButton(
onPressed:()=>
Navigator.pop(context,true),
style:
TextButton.styleFrom(
foregroundColor:Colors.red
),
child:
const Text("Delete"),
),

],

);

},

);



if(confirm==true){

_deleteApplication(id);

}


}




Future<void> _deleteApplication(String id) async{


final result =
await ProviderApplicationService
.deleteApplication(id);



if(!mounted)return;



if(result.success){


ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(

content:
Text("Application deleted"),

backgroundColor:
Colors.green,

)

);



_loadApplications();


}

else{


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text(result.message),

backgroundColor:
Colors.red,

)

);


}


}







@override
Widget build(BuildContext context){


return Scaffold(


appBar:AppBar(

title:
const Text(
"Provider Applications"
),


actions:[


IconButton(

icon:
const Icon(Icons.refresh),

onPressed:
_loadApplications,

)


],


),





body:

loading

?

const Center(

child:
CircularProgressIndicator()

)


:

applications.isEmpty


?

const Center(

child:
Text(
"No Applications Found"
)

)



:

ListView.builder(


padding:
const EdgeInsets.all(12),



itemCount:
applications.length,



itemBuilder:(context,index){



final app =
applications[index];



return Card(


elevation:4,


margin:
const EdgeInsets.only(
bottom:12
),



child:
Padding(


padding:
const EdgeInsets.all(15),



child:
Column(


crossAxisAlignment:
CrossAxisAlignment.start,



children:[




Row(

crossAxisAlignment:
CrossAxisAlignment.start,

children:[

Expanded(
child:
Text(

app.name,

style:
const TextStyle(

fontSize:18,

fontWeight:
FontWeight.bold

),

),
),


IconButton(

icon:
const Icon(
Icons.delete_outline,
color:Colors.red,
),

onPressed:()=>
_confirmDelete(
app.id,
app.name,
),

),

],

),





const SizedBox(height:8),





Text(
"Email: ${app.email}"
),



Text(
"Phone: ${app.phone}"
),




const SizedBox(height:8),




// ================= CATEGORIES (multi-select) =================

Text(
"Categories:",
style:
const TextStyle(
fontWeight:FontWeight.w600
),
),


const SizedBox(height:6),


app.categories.isEmpty

?

const Text(
"—",
style:TextStyle(color:Colors.grey),
)

:

Wrap(

spacing:6,

runSpacing:6,

children:
app.categories.map((catName){


return Chip(

label:
Text(
catName,
style:
const TextStyle(fontSize:12),
),


visualDensity:
VisualDensity.compact,


materialTapTargetSize:
MaterialTapTargetSize.shrinkWrap,


backgroundColor:
Colors.blueGrey.shade50,

);


}).toList(),

),




const SizedBox(height:8),




Text(
"Reason:"
),



Text(
app.interestReason
),





const SizedBox(height:10),




Container(

padding:
const EdgeInsets.symmetric(
horizontal:10,
vertical:5
),


decoration:
BoxDecoration(

color:
app.status=="approved"

?
Colors.green.shade100

:

app.status=="rejected"

?
Colors.red.shade100

:

Colors.orange.shade100,


borderRadius:
BorderRadius.circular(10)

),



child:
Text(

app.status.toUpperCase(),

style:
const TextStyle(

fontWeight:
FontWeight.bold

),

),


),





const SizedBox(height:15),





// Status buttons ab hamesha dikhengay,
// taake admin baad mein bhi status
// edit/change kar sake

Row(

children:[



Expanded(

child:
ElevatedButton.icon(


icon:
const Icon(
Icons.check
),


label:
const Text(
"Approve"
),


style:
ElevatedButton.styleFrom(

backgroundColor:
app.status=="approved"

?
Colors.grey

:
Colors.green

),



onPressed:
app.status=="approved"

?
null

:
(){

_updateStatus(

app.id,

"approved"

);


},



),

),




const SizedBox(width:10),





Expanded(

child:
ElevatedButton.icon(


icon:
const Icon(
Icons.close
),


label:
const Text(
"Reject"
),


style:
ElevatedButton.styleFrom(

backgroundColor:
app.status=="rejected"

?
Colors.grey

:
Colors.red

),



onPressed:
app.status=="rejected"

?
null

:
(){


_updateStatus(

app.id,

"rejected"

);



},



),

),




],



)




],



),



),



);



}



),



);



}



}