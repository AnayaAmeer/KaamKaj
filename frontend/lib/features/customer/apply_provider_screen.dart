import 'package:flutter/material.dart';

import 'package:my_app/core/models/category_model.dart';
import 'package:my_app/core/services/category_service.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/core/services/provider_application_service.dart';



class ApplyProviderScreen extends StatefulWidget {

  const ApplyProviderScreen({super.key});


  @override
  State<ApplyProviderScreen> createState() =>
      _ApplyProviderScreenState();

}





class _ApplyProviderScreenState
    extends State<ApplyProviderScreen> {


final nameController =
TextEditingController();


final emailController =
TextEditingController();


final phoneController =
TextEditingController();


final reasonController =
TextEditingController();



List<CategoryModel> categories=[];


bool loadingCategories=true;


// ab multi-select hai, isliye List of selected category ids
List<String> selectedCategories=[];



bool submitting=false;




@override
void initState(){

super.initState();

_loadUser();

_loadCategories();

}





// ================= USER =================


Future<void> _loadUser() async{


final result =
await AuthService.getProfile();



if(result.success &&
result.data!=null){


setState((){


nameController.text =
result.data!["name"] ?? "";


emailController.text =
result.data!["email"] ?? "";


});


}


}






// ================= CATEGORY =================


Future<void> _loadCategories() async{


final result =
await CategoryService.getCategories();



if(!mounted)return;



if(result.success){


setState((){


categories=result.data;

loadingCategories=false;


});


}

else{


setState((){

loadingCategories=false;

});


}



}





// ================= TOGGLE CATEGORY =================

void _toggleCategory(String categoryId){

setState((){

if(selectedCategories.contains(categoryId)){

selectedCategories.remove(categoryId);

}
else{

selectedCategories.add(categoryId);

}

});

}







// ================= SUBMIT =================


Future<void> _submit() async{


if(
selectedCategories.isEmpty ||
phoneController.text.isEmpty ||
reasonController.text.isEmpty
){


ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(
content:
Text("Please fill all fields")
)

);


return;

}



setState((){

submitting=true;

});



final result =
await ProviderApplicationService
.applyProvider(

name:
nameController.text.trim(),


email:
emailController.text.trim(),


phone:
phoneController.text.trim(),


categories:
selectedCategories,


interestReason:
reasonController.text.trim(),


);




setState((){

submitting=false;

});




if(!mounted)return;




if(result.success){


// Success dialog dikhayenge taake message
// pakka nazar aaye, uske baad hi screen
// close hogi

await showDialog(

context:context,

barrierDismissible:false,

builder:(context){

return AlertDialog(

icon:
const Icon(
Icons.check_circle,
color:Colors.green,
size:48,
),

title:
const Text(
"Application Submitted"
),

content:
const Text(
"Your service provider application has been submitted successfully. Status: Pending"
),

actions:[

TextButton(

onPressed:(){

Navigator.pop(context);

},

child:
const Text("OK"),

),

],

);

},

);



if(!mounted)return;



Navigator.pop(context);


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
"Apply For Service Provider"
),

),



body:
SingleChildScrollView(


padding:
const EdgeInsets.all(16),



child:
Column(


children:[



TextField(

controller:nameController,

readOnly:true,

decoration:
const InputDecoration(

labelText:"Name",

border:
OutlineInputBorder()

),

),



const SizedBox(height:15),




TextField(

controller:emailController,

readOnly:true,

decoration:
const InputDecoration(

labelText:"Email",

border:
OutlineInputBorder()

),

),



const SizedBox(height:15),





TextField(

controller:phoneController,


keyboardType:
TextInputType.phone,


decoration:
const InputDecoration(

labelText:"Phone Number",

hintText:"03xxxxxxxxx",

border:
OutlineInputBorder()

),

),




const SizedBox(height:15),






// ================= CATEGORY MULTI SELECT =================


Align(

alignment:
Alignment.centerLeft,

child:
Text(
"Business Interest",
style:
Theme.of(context)
.textTheme
.bodyMedium,
),

),


const SizedBox(height:8),



loadingCategories

?

const CircularProgressIndicator()


:

categories.isEmpty

?

const Text("No categories found")

:

Container(

width:double.infinity,

padding:
const EdgeInsets.all(12),

decoration:
BoxDecoration(

border:
Border.all(
color:Colors.grey.shade400
),

borderRadius:
BorderRadius.circular(8),

),


child:
Wrap(

spacing:8,

runSpacing:8,

children:
categories.map((category){


final isSelected =
selectedCategories
.contains(category.id);



return FilterChip(

label:
Text(category.name),

selected:isSelected,

onSelected:(_){

_toggleCategory(category.id);

},

selectedColor:
Colors.teal.shade100,

checkmarkColor:
Colors.teal,

);


}).toList(),

),

),




const SizedBox(height:6),



Align(

alignment:
Alignment.centerLeft,

child:
Text(
selectedCategories.isEmpty

?
"No category selected"

:
"${selectedCategories.length} selected",

style:
TextStyle(
fontSize:12,
color:Colors.grey.shade600,
),

),

),






const SizedBox(height:15),





TextField(

controller:reasonController,


maxLines:4,


decoration:
const InputDecoration(

labelText:
"Why are you interested?",


hintText:
"Tell us about your experience",


border:
OutlineInputBorder()

),


),




const SizedBox(height:25),






SizedBox(

width:
double.infinity,


height:
50,


child:
ElevatedButton(


onPressed:
submitting
?
null
:
_submit,



child:
submitting

?

const CircularProgressIndicator(
color:Colors.white,
)

:

const Text(
"Submit Application"
),


),


),





],


),


),



);


}



@override
void dispose(){


nameController.dispose();

emailController.dispose();

phoneController.dispose();

reasonController.dispose();


super.dispose();


}


}