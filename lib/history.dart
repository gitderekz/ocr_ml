import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ocr_ml/main.dart';

class History extends StatefulWidget {
  const History({super.key, this.width});
  final width;

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  List<DataRow> rows = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populateRows();
  }

  populateRows(){
    int index = 0;
    var presence = sharedPreferences.containsKey('history');
    if(presence){
      List<String> histories = sharedPreferences.getStringList('history')!;
      for (var history in histories) {
        ScrollController scrollController = ScrollController();
        rows.add(
          DataRow(
            cells: [
              DataCell(
                Container(
                  child: Text(
                    '${index+1}',
                    style: TextStyle(
                      // color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.only(bottom: 16.0),
                  width: widget.width,
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          history.split('=>')[0],
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  width: widget.width,
                  child: Text(
                    history.split('=>')[1],
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      // color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        index++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORY'),
        centerTitle: true,
      ),
      body: Scrollbar(
        controller: _verticalController,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _verticalController,
          child: Scrollbar(
            controller: _horizontalController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalController,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DataTable(
                    columnSpacing: 20,
                    // dataRowMinHeight: 100,
                    showBottomBorder: true,
                    dataRowMaxHeight: MediaQuery.of(context).size.width*0.3,
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      return Colors.blueGrey;
                    }),
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'SN',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                        )
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'INGREDIENTS',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                        )
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'PREDICTION',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                        )
                      ),
                    ],
                    rows: rows,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
