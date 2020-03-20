import "package:ozbargain/api/dealapi.dart";
import 'package:ozbargain/models/deal.dart';

class AppDataModel {
  DealsApi _api;

  AppDataModel() {
    _api = new DealsApi();
  }

  Future<List<Deal>> getDeals() async {

    var deals = new List<Deal>();

    var data = await _api.getDeals();
    if(data.success)
    {
        if(data.deals != null && data.deals.length>0)
        {
          data.deals.forEach((d)=>{
            deals.add(d)
          });
        }
    }

    return deals;
  }
}
