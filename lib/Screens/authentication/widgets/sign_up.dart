import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart' as slideDialog;
import 'package:smart_call_app/Screens/main_page.dart';
import 'package:smart_call_app/Util/constants.dart';
import '../../../Widgets/image_portrate.dart';
import '../../../Widgets/rounded_icon_button.dart';
import '../../../db/Models/user_registration.dart';
import '../../../db/entity/app_user.dart';
import '../../../db/remote/firebase_database_source.dart';
import '../../../db/remote/firebase_storage_source.dart';
import '../controller/response.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  String exam = '1';
  String country = 'Select Country';
  String gender = 'Male';
  String _imagePath = "";
  final picker = ImagePicker();
  bool isLoading = false;
  bool _primaryphotocheck = false;
  final String _primaryphoto = "Add Picture";
  final _nameController = TextEditingController();
  final UserRegistration _userRegistration = UserRegistration();
  AppUser? _user;
  final FirebaseStorageSource _storageSource = FirebaseStorageSource();
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  Future<Response> _addUser(UserRegistration userRegistration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userRegistration.id = prefs.getString("myid")!;
    Response<dynamic> res = await _storageSource.uploadUserProfilePhoto(
        _imagePath, userRegistration.id);
    if(res is Success<String>){
      userRegistration.localProfilePhotoPath = res.value;
      AppUser user = AppUser(
          id: userRegistration.id,
          name: userRegistration.name,
          age: userRegistration.age,
          gender: userRegistration.gender,
          country: userRegistration.country,
          profilePhotoPath: userRegistration.localProfilePhotoPath,
          token: "",
          temp1: "",
          temp2: "",
          temp3: "",
          temp4: "",
          temp5: "",
        status: "online",
        likes: 0,
        type: "live",
        views: 0,
      );
      _databaseSource.addUser(user);
      _user = _user;
      prefs.setBool('isLogin', true);
      return Response.success(user);
    }
    // if (Response is Error<String>)
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text("error")));
    return res;
  }

  update() {
    Navigator.pop(context);
    setState(() {
      print('update screen');
    });
  }

  Future pickImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // widget.onPhotoChanged(pickedFile.path);

      setState(() {
        _imagePath = pickedFile.path;
        //update();
        // _showPictureDialog();
        _primaryphotocheck = true;
      });
    }
  }

  void _showPictureDialog() {
    slideDialog.showSlideDialog(
        context: context,
        barrierColor: Colors.white.withOpacity(0.7),
        pillColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Expanded(child: SingleChildScrollView(
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SizedBox(
                      height: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 40,
                              width: double.infinity,
                              color: Theme.of(context).secondaryHeaderColor,
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
                                child: Text(
                                  "Add Photo",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Profile Picture"),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Stack(
                                    children: [
                                      SizedBox(
                                        height: 400,
                                        width: 200,
                                        child: _imagePath == ""
                                            ? ImagePortrait(
                                                imageType: ImageType.NONE,
                                                imagePath: '',
                                              )
                                            : ImagePortrait(
                                                imagePath: _imagePath,
                                                imageType: ImageType.FILE_IMAGE,
                                              ),
                                      ),
                                      Positioned.fill(
                                        left: _imagePath == "" ? 0 : 150,
                                        top: _imagePath == "" ? 0 : 350,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: _imagePath == ""
                                              ? RoundedIconButton(
                                                  onPressed:
                                                      pickImageFromGallery,
                                                  iconData: Icons.add,
                                                  iconSize: 20,
                                                  buttonColor: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                )
                                              : RoundedIconButton(
                                                  onPressed:
                                                      pickImageFromGallery,
                                                  iconData:
                                                      Icons.autorenew_outlined,
                                                  iconSize: 20,
                                                  buttonColor: Theme.of(context)
                                                      .secondaryHeaderColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: double.maxFinite,
                                    height: 40,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              // Change your radius here
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Theme.of(context).colorScheme.onPrimary),
                                        ),
                                        child: const Text("Save",
                                            style: TextStyle(fontSize: 18)),
                                        onPressed: () => setState(() {
                                              // _primaryphoto = 'Selected';
                                              // _primaryphotocheck = true;
                                              update();
                                            })),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ));
          }),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Create Profile',style: TextStyle(fontSize: 28,color: Theme.of(context).colorScheme.primary,fontWeight: FontWeight.bold),),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   decoration: BoxDecoration(
                //     color: Color(0xff00fff9),
                //     borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                //   ),
                //   width: getWidth(context) * 1,
                //   height: 50,
                // ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      pickImageFromGallery();
                    },
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: _imagePath == ""
                          ? Text(_primaryphoto)
                          : ImagePortrait(
                              imagePath: _imagePath,
                              imageType: ImageType.FILE_IMAGE,
                            ),

                      // _imagePath == "" ? Text(_primaryphoto) :
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _nameController,
                  onTap: () {
                    setState(() {});
                  },
                  // controller: _userPhoneController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    hintText: 'User Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Select Age',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 400,
                  child: DropdownButton<String>(
                    value: exam,
                    items: <String>[
                      '1',
                      '2',
                      '3',
                      '4',
                      '5',
                      '6',
                      '7',
                      '8',
                      '9',
                      '10',
                      '11',
                      '12',
                      '13',
                      '14',
                      '15',
                      '16',
                      '17',
                      '18',
                      '19',
                      '20',
                      '21',
                      '22',
                      '23',
                      '24',
                      '25',
                      '26',
                      '27',
                      '28',
                      '29',
                      '30',
                      '31',
                      '32',
                      '33',
                      '34',
                      '35',
                      '36',
                      '37',
                      '38',
                      '39',
                      '40',
                      '41',
                      '42',
                      '43',
                      '44',
                      '45',
                      '46',
                      '47',
                      '48',
                      '49',
                      '50',
                      '51',
                      '52',
                      '53',
                      '54',
                      '55',
                      '56',
                      '57',
                      '58',
                      '59',
                      '60',
                      '61',
                      '62',
                      '63',
                      '64',
                      '65',
                      '66',
                      '67',
                      '68',
                      '69',
                      '70',
                      '71',
                      '72',
                      '73',
                      '74',
                      '75',
                      '76',
                      '77',
                      '78',
                      '79',
                      '80'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        exam = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 400,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      showCountryPicker(
                          context: context,
                          countryListTheme: CountryListThemeData(
                            flagSize: 25,
                            // backgroundColor: Colors.white,
                            backgroundColor:
                                Theme.of(context).secondaryHeaderColor,
                            textStyle: const TextStyle(
                              fontSize: 16,
                            ),
                            bottomSheetHeight: 500,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            inputDecoration: InputDecoration(
                              labelText: 'Search',
                              hintText: 'Start typing to search',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      const Color(0xFF8C98A8).withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          onSelect: (Country cou) {
                            country = cou.countryCode;
                            setState(() {});
                          }
                          // print('Select country: ${country.displayName}'),
                          );
                    },
                    child: Text(
                      country,
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 400,
                  child: DropdownButton<String>(
                    value: gender,
                    items: <String>['Male', 'Female', 'Other']
                        .map<DropdownMenuItem<String>>((String gen) {
                      return DropdownMenuItem<String>(
                        value: gen,
                        child: Text(
                          gen,
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? gen1) {
                      setState(() {
                        gender = gen1!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 400,
                  height: 50,
                  child: isLoading ==false? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        print(gender);
                        print(country);
                        print(exam);
                        print(_nameController.text);
                        _userRegistration.name = _nameController.text;
                        _userRegistration.age = exam;
                        _userRegistration.country =  country;
                        _userRegistration.gender = gender;
                        if(_nameController.text.isEmpty){
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Please Enter Name",
                                    style: TextStyle(color: Colors.black), textAlign: TextAlign.center
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                width: 200),
                          );
                        }else
                          if(country=='Select Country'){
                            setState(() {
                              isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Please Select Country",
                                      style: TextStyle(color: Colors.black), textAlign: TextAlign.center
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  width: 200),
                            );

                          }else{
                            _addUser(_userRegistration).then((res) {
                              if(res is Success){
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => const MainPage(tab: 0,),
                                  ),
                                      (route) => false,
                                );
                              } else if (res is Error){
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Error",
                                          style: TextStyle(color: Colors.black), textAlign: TextAlign.center
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      width: 200),
                                );
                              }
                            });
                          }
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary),
                      )):const Center(
                    child: CircularProgressIndicator(color: Color(0xff607d8b),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
