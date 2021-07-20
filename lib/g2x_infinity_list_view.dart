library g2x_infinity_list_view;

import 'package:flutter/material.dart';

class G2xInfinityListViewController extends ValueNotifier<List<Widget>>{
  G2xInfinityListViewController({List<Widget> value = const <Widget>[]}) : super(value);
  void updateList(List<Widget> newValue){
    value = List.from(newValue);
  }
}

class G2xInfinityListView extends StatefulWidget {
  final G2xInfinityListViewController controller;
  final Function() onRefresh;
  final Function() loadMore;
  final Widget? emptyWidget;
  final bool callOnRefreshOnInit;
  const G2xInfinityListView({ Key? key, required this.controller, required this.onRefresh, required this.loadMore, this.emptyWidget, this.callOnRefreshOnInit = true }) : super(key: key);
  @override
  _G2xInfinityListViewState createState() => _G2xInfinityListViewState();
}

class _G2xInfinityListViewState extends State<G2xInfinityListView> {
  ScrollController _scrollController = new ScrollController();
  var maxScrollExtent = 0.0;
  var loading = false;
  var loadingOnRefresh = false;
  Widget? emptyWidget;

  @override
  void initState() {
    super.initState();
    if(widget.callOnRefreshOnInit){
      onRefresh();
    }
    widget.controller.addListener(updateEmptyAndState);
    _scrollController..addListener(() async {
      var triggerFetchMoreSize = 0.9 * _scrollController.position.maxScrollExtent;
        if (_scrollController.position.pixels > triggerFetchMoreSize && triggerFetchMoreSize != maxScrollExtent && loading == false) {
          maxScrollExtent = triggerFetchMoreSize;
          await loadMore();
        }
    });
  }

  @override
  void dispose() {
     widget.controller.removeListener(updateEmptyAndState);
    super.dispose();
  }

  void updateEmptyAndState(){
    if(widget.controller.value.length == 0){
        emptyWidget = widget.emptyWidget;
    }
    else{
      emptyWidget = null;
    }
    setState(() {
      loadingOnRefresh = false;
      loading = false;
    });
  }

  Future<void> loadMore() async {
    setState(() {
      loading = true;
    });
    await widget.loadMore();
  }

  Future<void> onRefresh() async {
    setState(() {
      loading = false;
      loadingOnRefresh = true;
    });
    await widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    if(emptyWidget != null){
      return emptyWidget!;
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index < widget.controller.value.length) {
            return widget.controller.value[index];
          } else if(!loadingOnRefresh && (loading && (index == widget.controller.value.length + 1 || widget.controller.value.length == 0))) {
            return Center(
              child: Container(
                height: 20,
                width: 20,
                margin: EdgeInsets.only(bottom: 20, top: 20),
                child: 
                  CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)
                  )
              ),
            );
          }
          else return SizedBox();
        },
        itemCount: widget.controller.value.length + 1,
      ),
    );
  }
}