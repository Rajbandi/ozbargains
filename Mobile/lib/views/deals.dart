import 'package:flutter/material.dart';
import 'package:ozbargain/api/dealapi.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';

class DealsView extends StatefulWidget {
  DealsView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DealsViewState createState() => _DealsViewState();
}

class _DealsViewState extends State<DealsView> {
  List<Deal> deals = new List<Deal>();

  @override
  Widget build(BuildContext context) {
    var model = new AppDataModel();

    var listView = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          var deal = deals[index];
          return InkWell(
              onTap: () {},
              child: _getDeal(deal)
              );
        },
        
        itemCount: deals == null ? 0 : deals.length,
        scrollDirection: Axis.vertical);

    return RefreshIndicator(
      child: listView,
      onRefresh: () => _onRefresh(),
    );
  }

  ListTile _getDeal(Deal d)
  {
    return new ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal:20.0, vertical:10.0),
      leading: Container(
        padding: EdgeInsets.only(right:12.0),
        decoration: new BoxDecoration(
          border: new Border(
            right: new BorderSide(width: 1.0, color: Colors.white24),
          )

        ),
        child: Icon(Icons.autorenew,color:Colors.white),
      ),
      title: Text(d.title),
      subtitle: Row(
        children: <Widget>[
          Text(d.content)
        ],
      ),
      trailing: Icon(Icons.keyboard_arrow_right,size:30.0),
    );
  }

  Future<Null> _onRefresh() async {
    var now = DateTime.now();
    var dateToday = new DateTime(now.year, now.month, now.day);
    var dayStart = AppHelper.currentTimeInSeconds(dateToday);

    var q = new DealsQuery(
        dateFrom: dayStart.toString(),
        limit: "10",
        sort: "meta.timestamp,desc");

    var list = await AppDataModel().getDeals(q);
    setState(() {
      this.deals = list;
    });

    return null;
  }
}
