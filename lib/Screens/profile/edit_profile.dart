import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_call_app/Screens/authentication/controller/response.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:smart_call_app/Util/app_url.dart';
import '../../../Widgets/image_portrate.dart';
import '../../../db/Models/user_registration.dart';
import '../../../db/entity/app_user.dart';
import '../../../db/remote/firebase_database_source.dart';
import '../../../db/remote/firebase_storage_source.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class EditProfile extends StatefulWidget {
  final AppUser myuser;

  const EditProfile({super.key, required this.myuser});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String returnCountry() {
    return widget.myuser.country;
  }

  String exam = '1';
  String country = "Select Country";
  String gender = 'Select Gender';
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
    if (kDebugMode) {
      print("Current name is ${widget.myuser.name}");
      print("Current age is ${widget.myuser.age}");
      print("Current country is ${widget.myuser.country}");
    }
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

  void _handleUpdate() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (_nameController.text.isEmpty) {
        showSnackBar("Please Enter Name", Colors.redAccent);
      } else {
        // Preserve existing values if no changes are made
        String updatedCountry =
            country == 'Select Country' ? widget.myuser.country : country;
        String updatedName = _nameController.text.isEmpty
            ? widget.myuser.name
            : _nameController.text;
        String updatedGender =
            gender == 'Select Gender' ? widget.myuser.gender : gender;
        String updatedAge = exam == 'Select Age' ? widget.myuser.age : exam;
        String updatedProfilePhoto = _imagePath.isEmpty
            ? widget.myuser.profilePhotoPath
            : await _uploadProfilePhotoIfNeeded();

        // Update user details
        widget.myuser.country = updatedCountry;
        widget.myuser.name = updatedName;
        widget.myuser.gender = updatedGender;
        widget.myuser.age = updatedAge;
        widget.myuser.profilePhotoPath = updatedProfilePhoto;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String userId = prefs.getString("myid")!;

        await instance
            .collection('users')
            .doc(widget.myuser.id)
            .update(widget.myuser.toMap());

        if (mounted) {
          if (_isAdLoaded) {
            _interstitialAd!.show();
            _interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                ad.dispose();
                if (mounted) _navigateToMainPage();
              },
              onAdFailedToShowFullScreenContent:
                  (InterstitialAd ad, AdError error) {
                ad.dispose();
                if (mounted) _navigateToMainPage();
              },
            );
          } else {
            if (mounted) _navigateToMainPage();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar("An error occurred: $e", Colors.redAccent);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadProfilePhotoIfNeeded() async {
    if (_imagePath.isNotEmpty) {
      Response<dynamic> res = await _storageSource.uploadUserProfilePhoto(
          _imagePath,
          (await SharedPreferences.getInstance()).getString("myid")!);
      if (res is Success<String>) {
        return res.value;
      }
    }
    return widget.myuser.profilePhotoPath;
  }

  void showSnackBar(String message, Color backgroundColor) {
    if (_scaffoldMessengerKey.currentState != null) {
      _scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 4),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          width: 200,
        ),
      );
    }
  }

  void _navigateToMainPage() {
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage(tab: 0)),
        (route) => false,
      );
    }
  }

  void onAdLoaded(InterstitialAd ad) {
    if (mounted) {
      setState(() {
        _interstitialAd = ad;
        _isAdLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Edit Profile',
          style: TextStyle(
              fontSize: 28,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
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
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors
                                  .black, // Ensure the country names are black
                            ),
                            searchTextStyle: const TextStyle(
                              color: Colors
                                  .black, // Ensure the entered text color is black
                            ),
                            flagSize: 25,
                            backgroundColor: Colors.white,
                            // backgroundColor: Theme.of(context).secondaryHeaderColor,

                            bottomSheetHeight: 500,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            inputDecoration: InputDecoration(
                              labelText: 'Search',
                              labelStyle: TextStyle(color: Colors.black),
                              hintText: 'Start typing to search',
                              hintStyle: TextStyle(
                                color: Colors.black,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.black, // Search icon color black
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      const Color(0xFF8C98A8).withOpacity(0.2),
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
                      country == 'Select Country'
                          ? widget.myuser.country
                          : country,
                      style: TextStyle(
                          fontSize: 18,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 400,
                  child: DropdownButton<String>(
                    value: gender == "Select Gender"
                        ? widget.myuser.gender
                        : gender,
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: _handleUpdate,
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer)
                        : Text(
                            'Update',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer),
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
    Response<dynamic> res =
        await _storageSource.uploadUserProfilePhoto(_imagePath, userId);
  }

  @override
  void dispose() {
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
    }
    super.dispose();
  }
}
