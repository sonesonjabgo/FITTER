import 'dart:convert';
import 'package:fitter/models/wod_detail_model.dart';
import 'package:fitter/screens/wod/wod_detail_screen.dart';
import 'package:http/http.dart' as http;

import 'package:fitter/widgets/button_mold.dart';
import 'package:fitter/widgets/empty_box.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WodInputScreen extends StatefulWidget {
  final String wodName, wodId;
  final dynamic type;
  const WodInputScreen(
      {super.key,
      required this.wodName,
      required this.type,
      required this.wodId});

  @override
  State<WodInputScreen> createState() => _WodInputScreenState();
}

class _WodInputScreenState extends State<WodInputScreen> {
  final recordController = TextEditingController();
  final minController = TextEditingController();
  final secController = TextEditingController();
  final hourController = TextEditingController();
  String defaultHour = "00";
  String defaultMin = "00";
  String defaultSec = "00";

  var selectedDate = DateTime.now();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    (widget.type == "생성") ? () {} : callServer();
  }

  Future callServer() async {
    var url = Uri.parse(
        'http://j9d202.p.ssafy.io:8000/api/named-wod/wod-record/read/${widget.type}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      print('Response data: ${response.body}');
      print("success");
      final dynamic wod = jsonDecode(response.body);

      WODDetailModel wodDetail = WODDetailModel.fromJson(wod);

      final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

      setState(() {
        selectedDate = dateFormatter.parse(wodDetail.createDate);
      });

      if (wodDetail.time != null) {
        final parts = wodDetail.time!.split(':');
        if (parts.length == 3) {
          hourController.text = parts[0];
          minController.text = parts[1];
          secController.text = parts[2];
        }
      }

      if (wodDetail.count != null) {
        recordController.text = wodDetail.count.toString();
      }
    } else {
      // 요청이 실패한 경우
      setState(() {
        print('요청 실패: ${response.statusCode}');
      });
    }
  }

  Future updatePR() async {
    prefs = await SharedPreferences.getInstance();
    var url = Uri.parse(
        'http://j9d202.p.ssafy.io:8000/api/named-wod/wod-record/modify/${widget.type}');

    final headers = {
      'Authorization': prefs.getString('Authorization').toString(),
      'Content-Type': 'application/json'
    };

    if (hourController.text != "") {
      defaultHour = hourController.text;
    }
    if (minController.text != "") {
      defaultMin = minController.text;
    }
    if (secController.text != "") {
      defaultSec = secController.text;
    }

    final body = jsonEncode(
      {
        "count": recordController.text,
        "time": "$defaultHour:$defaultMin:$defaultSec",
        "wodId": widget.wodId,
      },
    );

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // 요청이 성공한 경우
      setState(() {
        print('요청 성공: ${response.body}');
      });
    } else {
      // 요청이 실패한 경우
      setState(() {
        print('요청 실패: ${response.statusCode}');
      });
    }
  }

  Future writePR() async {
    prefs = await SharedPreferences.getInstance();
    var url = Uri.parse(
        'http://j9d202.p.ssafy.io:8000/api/named-wod/wod-record/create');

    final headers = {
      'Authorization': prefs.getString('Authorization').toString(),
      'Content-Type': 'application/json'
    };

    if (hourController.text != "") {
      defaultHour = hourController.text;
    }
    if (minController.text != "") {
      defaultMin = minController.text;
    }
    if (secController.text != "") {
      defaultSec = secController.text;
    }

    final body = jsonEncode(
      {
        "createDate": DateFormat('yyyy-MM-dd').format(selectedDate),
        "count": recordController.text,
        "time": "$defaultHour:$defaultMin:$defaultSec",
        "wodId": widget.wodId,
      },
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // 요청이 성공한 경우
      setState(() {
        print('요청 성공: ${response.body}');
      });
    } else {
      // 요청이 실패한 경우
      setState(() {
        print('요청 실패: ${response.statusCode}');
      });
    }
  }

  void _openDatePicker(BuildContext context) {
    BottomPicker.date(
      title: ' ',
      dateOrder: DatePickerDateOrder.ymd,
      pickerTextStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.blue,
      ),
      buttonText: '',
      buttonTextStyle: const TextStyle(color: Colors.white),
      buttonSingleColor: const Color(0xff0080ff),

      // 선택할 수 있는 날짜 범위 제한
      maxDateTime: DateTime.now(),
      minDateTime: DateTime.now().subtract(const Duration(days: 365 * 100)),
      onChange: (index) {
        print(index);
      },
      onSubmit: (index) {
        setState(() {
          selectedDate = index;
        });
      },
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.5,
        title: Text(
          (widget.type == "생성") ? "${widget.wodName} RECORD" : "기 록 수 정",
          style: const TextStyle(fontSize: 25),
        ),
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const EmptyBox(boxSize: 1),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                  border: const Border(
                      bottom: BorderSide(color: Color(0xff0080ff), width: 3)),
                  color: Colors.blueGrey.shade50),
              child: GestureDetector(
                onTap: () {
                  (widget.type == "생성") ? _openDatePicker(context) : () {};
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("날짜 선택"),
                    Text(
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                      style: const TextStyle(fontSize: 30),
                    ),
                  ],
                ),
              ),
            ),
            const EmptyBox(boxSize: 1),
            Container(
                width: double.maxFinite,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                    border: const Border(
                        bottom: BorderSide(color: Color(0xff0080ff), width: 3)),
                    color: Colors.blueGrey.shade50),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hourController,
                        decoration: const InputDecoration(
                          labelText: "시",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: minController,
                        decoration: const InputDecoration(
                          labelText: "분",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: secController,
                        decoration: const InputDecoration(
                          labelText: "초",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                )),
            const EmptyBox(boxSize: 1),
            TextField(
              controller: recordController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "count",
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0080ff),
                    width: 7,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0080ff),
                    width: 7,
                  ),
                ),
                filled: true,
                fillColor: Colors.blueGrey.shade50,
              ),
            ),
            const EmptyBox(boxSize: 1),
            GestureDetector(
              onTap: () async {
                (widget.type == "생성") ? await writePR() : await updatePR();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => WodDetailScreen(
                              wodName: widget.wodName,
                              wodId: widget.wodId,
                            ),
                        fullscreenDialog: true),
                    (route) => route.isFirst);
              },
              child: ButtonMold(
                  btnText: (widget.type == "생성") ? "등 록 하 기" : "수 정 하 기",
                  horizontalLength: 25,
                  verticalLength: 10,
                  buttonColor: true),
            ),
            const EmptyBox(boxSize: 10),
          ],
        ),
      ),
    );
  }
}
