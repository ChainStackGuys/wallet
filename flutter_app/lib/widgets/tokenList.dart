import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class tokenList extends StatelessWidget {

  List arr = [1];
  tokenList({Key key, this.arr}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: arr.map((item) => walletCard(item)).toList()
    );
  }
}


Widget walletCard(item) {
  return new Card(
      color: Colors.white, //背景色
      child:  GestureDetector(
        child: new Container(
            padding: const EdgeInsets.all(28.0),
            child: new Row(
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: new BoxDecoration(
                    border: new Border.all(width: 2.0, color: Colors.black26),
                    borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                  ),
                  child: new Image.asset(
                    'images/icon.png',
                    height: 40.0,
                    width: 40.0,
                    fit: BoxFit.cover,
                  ),
                ),
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text(
                        item['name'],
                        style: new TextStyle(fontSize: 32.0, color: Colors.black),
                      ),
                      new Text(item['address']),
                    ],
                  ),
                ),
                new Container(
                    child: new Column(
                      children: <Widget>[
                        new Text(
                          '14000.00',
                          style: new TextStyle(fontSize: 16.0,
                              color: Color.fromARGB(100, 6, 147, 193)),
                        ),
                        new Text('14000.00'),
                      ],
                    )

                )
              ],
            )
        ),
        onTap: (){
          print(item);
          print(item['address']);
          saveToken(item);

        },
      )
  );
}

// 把点击的token对象保存进入缓存，在首页去显示
// 这里点击后应该给上层广播一个事件
void saveToken(token) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List tokenArr = [token];
  print(tokenArr);
  prefs.setStringList('tokens', tokenArr);
  List arr = prefs.getStringList('tokens');
  print(arr);
}