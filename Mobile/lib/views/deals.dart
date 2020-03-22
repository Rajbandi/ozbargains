import 'package:flutter/material.dart';
import 'package:ozbargain/api/dealapi.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/deal.dart';

class DealsView extends StatefulWidget {
  DealsView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DealsViewState createState() => _DealsViewState();
}

class _DealsViewState extends State<DealsView> {
  List<Deal> deals = new List<Deal>();
@override
  void initState() {
    super.initState();
    _onRefresh();
  }
  
  @override
  Widget build(BuildContext context) {
    
    var model = new AppDataModel();
    var listView = ListView.builder(
        
        itemBuilder: (BuildContext context, int index) {
          var deal = deals[index];
          return InkWell(onTap: () {

            _openDeal(deal);

          }, child: Card(child: _getDeal(deal)));
        },
        itemCount: deals == null ? 0 : deals.length,
        scrollDirection: Axis.vertical);

    return RefreshIndicator(
      child: listView,
      
      onRefresh: () => _onRefresh(),
    );
  }

  _openDeal(Deal d)
  {
       var view = new DealView(title: "Deal", deal: d);
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => view));
  }
  ListTile _getDeal(Deal d) {
    return new ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
      dense: true,
      title: Text(
        d.title,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      subtitle: Padding(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  d.meta.author,
                  
                ),
                Text(
                  d.meta.date,
                  
                )
              ],
            ),
          
            InkWell(
                onTap: () => {
                      AppHelper.openUrl(context, d.title, d.snapshot.goto)
                    },
                child: Icon(
                  Icons.open_in_browser,
                  color: Theme.of(context).accentColor,
                )),
          ]),
          padding: EdgeInsets.only(top: 2.0)),
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
      this.deals = list.skipWhile((value) => value.errors != null && value.errors.length>0).toList();
    });
    return null;
  }
}
