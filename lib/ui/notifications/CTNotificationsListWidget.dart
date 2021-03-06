import 'package:corona_trace/ui/notifications/CTLoader.dart';
import 'package:corona_trace/ui/notifications/CTNotificationDetailCard.dart';
import 'package:corona_trace/ui/notifications/CTNotificationItem.dart';
import 'package:corona_trace/ui/notifications/CTNotificationMapDetail.dart';
import 'package:corona_trace/ui/notifications/blocs/CTNotificationsBloc.dart';
import 'package:corona_trace/ui/notifications/blocs/NotificationsBlocEvent.dart';
import 'package:corona_trace/ui/notifications/blocs/NotificationsBlocState.dart';
import 'package:corona_trace/utils/AppLocalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CTNotificationsListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CTNotificationsBloc>(
      create: (context) => CTNotificationsBloc(),
      child: _NotificationsBlocListWidget(),
    );
  }
}

class _NotificationsBlocListWidget extends StatefulWidget {
  @override
  __NotificationsBlocListWidgetState createState() =>
      __NotificationsBlocListWidgetState();
}

class __NotificationsBlocListWidgetState
    extends State<_NotificationsBlocListWidget> {
  ScrollController _controller;
  CTNotificationsBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<CTNotificationsBloc>(context)
      ..add(NotificationsBloEvent.fetch);

    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      _bloc.add(NotificationsBloEvent.fetchMore);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CTNotificationsBloc, NotificationsBlocState>(
      builder: (context, state) => _content(state),
    );
  }

  Widget _content(NotificationsBlocState state) {
    if (state.isInitialLoading()) {
      return Center(
        child: CTLoader(50, 50),
      );
    }

    if (state.suggestions.isEmpty) {
      return getNoNotificationsWidget();
    }

    return SingleChildScrollView(
      controller: _controller,
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemBuilder: (context, index) {
          var item = state.suggestions[index];
          return InkWell(
            child: CTNotificationItem(crossedPaths: true, notification: item),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return CTNotificationMapDetail(
                    crossedPaths: true, notification: item);
              }));
            },
          );
        },
        itemCount: state.suggestions.length,
      ),
    );
  }

  Widget getNoNotificationsWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  child: Text(
                    AppLocalization.text("notifications.about.your.location"),
                    style: TextStyle(fontSize: 15),
                  ),
                  padding: EdgeInsets.only(left: 20, right: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Divider(
                      color: Colors.grey,
                    ),
                    Padding(
                      child: Text(
                        AppLocalization.text("notifications.resources"),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    ),
                    cdcDocumentation(emptyLeadingSpace: false),
                    Divider(
                      color: Colors.grey,
                    ),
                    cdcTesting(emptyLeadingSpace: false),
                    Divider(
                      color: Colors.grey,
                    ),
                  ],
                )
              ],
            ),
            constraints: constraints.copyWith(
              minHeight: constraints.maxHeight,
              maxHeight: double.infinity,
            ),
          ),
        );
      },
    );
  }
}
