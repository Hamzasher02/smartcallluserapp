import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart' as slideDialog;
import 'package:smart_call_app/Screens/authentication/controller/response.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:smart_call_app/Util/app_url.dart';
import '../../../Widgets/image_portrate.dart';
import '../../../Widgets/rounded_icon_button.dart';
import '../../../db/Models/user_registration.dart';
import '../../../db/entity/app_user.dart';
import '../../../db/remote/firebase_database_source.dart';
import '../../../db/remote/firebase_storage_source.dart';

class EditProfile extends StatefulWidget {
  final AppUser myuser;

  const EditProfile({super.key, required this.myuser});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
  final FirebaseFirestore instance = FirebaseFirestore.instance;
  AppUser? _user;
  final FirebaseStorageSource _storageSource = FirebaseStorageSource();
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  update() {
    Navigator.pop(context);
    setState(() {
      print('update screen');
    });
  }

  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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

  @override
  void initState() {
    super.initState();
    exam = widget.myuser.age;
    gender = widget.myuser.gender;
    _nameController.text = widget.myuser.name;
    initAd();
  }

  initAd() {
    InterstitialAd.load(
      adUnitId: AppUrls.interstitialAdID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isAdLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
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
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60.0),
                              child: Image.network(
                                widget.myuser.profilePhotoPath,
                                fit: BoxFit.cover,
                                width: 120,
                              ),
                            )
                          // Text(_primaryphoto)
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
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  // onTap: () {
                  //   setState(() {});
                  // },
                  onFieldSubmitted: (val) {
                    setState(() {
                      _nameController.text = val;
                    });
                  },
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
                            backgroundColor: Theme.of(context).secondaryHeaderColor,
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
                                  color: const Color(0xFF8C98A8).withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          onSelect: (Country cou) {
                            setState(() {
                              country = cou.countryCode;
                            });
                          }

                          // print('Select country: ${country.displayName}'),
                          );
                    },
                    child: Text(
                      country,
                      style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
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
                    items: <String>['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String gen) {
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
                  child: isLoading == false
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            print(gender);
                            print(country);
                            print(exam);
                            print(_nameController.text);
                            // _userRegistration.name = _nameController.text;
                            // _userRegistration.age = exam;
                            // _userRegistration.country = country;
                            // _userRegistration.gender = gender;
                            if (_nameController.text.isEmpty) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please Enter Name", style: TextStyle(color: Colors.black), textAlign: TextAlign.center),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    width: 200),
                              );
                            } else if (country == 'Select Country') {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please Select Country", style: TextStyle(color: Colors.black), textAlign: TextAlign.center),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    width: 200),
                              );
                            } else {
                              widget.myuser.country = country;
                              widget.myuser.name = _nameController.text;
                              widget.myuser.gender = gender;
                              widget.myuser.age = exam;
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String userId = prefs.getString("myid")!;
                              Response<dynamic> res = await _storageSource.uploadUserProfilePhoto(_imagePath, userId);
                              if (res is Success<String>) {
                                widget.myuser.profilePhotoPath = res.value;
                              }
                              await instance.collection('users').doc(widget.myuser.id).update(widget.myuser.toMap());
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update Successful')));
                              if (_isAdLoaded) {
                                _interstitialAd!.show();
                                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const MainPage(tab: 3)),
                                      (route) => false,
                                );
                              }
                            }
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
                          ))
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff607d8b),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  uploadImage(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("myid")!;
    Response<dynamic> res = await _storageSource.uploadUserProfilePhoto(_imagePath, userId);
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd!.dispose();
  }
}
