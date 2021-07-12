import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        // debugShowCheckedModeBanner: false,
        title: 'Github Profiles Demo',
        themeMode: ThemeMode.system,
        theme: BCIUtils.lightTheme,
        darkTheme: BCIUtils.darkTheme,
        home: GithubProfilesApp(),
      );
    });
  }
}

class GithubProfilesApp extends StatefulWidget {
  @override
  _GithubProfilesAppState createState() => _GithubProfilesAppState();
}

class _GithubProfilesAppState extends State<GithubProfilesApp> {
  Future<GithubUser>? githubUser;
  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Github Profiles App',
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.h),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                  hintText: 'Search username',
                  hintStyle: Theme.of(context).textTheme.bodyText1),
            ),
            SizedBox(height: 3.h),
            FutureBuilder<GithubUser>(
              future: githubUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError)
                  return Center(
                    child: Text(
                      'User not found',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );

                if (snapshot.data == null) {
                  return Center(
                    child: Text(
                      'Find a user',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  );
                }

                final user = snapshot.data;
                return Column(children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withGreen(125),
                    backgroundImage: NetworkImage(
                      user!.avatarUrl.toString(),
                    ),
                    radius: 7.h,
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    user.login ?? 'User not Exist',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    user.location ?? '',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Repositories',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(
                            user.publicRepos.toString() == 'null'
                                ? '0'
                                : user.publicRepos.toString(),
                            style: Theme.of(context).textTheme.subtitle1,
                          )
                        ],
                      ),
                      SizedBox(
                        width: 1.w,
                      ),
                      Column(
                        children: [
                          Text(
                            'Following',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(
                            // user.following.toString(),
                            user.following.toString() == 'null'
                                ? '0'
                                : user.publicRepos.toString(),
                            style: Theme.of(context).textTheme.subtitle1,
                          )
                        ],
                      ),
                      SizedBox(
                        width: 1.w,
                      ),
                      Column(
                        children: [
                          Text(
                            'Followers',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(
                            // user.followers.toString(),
                            user.followers.toString() == 'null'
                                ? '0'
                                : user.publicRepos.toString(),
                            style: Theme.of(context).textTheme.subtitle1,
                          )
                        ],
                      ),
                    ],
                  )
                ]);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            githubUser = fetchGithubUser(searchController.text);
          });
        },
        child: Icon(
          Icons.search,
          size: 15.sp,
        ),
      ),
    );
  }
}

Future<GithubUser> fetchGithubUser(String user) async {
  var client = http.Client();
//  String  url = ;
  var response =
      await client.get(Uri.parse("https://api.github.com/users/$user"));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return GithubUser.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print('Failed to load album');
  }
  return GithubUser();
}

class BCIUtils {
  static Widget iconText(BuildContext context, Icon icon, Text text) {
    return Row(
      children: [
        icon,
        SizedBox(width: 10.w),
        text,
      ],
    );
  }

  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.deepPurple,
    accentColor: Colors.amber,
    cardColor: Colors.transparent,
    textTheme: TextTheme(
      headline5: TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
      subtitle1: TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.bold,
        fontSize: 14.sp,
      ),
      bodyText1: TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.amber,
      size: 18.sp,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    accentColor: Colors.white,
    cardColor: Colors.transparent,
    textTheme: TextTheme(
      headline5: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
      subtitle1: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14.sp,
      ),
      bodyText1: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 18.sp,
    ),
  );
}

GithubUser githubUserFromJson(String str) =>
    GithubUser.fromJson(json.decode(str));

String githubUserToJson(GithubUser data) => json.encode(data.toJson());

class GithubUser {
  GithubUser({
    this.login,
    this.id,
    this.nodeId,
    this.avatarUrl,
    this.gravatarId,
    this.url,
    this.htmlUrl,
    this.followersUrl,
    this.followingUrl,
    this.gistsUrl,
    this.starredUrl,
    this.subscriptionsUrl,
    this.organizationsUrl,
    this.reposUrl,
    this.eventsUrl,
    this.receivedEventsUrl,
    this.type,
    this.siteAdmin,
    this.name,
    this.company,
    this.blog,
    this.location,
    this.email,
    this.hireable,
    this.bio,
    this.twitterUsername,
    this.publicRepos,
    this.publicGists,
    this.followers,
    this.following,
    this.createdAt,
    this.updatedAt,
  });

  String? login;
  int? id;
  String? nodeId;
  String? avatarUrl;
  String? gravatarId;
  String? url;
  String? htmlUrl;
  String? followersUrl;
  String? followingUrl;
  String? gistsUrl;
  String? starredUrl;
  String? subscriptionsUrl;
  String? organizationsUrl;
  String? reposUrl;
  String? eventsUrl;
  String? receivedEventsUrl;
  String? type;
  bool? siteAdmin;
  String? name;
  String? company;
  String? blog;
  String? location;
  String? email;
  bool? hireable;
  String? bio;
  String? twitterUsername;
  int? publicRepos;
  int? publicGists;
  int? followers;
  int? following;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory GithubUser.fromJson(Map<String, dynamic> json) => GithubUser(
        login: json["login"],
        id: json["id"],
        nodeId: json["node_id"],
        avatarUrl: json["avatar_url"],
        gravatarId: json["gravatar_id"],
        url: json["url"],
        htmlUrl: json["html_url"],
        followersUrl: json["followers_url"],
        followingUrl: json["following_url"],
        gistsUrl: json["gists_url"],
        starredUrl: json["starred_url"],
        subscriptionsUrl: json["subscriptions_url"],
        organizationsUrl: json["organizations_url"],
        reposUrl: json["repos_url"],
        eventsUrl: json["events_url"],
        receivedEventsUrl: json["received_events_url"],
        type: json["type"],
        siteAdmin: json["site_admin"],
        name: json["name"],
        company: json["company"],
        blog: json["blog"],
        location: json["location"],
        email: json["email"],
        hireable: json["hireable"],
        bio: json["bio"],
        twitterUsername: json["twitter_username"],
        publicRepos: json["public_repos"],
        publicGists: json["public_gists"],
        followers: json["followers"],
        following: json["following"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "login": login,
        "id": id,
        "node_id": nodeId,
        "avatar_url": avatarUrl,
        "gravatar_id": gravatarId,
        "url": url,
        "html_url": htmlUrl,
        "followers_url": followersUrl,
        "following_url": followingUrl,
        "gists_url": gistsUrl,
        "starred_url": starredUrl,
        "subscriptions_url": subscriptionsUrl,
        "organizations_url": organizationsUrl,
        "repos_url": reposUrl,
        "events_url": eventsUrl,
        "received_events_url": receivedEventsUrl,
        "type": type,
        "site_admin": siteAdmin,
        "name": name,
        "company": company,
        "blog": blog,
        "location": location,
        "email": email,
        "hireable": hireable,
        "bio": bio,
        "twitter_username": twitterUsername,
        "public_repos": publicRepos,
        "public_gists": publicGists,
        "followers": followers,
        "following": following,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
