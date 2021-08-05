import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: Homepage(),
  ));
}




class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int temperature = 0;
  String location = "London";
  int woeid = 44418;
  String weather = "clear";
  String abbreviation = '';
  String errorMessage = '';


  String searchApiurl = 'https://www.metaweather.com/api/location/search/?query=';
  String locationApiurl = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchlocation();
  }


  Future<void> fetchsearch(String input) async{
    try {
      var searchResults = await http.get(Uri.parse(searchApiurl + input));
      var result = json.decode(searchResults.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];

      });
    }
    catch(error){
      setState(() {
        errorMessage = 'Sorry !! we dont have the data ';

      });

    }

  }

  Future<void> fetchlocation() async{
    var locationResults = await http.get(Uri.parse(locationApiurl + woeid.toString()));
    var result = json.decode(locationResults.body);
    var consolidatedweather = result["consolidated_weather"];
    var data = consolidatedweather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ','').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });



  }
  Future<void>  onTextFieldSubmitted(String input) async{
    await fetchsearch(input);
    await fetchlocation();
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(

            image: AssetImage("images/$weather.png"),
            fit: BoxFit.cover,
          ),

        ),
        child: temperature == null
        ?Center(child: CircularProgressIndicator())

        :Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [

              Center(
                child: Image.network(
                  'https://www.metaweather.com/static/img/weather/png/'+abbreviation+'.png',
                  width: 100,
                ),
              ),


              Center(child: Text(temperature.toString() + "C",
                style: TextStyle(color: Colors.white, fontSize: 60),
              )),
              Center(child: Text(location,
                style: TextStyle(color: Colors.white, fontSize: 60),
              )),
                ],
              ),

             Column(
               children: [
                 Container(
                   width: 300,
                   child: TextField(
                     onSubmitted: (String input){
                       onTextFieldSubmitted(input);
                     },
                     style: TextStyle(color: Colors.white, fontSize: 25),
                     decoration: InputDecoration(
                       hintText: 'Search Another Location',
                       hintStyle: TextStyle(color: Colors.white, fontSize: 20),
                       prefixIcon: Icon(Icons.search, color: Colors.white,)
                     ),
                   ),

                 ),
                 Text(
                   errorMessage,
                   textAlign: TextAlign.center,
                   style: TextStyle(
                     color: Colors.red,
                     fontSize: 25,
                   ),
                 ),
               ],
             ),

            ],
          ),
        ),
      ),
    );
  }


}



