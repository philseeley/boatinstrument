part of 'boatinstrument_controller.dart';

// Help can be written in markdown. Local documentation should be placed in
// assets/doc and referenced with the "doc:" scheme, e.g.
//   @override
//   Widget? getHelp(BuildContext context) => const HelpPage(url: 'doc:my_help.md');

// If referencing icons, download them as PNG from https://fonts.google.com/icons
// as 32pt and colour #000000 for the light theme and #FFFFFF for the dark theme.
// The icons should be referenced as:
//   ![Image](assets/icons/__THEME__/my_icon.png)

class HelpPage extends StatefulWidget {
  final String? text;
  final String? url;
  final String title;

  const HelpPage({this.text, this.url, this.title = 'Help',  super.key});

  @override
  State<StatefulWidget> createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> {
  final List<String> _history = [];
  String? _text;

  @override
  void initState() {
    super.initState();
    _text = widget.text;
  }

  Future<void> loadData(String urlString, bool add) async {
    Uri uri = Uri.parse(urlString);
    if(uri.scheme == 'doc') {
      _text = await rootBundle.loadString('assets/doc/${uri.path}');

      if(add) {
        _history.add(urlString);
      }
      setState(() {});
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _back(BuildContext context) {
    if(_history.length > 1) {
      _history.removeLast();
      loadData(_history.last, false);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_text == null) {
      loadData(widget.url!, true);
      return Container();
    }

    _text = _text!.replaceAll('__THEME__', Theme.of(context).brightness.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: BackButton(onPressed: () {
          _back(context);
        },),),
      body: Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: MarkdownWidget(
          config: MarkdownConfig(configs: [
            LinkConfig(
              style: TextStyle(decoration: TextDecoration.underline),
              onTap: (url) {loadData(url, true);}
            )
          ]),
          data: _text!,
        )
      )
    );
  }  
}
