import "package:ozbargain/api/dealapi.dart";
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/models/dealfilter.dart';

class AppDataModel {
  DealsApi _api;

  static final AppDataModel _model = new AppDataModel._internal();

  factory AppDataModel() {
    return _model;
  }

  AppDataModel._internal() {
    _api = new DealsApi();
  }

  List<Deal> deals = new List<Deal>();
  Future<List<Deal>> getDeals(DealsQuery q) async {

    if(this.deals != null)
      this.deals.clear();
    else
      this.deals = new List<Deal>();

    var data = await _api.getDeals(q);
    if(data.success)
    {
        if(data.deals != null && data.deals.length>0)
        {
          data.deals.forEach((d)=>{
                if(d.errors == null || d.errors.length<=0)
                  this.deals.add(d)
          });
        }
    }
    return this.deals;
  }

  Future<List<Deal>> getFilteredDeals(DealFilter filter, {bool refresh=false}) async {
      List<Deal> filteredDeals = new List<Deal>();
      if(this.deals==null || this.deals.length == 0 || refresh)
      {
          print("sending query ******** ");
          this.deals = await getDeals(DealsQuery(sort: "meta.timestamp,desc"));
      }
      print("Total deals found ${this.deals.length}");
      if(filter == DealFilter.Today)
      {
          var now = DateTime.now();
          var dateToday = new DateTime(now.year, now.month, now.day);
          var dayStart = AppHelper.currentTimeInSeconds(dateToday);
          print("Search for today $dayStart");
          this.deals.where((deal) => deal.meta.timestamp>dayStart).toList()
          .forEach((d) { 
            filteredDeals.add(d);
          });

          filteredDeals.sort((d1,d2)=> d2.meta.timestamp.compareTo(d1.meta.timestamp));

          print("Todays deals ${filteredDeals.length}");
      } 
      else
      if(filter == DealFilter.Popular)
      {
        this.deals.toList()
          .forEach((d) { 
            filteredDeals.add(d);
          });
        filteredDeals.sort((d1,d2)=> d2.vote.up.compareTo(d1.vote.up));
      }
      else
      if(filter == DealFilter.Expiring)
      {

      }
      else
      if(filter == DealFilter.All)
      {
          this.deals.forEach((deal) {
              filteredDeals.add(deal);
          });
      } 

      return filteredDeals.toList();
  }
}
