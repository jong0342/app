import 'package:flutter/material.dart';
import 'package:jeonju_quiz_app/model/api_adapter.dart';
import 'package:jeonju_quiz_app/model/model_quiz.dart';
import 'package:jeonju_quiz_app/screen/screen_quiz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Stateful Widget으로 HomeScreen 클래스를 만든다.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/* _HomeScreenState를 만든다

Widget build 함수를 선언해준다.

기기 크기와 상관없는 반응형 UI로 만들기 위해 MediaQuery를 사용한다.

MediaQuery : 반응형 웹을 구현하는 CSS technique이며, 특정 조건에서
어떤 CSS를 적용하라는 규칙을 줄 수 있다.

MediaQury로 Size 타입의 변수를 만들어준다.
 Size screenSize = MediaQuery.of(context).size;
    double width = (넓이 설정)screenSize.width;
    double height = (높이 설정)screenSize.height;
    이 변수는 너비와 높이를 알아낼 수 있다.

MediaQuery를 사용함으로 이후 높이, 패딩, 폰트 사이즈에 대한 상수 X

width와 height에 곱하기를 한 값을 활용한다.

SafeArea에 Scaffold를 넣는 형태로 화면을 구성하여 return 한다.

SafeArea는 기기의 상단 노티 바 부분, 하단 영역을 침범하지 
않는 안전한 영역을 잡아주는 위젯

leading에는 빈 컨테이너를 넣은 이유는 

body에 Column을 넣고 axisAlignment를 설정해준다
axis : 중심선 | Crossaxis : 횡축 | mainaxis : 주축
MainAxisAlignment, CrossAxisAlignment 속성을 사용하여 행 또는 열에서
child widget을 사용하는 방법 | https://beomseok95.tistory.com/310

children에 Image.asset을 넣고 Images파일안에 넣어놓은 quiz.jpeg을
넣어주고 width를 width * 0.8로 설정해준다.
    */

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  List<Quiz> quizs = [];
  bool isLoading = false;

  _fetchQuizs() async {
    setState(() {
      isLoading = true;
    });
    final response = await http
        .get(Uri.parse('https://make-quiz-test.herokuapp.com/quiz/3/'));
    if (response.statusCode == 200) {
      setState(() {
        quizs = parseQuizs(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      throw Exception('failed to load data');
    }
  }
  // List<Quiz> quizs = [
  //   Quiz.fromMap({
  //     'title': 'test',
  //     'candidates': ['a', 'b', 'c', 'd'],
  //     'answer': 0
  //   }),
  //   Quiz.fromMap({
  //     'title': 'test',
  //     'candidates': ['a', 'b', 'c', 'd'],
  //     'answer': 0
  //   }),
  //   Quiz.fromMap({
  //     'title': 'test',
  //     'candidates': ['a', 'b', 'c', 'd'],
  //     'answer': 0
  //   }),
  // ];

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: Text('JeonJu Quiz App'),
          backgroundColor: Colors.black,
          leading: Container(),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                'images/quiz.jpeg',
                width: width * 0.6,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(
                width * 0.024,
              ),
            ),
            Text(
              'Quiz 앱',
              style: TextStyle(
                fontSize: width * 0.065,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '퀴즈를 풀기 전 안내사항\n꼼꼼히 읽고 퀴즈를 풀어보세요.',
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(width * 0.04),
            ),
            _buildStep(width, '1. 랜덤으로 나오는 퀴즈를 풀어보세요.'),
            _buildStep(width, '2. 전주 경기전에 대한 퀴즈입니다.'),
            _buildStep(width, '3. 문제를 잘 읽고 정답을 고른 뒤\n다음 문제 버튼을 눌러주세요.'),
            Padding(
              padding: EdgeInsets.all(width * 0.048),
            ),
            Container(
              padding: EdgeInsets.only(bottom: width * 0.036),
              child: Center(
                child: ButtonTheme(
                  minWidth: width * 0.8,
                  height: height * 0.05,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RaisedButton(
                    child: Text(
                      '지금 문제 풀기',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.black,
                    onPressed: () {
                      _scaffoldkey.currentState.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: <Widget>[
                              CircularProgressIndicator(),
                              Padding(
                                padding: EdgeInsets.only(left: width * 0.036),
                              ),
                              Text('로딩 중....'),
                            ],
                          ),
                        ),
                      );
                      _fetchQuizs().whenComplete(() {
                        return Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              quizs: quizs,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(double width, String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        width * 0.048,
        width * 0.024,
        width * 0.048,
        width * 0.024,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.check_box,
            size: width * 0.04,
          ),
          Padding(
            padding: EdgeInsets.only(right: width * 0.024),
          ),
          Text(title),
        ],
      ),
    );
  }

  padding({EdgeInsets padding}) {}
}
