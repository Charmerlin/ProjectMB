import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//--นี้คือส่วนของ main นอกจากจะมีการทำงานปกติแล้ว ก็จะมีคำสั่งเปลี่ยนสีพื้นหลังเป็นสีน้ำเงิน โดยจะเปลี่ยนทั้งสองหน้า--
void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      scaffoldBackgroundColor: Color.fromARGB(
          255, 32, 20, 76), // เปลี่ยนพื้นหลังของ Scaffold เป็นสีเงิน
    ),
    home: const MyApp(),
  ));
}
//<--นี้คือส่วนของ main นอกจากจะมีการทำงานปกติก็จะมีคำสั่งเปลี่ยนสีพื้นหลังเป็นสีน้ำเงิน โดยจะเปลี่ยนทั้งสองหน้า--


//--ส่วนการเรียก API-->
String url = 'https://api.sampleapis.com/movies/animation';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
//--ส่วนการเรียก API-->


//--ส่วนตรงนี้จะดึงข้อมูลมาจากClass Animation ที่อยู่ข้างล่างมาแสดง--
class _MyAppState extends State<MyApp> {
  late List<Animation> menu;
  late List<Animation> filteredMenu;

  @override
  void initState() {
    super.initState();
    menu = [];
    filteredMenu = [];
    getData();
  }

  Future<void> getData() async {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Animation> animations = jsonData.map((item) {
        return Animation(
          id: item['id'],
          title: item['title'],
          posterURL: item['posterURL'],
          imdbId: item['imdbId'],
        );
      }).toList();

      setState(() {
        menu = animations;
        filteredMenu = animations;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void filterMenu(String query) {
    setState(() {
      filteredMenu = menu
          .where((animation) =>
              animation.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
//--ส่วนตรงนี้จะดึงข้อมูลมาจากClass Animation ที่อยู่ข้างล่างมาแสดง--


//--เป็นส่วนของคำสั่งในหน้าจอหลัก-->
//--ส่วนของการเรียกคำสั่งในAppBar-->
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 18, 58, 143),
        title: Center( // ทำให้ส่วนของ Text อยู่ตรงกลาง
            child: const Text(
          'Animation List',
          style: TextStyle(
            color: Colors.white, // กำหนดสีข้อความให้เป็นสีขาว
            fontSize: 40, //กำหนดขนาดข้อความ
          ),
        )), 

        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final String? selected = await showSearch<String>(
                context: context,
                delegate: CustomSearchDelegate(filteredMenu),
              );
              // Handle selected item here
            },
          ),
        ],
        // เพิ่ม TextField สำหรับการค้นหาใน AppBar
        // ในส่วนของ bottom ของ AppBar
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56), //กำหนดขนาดช่องค้นหา
          child: TextField(
            onChanged:
                filterMenu, // เมื่อมีการค้นหาใน TextField ให้เรียกฟังก์ชัน filterMenu
            decoration: InputDecoration(
              hintText: 'Search...',
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              hintStyle: TextStyle(
                  color: Colors.white), // กำหนดสีของ hintText เป็นสีขาว
            ),
          ),
        ),
      ),
      //-ส่วนของการเรียกคำสั่งในAppBar-->

      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // ส่วนกำหนดจำนวนคอลัมน์ที่แสดง list Animetion ในหน้าแรก
        ),
        itemCount: filteredMenu.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AnimationDetailPage(animation: filteredMenu[index]),
                ),
              );
            },
            child: Card( //เป็นส่วนข้อมูลที่อยู่ใน index ของ list Animetion ในหน้าแรก
              color: Color.fromARGB(255, 53, 186, 230),
              child: Column(
                children: [
                  Image.network(filteredMenu[index].posterURL), //จะมีการเรียกรูปภาพของ Animetionนั้นๆ
                  SizedBox(height: 10),
                  Text(
                    filteredMenu[index].title,
                    style: TextStyle(
                      fontSize: 20, // กำหนดขนาดของข้อความใน Text widget
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
//--เป็นส่วนของคำสั่งในหน้าจอหลัก-->


//--ส่วนตรงนี้คือClass Animation-->
class Animation {
  final int id;
  final String title;
  final String posterURL;
  final String imdbId;

  Animation({
    required this.id,
    required this.title,
    required this.posterURL,
    required this.imdbId,
  });
}
//--ส่วนตรงนี้คือClass Animation-->


//--ส่วนตรงนี้คือโค้ดของหน้าที่2 เมื่อกดที่รูปจากหน้าแรกจะมาหน้านี้-->
//--โดยจะแบ่งหลักๆ2ส่วน คือ 1 AnimationDetailPage เป็นส่วนที่ใช้สำหรับแสดงรายละเอียดของ Animation แต่ละตัว เช่น ขนาดสี และลำดับการแสดงอะไรขึ้นก่อนขึ้นหลัง 
class AnimationDetailPage extends StatelessWidget {
  final Animation animation;

  const AnimationDetailPage({Key? key, required this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animation.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(animation.posterURL),
            SizedBox(height: 20),
            Text(
              animation.title,
              style:
                  TextStyle(color: Colors.white, fontSize: 22), // กำหนดสีข้อความให้เป็นสีขาว
            ),
            SizedBox(height: 20),
            Text(
              'IMDB ID: ${animation.imdbId}',
              style:
                  TextStyle(color: Colors.white, fontSize: 18), // กำหนดสีข้อความให้เป็นสีขาว
            ),
          ],
        ),
      ),
    );
  }
}


//ส่วนที่2 CustomSearchDelegate เป็นส่วนที่ใช้สำหรับค้นหา Animation แต่ละตัว โดยมีการสร้าง UI สำหรับแสดงผลการค้นหาและการเลือก Animation 
class CustomSearchDelegate extends SearchDelegate<String> {
  final List<Animation> animations;

  CustomSearchDelegate(this.animations);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return SizedBox(); // ไม่แสดงปุ่ม "Back" ในการค้นหา
  }

//ส่วนของ buildResults เป็นส่วนที่ใช้สำหรับแสดงผลการค้นหา
  @override
  Widget buildResults(BuildContext context) {
    final List<Animation> searchResults = animations
        .where((animation) =>
            animation.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index].title),
          onTap: () {
            close(context, searchResults[index].title);
          },
        );
      },
    );
  }

//--ส่วนของ buildSuggestions เป็นส่วนที่ใช้สำหรับแสดงผลการค้นหา--
  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Animation> searchResults = animations
        .where((animation) =>
            animation.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index].title),
          onTap: () {
            close(context, searchResults[index].title);
          },
        );
      },
    );
  }
  //--ส่วนของ buildSuggestions เป็นส่วนที่ใช้สำหรับแสดงผลการค้นหา--
}
//--ส่วนตรงนี้คือโค้ดของหน้าที่2เมื่อกดที่รูปจากหน้าแรกจะมีหน้านี้-->
