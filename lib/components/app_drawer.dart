import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocr_ml/history.dart';
import 'package:ocr_ml/main.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController.text = sharedPreferences.getString('url')!;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.center_focus_weak_sharp),
                  ],
                ),
                decoration: BoxDecoration(

                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>History(width: MediaQuery.of(context).size.width*0.45,)));},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            overflow: TextOverflow.clip,
                            'History',
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                        ),
                        Icon(Icons.work_history_rounded),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Container(
                        height: 60,
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Address'
                          ),
                          controller: textEditingController,
                          onChanged: (url)=>(sharedPreferences.setString('url', '${url}'))
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}
