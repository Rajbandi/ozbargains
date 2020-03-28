class Deal {
  String description;
  String link;
  String gravatar;
  Vote vote;
  List<String> tags;
  String category;
  String title;
  List<String> errors;
  Snapshot snapshot;
  Meta meta;
  String dealId;
  String content;

  Deal(
      {this.description,
      this.link,
      this.gravatar,
      this.vote,
      this.tags,
      this.category,
      this.title,
      this.errors,
      this.snapshot,
      this.meta,
      this.dealId,
      this.content});

  Deal.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    link = json['link'];
    gravatar = json['gravatar'];
    vote = json['vote'] != null ? new Vote.fromJson(json['vote']) : null;
    tags = json['tags'].cast<String>();
    category = json['category'];
    title = json['title'];
    if (json['errors'] != null) {
      errors = new List<String>();
      json['errors'].forEach((v) {
        errors.add(v);
      });
    }
    snapshot = json['snapshot'] != null
        ? new Snapshot.fromJson(json['snapshot'])
        : null;
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    dealId = json['dealId'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['link'] = this.link;
    data['gravatar'] = this.gravatar;
    if (this.vote != null) {
      data['vote'] = this.vote.toJson();
    }
    data['tags'] = this.tags;
    data['category'] = this.category;
    data['title'] = this.title;
    if (this.errors != null) {
      data['errors'] = this.errors.toList();
    }
    if (this.snapshot != null) {
      data['snapshot'] = this.snapshot.toJson();
    }
    if (this.meta != null) {
      data['meta'] = this.meta.toJson();
    }
    data['dealId'] = this.dealId;
    data['content'] = this.content;
    return data;
  }
}

class Vote {
  String down;
  String up;

  Vote({this.down, this.up});

  Vote.fromJson(Map<String, dynamic> json) {
    down = json['down'];
    up = json['up'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['down'] = this.down;
    data['up'] = this.up;
    return data;
  }
}

class Snapshot {
  String link;
  String title;
  String image;
  String goto;

  Snapshot({this.link, this.title, this.image, this.goto});

  Snapshot.fromJson(Map<String, dynamic> json) {
    link = json['link'];
    title = json['title'];
    image = json['image'];
    goto = json['goto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['link'] = this.link;
    data['title'] = this.title;
    data['image'] = this.image;
    data['goto'] = this.goto;
    return data;
  }
}

class Meta {
  int timestamp;
  String submitted;
  String image;
  String author;
  String date;
  List<dynamic> labels;
  String freebie;
  int expiredDate;
  int upcomingDate;

  Meta({this.timestamp, this.submitted, this.image, this.author, this.date, this.expiredDate, this.upcomingDate});

  Meta.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    submitted = json['submitted'];
    image = json['image'];
    author = json['author'];
    date = json['date'];
    expiredDate = json['expiredDate'];
    upcomingDate = json['upcomingDate'];
    labels = json['labels'];
    freebie = json['freebie'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['submitted'] = this.submitted;
    data['image'] = this.image;
    data['author'] = this.author;
    data['date'] = this.date;
    data['expiredDate'] = this.expiredDate;
    data['upcomingDate'] = this.upcomingDate;
    data['freebie'] = this.freebie;
    data['labels'] = this.labels;
    return data;
  }
}



class ApiResponse {
  bool success;
  String errorCode;
  String errorMessage;
}

class Deals extends ApiResponse{

List<Deal> deals;

Deals()
{
   deals = new List<Deal>();
}

Deals.fromJson(Map<String, dynamic> json) {
    success = json['success'];
     errorCode = json['errorCode'];
     errorMessage = json['errorMessage'];
    if(json['deals'] != null)
    {
      deals = new List<Deal>();
      json['deals'].forEach((d)=>{
        deals.add(Deal.fromJson(d))
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['success'] = success;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['deals'] = deals.map((d)=>{ d.toJson() }).toList();

    return data;
  }
}


