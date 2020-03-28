import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/deal.dart';

class DealCommon {
  BuildContext context;
  ThemeData currentTheme;
  Color primaryColor, accentColor;
  GlobalKey<ScaffoldState> scaffoldKey;

  TextStyle nonTitleStyle;

  TextStyle primaryTitle;

  TextStyle highlightTitle;

  DealCommon(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    this.context = context;
    this.scaffoldKey = scaffoldKey;
    currentTheme = Theme.of(context);
    primaryColor = currentTheme.primaryColor;
    accentColor = currentTheme.accentColor;

    nonTitleStyle =
        currentTheme.textTheme.caption.merge(new TextStyle(color: Colors.grey));

    primaryTitle = currentTheme.primaryTextTheme.bodyText1
        .copyWith(color: currentTheme.primaryColor);
    highlightTitle = currentTheme.accentTextTheme.bodyText1
        .copyWith(color: currentTheme.accentColor);
  }

  Widget getNonTitle(t) {
    return Text(t ?? "", style: nonTitleStyle);
  }

  Widget getMeta(Deal d, {bool authorImage = false, bool gotoImage = false}) {
    List<Widget> metaWidgets = new List<Widget>();
    metaWidgets.add(getNonTitle(d.meta.author));

    var dealDate = AppHelper.getDateFromUnix(d.meta.timestamp ?? 0);
    var dealFormat = AppHelper.getLocalDateTime(dealDate);
    metaWidgets.add(getNonTitle(dealFormat));
    if (d.meta.upcomingDate > 0) {
      var upcomDate = AppHelper.getDateFromUnix(d.meta.upcomingDate ?? 0);
      var upcomDiff = DateTime.now().difference(upcomDate);
      var upcomDays = upcomDiff.inDays;

      var upcomPeriod = "${upcomDays.abs()} days";
      if (upcomDays == 0) {
        var hours = upcomDiff.inHours;
        upcomPeriod = "${hours.abs()} hours";
        if (hours == 0) {
          upcomPeriod = "${upcomDiff.inMinutes.abs()} minutes";
        }
      }
      var upcomFormat = AppHelper.getLocalDateTime(upcomDate);
      var upcomText = "";
      if (upcomDiff.isNegative) {
        upcomText = "Starts on $upcomFormat (in $upcomPeriod)";
      } else {
        upcomText = "From $upcomFormat ($upcomDays days ago)";
      }
      metaWidgets.add(getNonTitle(upcomText));
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: getMetaAuthor(d, authorImage)),
          Expanded(
              flex: 5,
              child: Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: metaWidgets))),
          getSnapshotGoto(d, gotoImage)
        ]);
  }

  Widget getMetaAuthor(Deal d, bool authorImage) {
    List<Widget> widgets = new List<Widget>();
    if (authorImage) {
      widgets.add(Container(
        padding: EdgeInsets.only(bottom: 10),
        child: getNetworkImage(d.meta.image, 50, 50),
      ));
    }
    widgets.add(
      Container(child: getVotes(d)),
    );
    return Column(
        mainAxisAlignment: MainAxisAlignment.start, children: widgets);
  }

  Widget getSnapshotGoto(Deal d, bool gotoImage) {
    List<Widget> widgets = new List<Widget>();
    widgets.add(getCopyLinks(d));
    if (gotoImage) {
      widgets.add(InkWell(
        child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  getNetworkImage(d.snapshot.image, 75, 75),
                  Text(
                    "Goto",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ])),
        onTap: () => {AppHelper.openUrl(context, "", d.snapshot.goto)},
      ));
    }
    return Column(children: widgets);
  }

  Widget getDealRow(child) {
    return Container(padding: EdgeInsets.only(top: 3, bottom: 3), child: child);
  }

  Widget getNetworkImage(String url, double width, double height) {
    Widget image;
    try {
      if (url != null && url.length > 0)
        image = Image.network(
          url,
          width: width,
          height: height,
        );
    } catch (e) {}

    if (image == null) {
      image = Text("No Image");
    }
    return image;
  }

  Widget getTagsRow(List<String> tags) {
    var row = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.spaceBetween,
      direction: Axis.horizontal,
      children: <Widget>[],
    );

    tags.forEach((element) {
      var tagStyle = nonTitleStyle.copyWith(color: currentTheme.disabledColor);
      row.children.add(Container(
          padding: EdgeInsets.all(3),
          margin: EdgeInsets.only(right: 2, top: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: currentTheme.dividerColor),
          child: Text(
            element,
            style: tagStyle,
          )));
    });

    return row;
  }

  Widget getTitle(Deal d) {
    List<InlineSpan> spans = new List<InlineSpan>();
    if (d.meta != null) {
      if (d.meta.labels != null && d.meta.labels.length > 0) {
        d.meta.labels.forEach((label) {
          var lbl = "";
          if (label != null && label is String) {
            lbl = (label as String).toUpperCase();
          }

          spans.add(WidgetSpan(
              child: Container(
            child:
                Text(lbl, style: highlightTitle.copyWith(color: Colors.white)),
            padding: EdgeInsets.only(right: 2, left: 2),
            margin: EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0), color: Colors.red),
          )));
        });
      }
    }
    spans.add(TextSpan(text: d.title, style: currentTheme.textTheme.headline6));

    return RichText(text: TextSpan(children: spans));
  }

  Widget getCopyLinks(Deal d) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(
          child: Container(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                FontAwesomeIcons.copy,
                color: primaryColor,
              )),
          onTap: () => {copyToClipboard("Copied OzBargains Url ", d.link)},
        ),
        InkWell(
          child: Container(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.content_copy,
                color: accentColor,
              )),
          onTap: () =>
              {copyToClipboard("Copied external deal link ", d.snapshot.goto)},
        ),
      ],
    );
  }

  Widget getVotes(Deal d) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        getVote(
            (d.vote.up ?? "0"), FontAwesomeIcons.thumbsUp, Color(0x88009900)),
        getVote((d.vote.down ?? "0"), FontAwesomeIcons.thumbsDown,
            Color(0x88ff0000))
      ],
    );
  }

  Widget getVote(v, IconData icon, Color c) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(3),
        margin: EdgeInsets.only(bottom: 1),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                icon,
                size: 12,
              ),
              Text(v,
                  style: currentTheme.textTheme.bodyText1
                      .copyWith(color: Colors.white))
            ]),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(2.0),
        ));
  }

  showSnackMessage(message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  copyToClipboard(msg, text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackMessage("$msg \n$text");
  }

 
}
