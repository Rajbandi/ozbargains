import 'dart:convert';

import "package:ozbargain/api/dealapi.dart";
import 'package:ozbargain/api/dealsocket.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/filterrule.dart';
import 'package:ozbargain/models/appsettings.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/models/dealfiltertype.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataModel {
  DealsApi _api;
  String _url = "https://ozbargains.omkaars.dev";
  static final AppDataModel _model = new AppDataModel._internal();

  DealSocket _socket;
  factory AppDataModel() {
    return _model;
  }

  AppDataModel._internal() {
    _api = DealsApi(_url);

    _socket = DealSocket(_url);

    _socket.controller.stream.listen((socketDeals) {
      print(
          '*********** received a message from controller ${socketDeals.length}');
    }, onError: (error, StackTrace stackTrace) {
      print('Error received from controller $error $stackTrace');
    }, onDone: () {
      print("controller is closed");
    });

    _socket.open();
  }

  SharedPreferences get preferences => AppHelper.preferences;

  AppSettings _settings;

  AppSettings get settings {
    loadSettings();
    return _settings;
  }

  updateSettings() {
    print("******** updating settings ********");
    print("${settings.toJson()}");
    preferences.setString("settings", jsonEncode(settings.toJson()));
  
  }

  refreshSettings() {
    loadSettings(refresh: true);
  }

  loadSettings({bool refresh = false}) {
    if (_settings == null || refresh) {
      print("Loading settings");
      var jsonString = preferences.getString("settings");
      try {
        _settings = AppSettings.fromJson(jsonDecode(jsonString));
      } catch (e) {
        _settings = AppSettings();
        print(e);
      }

      print("Settings $_settings");
    }
  }

  changeOpenBrowser(bool openBrowser) {
    settings.openBrowser = openBrowser;
    updateSettings();
  }

  void refreshMyDeals() {
    myDeals.clear();
    try {
      var alertFilters = settings.alertFilters;
      if (alertFilters.length > 0) {
        for (Deal deal in deals) {
          var alertNames = List<String>();

          for (DealFilter alertFilter in alertFilters) {
            var isMatch = alertFilter.parse(deal);
            if (isMatch) {
              alertNames.add(alertFilter.name);
            }
          }
          if(alertNames.length>0)
          {
            deal.meta.alertName = alertNames.join(",");
            myDeals.add(deal);
          }
        }

         myDeals.sort((d1, d2) => d2.meta.timestamp.compareTo(d1.meta.timestamp));
      }
     
    } catch (e) {
      print(e);
    }
  }

  void refreshDeals(List<Deal> d) {
    print("refreshing deals ${d.length}");
    if (this.deals != null && d != null && d.length > 0) {
      var newDeals = this.deals.map((deal) {
        var d2 =
            d.firstWhere((d1) => d1.dealId == deal.dealId, orElse: () => null);
        if (d2 != null) {
          return d2;
        } else {
          return deal;
        }
      }).toList();
      print("Refreshing new deals ${newDeals.length}");
      if (newDeals.length > 0) {
        this.deals.clear();
        this.deals.addAll(newDeals);
      }

      print("Refreshed successfully");
    }
  }

  List<Deal> deals = new List<Deal>();
  List<Deal> myDeals = new List<Deal>();
  List<FilterRule> rules = new List<FilterRule>();

  Future<List<Deal>> getDeals(DealsQuery q) async {
    if (this.deals != null)
      this.deals.clear();
    else
      this.deals = new List<Deal>();

    var data = await _api.getDeals(q);
    if (data.success) {
      if (data.deals != null && data.deals.length > 0) {
        data.deals.forEach((d) =>
            {if (d.errors == null || d.errors.length <= 0) this.deals.add(d)});
      }
    }
    return this.deals;
  }

  List<String> getCategories() {
    List<String> categories = new List<String>();
    if (this.deals != null) {
      var lists = new List<List<String>>();
      this.deals.forEach((deal) {
        lists.add(deal.tags);
      });
      categories.addAll(lists.expand((tags) => tags).toList().toSet().toList());
    }
    return categories;
  }

  Future<List<Deal>> getFilteredDeals(DealFilterType filter,
      {bool refresh = false, String search = ""}) async {
    List<Deal> filteredDeals = new List<Deal>();
    if (this.deals == null || this.deals.length == 0 || refresh) {
      print("sending query ******** ");
      var serverDeals = await getDeals(DealsQuery(sort: "meta.timestamp,desc"));
      this.deals = serverDeals
          .skipWhile((value) => value.errors != null && value.errors.length > 0)
          .toList();
    }

    print("Total deals found ${this.deals.length}");
    if (filter == DealFilterType.Today) {
      var now = DateTime.now().add(Duration(hours: -24));
//          var dateToday = new DateTime(now.year, now.month, now.day);
      var dayStart = AppHelper.currentTimeInSeconds(now);
      print("Search for today $dayStart");
      this
          .deals
          .where((deal) => deal.meta.timestamp > dayStart)
          .toList()
          .forEach((d) {
        filteredDeals.add(d);
      });

      filteredDeals
          .sort((d1, d2) => d2.meta.timestamp.compareTo(d1.meta.timestamp));

      print("Todays deals ${filteredDeals.length}");
    } else if (filter == DealFilterType.Popular) {
      var now = AppHelper.currentTimeInSeconds(DateTime.now());
      this.deals.toList().forEach((d) {
        if (d.meta.expiredDate == null ||
            d.meta.expiredDate == 0 ||
            d.meta.expiredDate > now) filteredDeals.add(d);
      });
      filteredDeals.sort((d1, d2) {
        return int.tryParse(d2.vote.up).compareTo(int.tryParse(d1.vote.up));
      });
    } else if (filter == DealFilterType.Freebies) {
      this.deals.toList().forEach((d) {
        if (d.meta.freebie != null && d.meta.freebie == "Freebie") {
          filteredDeals.add(d);
        }
      });
      filteredDeals
          .sort((d1, d2) => d2.meta.timestamp.compareTo(d1.meta.timestamp));
    } else if (filter == DealFilterType.Expiring) {
      var now = AppHelper.currentTimeInSeconds(DateTime.now());

      this.deals.toList().forEach((d) {
        if (d.meta.expiredDate != null && d.meta.expiredDate > 0) {
          if (d.meta.expiredDate > now) {
            filteredDeals.add(d);
          }
        }
      });
      filteredDeals
          .sort((d1, d2) => d1.meta.expiredDate.compareTo(d2.meta.expiredDate));
    } else if (filter == DealFilterType.Upcoming) {
      var now = AppHelper.currentTimeInSeconds(DateTime.now());

      this.deals.toList().forEach((d) {
        if (d.meta.upcomingDate != null && d.meta.upcomingDate > 0) {
          if (d.meta.upcomingDate > now) {
            filteredDeals.add(d);
          }
        }
      });
      filteredDeals.sort(
          (d1, d2) => d1.meta.upcomingDate.compareTo(d2.meta.upcomingDate));
    }
    if (filter == DealFilterType.LongRunning) {
      var lastMonth = AppHelper.currentTimeInSeconds(
          DateTime.now().add(new Duration(days: -30)));
      var now = AppHelper.currentTimeInSeconds(DateTime.now());

      this.deals.toList().forEach((d) {
        if (d.meta.timestamp != null && d.meta.timestamp > 0) {
          bool ok = false;
          if (d.meta.timestamp > lastMonth) {
            if (d.meta.expiredDate != null && d.meta.expiredDate > 0) {
              if (d.meta.expiredDate > now) {
                ok = true;
              }
            } else {
              ok = true;
            }

            if (ok) {
              if (d.meta.upcomingDate != null && d.meta.upcomingDate > 0) {
                if (d.meta.upcomingDate < now) {
                  ok = true;
                }
              } else {
                ok = true;
              }
            }
            if (ok) {
              filteredDeals.add(d);
            }
          }
        }
      });
      filteredDeals
          .sort((d1, d2) => d1.meta.timestamp.compareTo(d2.meta.timestamp));
    } else if (filter == DealFilterType.All) {
      this.deals.forEach((deal) {
        filteredDeals.add(deal);
      });
    }

    if (search != null && search.length > 0) {
      filteredDeals = filteredDeals
          .where((deal) =>
              deal.title.contains(search) || deal.description.contains(search))
          .toList();
    }

    return filteredDeals.toList();
  }
}
