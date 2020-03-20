import 'package:flutter/material.dart';
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

   
    var listView = ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          var deal = deals[index];
          return InkWell(
            onTap: (){

            },
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex:3,
                    child:Wrap(
                      direction: Axis.horizontal,
                      spacing: 1,
                      children: <Widget>[
                        Image.network(deal.gravatar),
                        Text(deal.title),
                        Image.network(deal.snapshot.image)
                      ],)
                  )
                ],
              )
            )
          );
        },
        separatorBuilder: (context, length) => Divider(height: 1),
        itemCount: deals == null ? 0 : deals.length,
        scrollDirection: Axis.vertical);

        return RefreshIndicator(
          child: listView,
          onRefresh: ()=> _onRefresh(),);
  }

   Future<Null> _onRefresh() async {
   
   var list = await AppDataModel().getDeals();  
   setState(() {
    this.deals = list;
   });
   
    return null;
  }
}
