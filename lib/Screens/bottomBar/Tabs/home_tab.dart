import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Screens/home/favourites_page.dart';
import 'package:smart_call_app/Screens/home/for_you_page.dart';

import '../../../Widgets/country_to_flag.dart';
import '../../../db/entity/app_user.dart';
import '../../../db/remote/firebase_database_source.dart';

class HomeScreen extends StatefulWidget {
  final AppUser myuser;

  const HomeScreen({super.key, required this.myuser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Country? countryRename;

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  bool _onlineVisible = true;

  @override
  void initState() {
    super.initState();
    _loadIconState();
  }

  Future<void> _loadIconState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _onlineVisible = prefs.getBool('eyeIconState') ?? true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      ForYouPage(
        myuser: widget.myuser,
        country: countryRename == null ? "random" : countryRename!.countryCode,
      ),
      FavouritesPage(
        myuser: widget.myuser,
      )
    ];
    // country?.countryCode = "AL";
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: false,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Country Picker Icon or Flag
                      CountryListPicker(context),

                      // Expanded widget wraps the _buildTabText to allow flexible space for the texts
                      Expanded(
                        child: _buildTabText(),
                      ),

                      // Visibility Icon
                      IconButton(
                        icon: Icon(
                          _onlineVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _onlineVisible = !_onlineVisible;
                              prefs.setBool('eyeIconState', _onlineVisible);
                            });
                          });

                          if (_onlineVisible) {
                            await _databaseSource.updateStatus(
                                widget.myuser.id, "online");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Online",
                                  style: TextStyle(color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.greenAccent,
                                behavior: SnackBarBehavior.floating,
                                width: 200,
                              ),
                            );
                          } else {
                            await _databaseSource.updateStatus(
                                widget.myuser.id, "offline");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Offline",
                                  style: TextStyle(color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                width: 200,
                              ),
                            );
                          }
                        },
                      )
                    ],
                  )),
            ),
          ];
        },
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentPage = index;
              });
            });
          },
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return pages[index];
          },
        ));
  }

  GestureDetector CountryListPicker(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          countryRename = null;
        });

        // Detect if the theme is dark or light
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

        showCountryPicker(
          context: context,
          countryListTheme: CountryListThemeData(
            flagSize: 25,
            backgroundColor: isDarkMode
                ? Colors.black
                : Colors.white, // Background based on theme
            textStyle: TextStyle(
              fontSize: 16,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black, // Text color based on theme
            ),
            bottomSheetHeight: 500,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            inputDecoration: InputDecoration(
              labelText: 'Search',
              labelStyle: TextStyle(
                color: isDarkMode
                    ? Colors.white70
                    : Colors.black87, // Label text color
              ),
              hintText: 'Start typing to search',
              hintStyle: TextStyle(
                color: isDarkMode
                    ? Colors.white54
                    : Colors.black54, // Hint text color
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDarkMode
                    ? Colors.white
                    : Colors.black, // Search icon color
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFF8C98A8).withOpacity(0.2),
                ),
              ),
              contentPadding: const EdgeInsets.all(12.0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            searchTextStyle: TextStyle(
              color:
                  isDarkMode ? Colors.white : Colors.black, // Search text color
            ),
          ),
          onSelect: (Country country) {
            setState(() {
              print(country.name);
              countryRename = country;
            });
            log(countryRename!.countryCode);
          },
        );
      },
      child: countryRename == null
          ? const Icon(
              Icons.public,
              color: Colors.white, // Icon color
              size: 30,
            )
          : Text(
              countryRename!.flagEmoji,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.normal,
                color: Colors.white, // Text color for selected country flag
              ),
            ),
    );
  }

  Widget _buildTabText() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth <= 300 ? 12 : 16;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.bounceInOut,
                );
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'ForYou',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight:
                        _currentPage == 0 ? FontWeight.bold : FontWeight.w500,
                    color: Colors.white, // Set text color to white
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.bounceInOut,
                );
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Favourites',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight:
                        _currentPage == 1 ? FontWeight.bold : FontWeight.w500,
                    color: Colors.white, // Set text color to white
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
