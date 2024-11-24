part of 'boatinstrument_controller.dart';

class _HelpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HelpPageState();
}

class _HelpPageState extends State<_HelpPage> {
  List<String> history = [];
  String? data;

  @override
  void initState() {
    super.initState();
    loadData('help.md', true);
  }

  loadData(String file, bool add) async {
    data = await rootBundle.loadString('assets/$file');
    if(add) {
      history.add(file);
    }
    setState(() {
    });
  }

  _back(BuildContext context) {
    if(history.length > 1) {
      history.removeLast();
      loadData(history.last, false);
    } else {
      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    if(data != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Help'),
          leading: BackButton(onPressed: () {
            _back(context);
          },),),
        body: Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: MarkdownWidget(
            config: MarkdownConfig(configs: [
              LinkConfig(onTap: (url) {loadData(url, true);})
            ]),
            data: data!,
          )
        )
      );
    } else {
      return Container();
    }
  }
  
}