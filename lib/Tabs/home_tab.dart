import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:smart_call_app/Pages/favourites_page.dart';
import 'package:smart_call_app/Pages/for_you_page.dart';

import '../Widgets/country_to_flag.dart';
import '../db/entity/app_user.dart';
import '../db/remote/firebase_database_source.dart';

class HomeScreen extends StatefulWidget {
  final AppUser myuser;

  const HomeScreen({super.key, required this.myuser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Country? country;

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  bool _onlineVisible = false;

  @override
  Widget build(BuildContext context) {
    List pages = [ ForYouPage(myuser: widget.myuser, country: country==null?"random":country!.countryCode,), FavouritesPage(myuser: widget.myuser,)];
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
                  CountryListPicker(context),
                  _buildTabText(),
                  IconButton(
                    icon: Icon(
                      _onlineVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _onlineVisible = !_onlineVisible;
                      });
                      if(_onlineVisible){
                        _databaseSource.updateStatus(widget.myuser.id, "online");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                "Online",
                                style: TextStyle(color: Colors.black), textAlign: TextAlign.center
                              ),
                              backgroundColor: Colors.greenAccent,
                              behavior: SnackBarBehavior.floating,
                              width: 200),
                        );
                      }else{
                        _databaseSource.updateStatus(widget.myuser.id, "offline");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Offline",
                                  style: TextStyle(color: Colors.black), textAlign: TextAlign.center
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              width: 200),
                        );
                      }

                    },
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: PageView.builder(
          physics: const ClampingScrollPhysics(),
          controller: _pageController,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemCount: pages.length,
          itemBuilder: (BuildContext context, int index) {
            return pages[index];
          }),
    );
  }


  GestureDetector CountryListPicker(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            country=null;
          });
          showCountryPicker(
              context: context,
              countryListTheme: CountryListThemeData(
                flagSize: 25,
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
              onSelect: (Country country) {
                setState(() {
                  print(country.name);
                  print(country.displayName);
                  print(country.flagEmoji);
                  print(country.countryCode);
                  print(country.displayNameNoCountryCode);
                  print(country.e164Key);
                  print(country.e164Sc);
                  print(country.example);
                  this.country = country;
                });
              });
        },
        child: country == null ? const Icon(Icons.public,color: Colors.white,size: 30,):Text(country!.flagEmoji,
            style: country == null
                ? const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                : const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.normal)));
  }

  Widget _buildTabText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              _pageController.animateToPage(0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.bounceInOut);
            },
            child: Text(
              'ForYou',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight:_currentPage == 0 ?  FontWeight.bold : FontWeight.w500,
                  color: _currentPage == 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary),
            ),
          ),
          Container(
            // color: borderColor,
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          InkWell(
            onTap: () {
              _pageController.animateToPage(1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.bounceInOut);
            },
            child: Text(
              'Favourites',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight:_currentPage == 1 ?  FontWeight.bold : FontWeight.w500,
                  color: _currentPage == 1
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
