part of 'boatinstrument_controller.dart';

class _HelpPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<ListTile> list = [
      ListTile(title: RichText(text: TextSpan(style: Theme.of(context).textTheme.bodyMedium, children: const [
        TextSpan(text: '''The display shows a number of Pages and swiping left/right moves between them. Swiping down and selecting '''),
        WidgetSpan(child: Icon(Icons.web)),
        TextSpan(text: ''' shows the list of Pages. Press the '''),
        WidgetSpan(child: Icon(Icons.edit)),
        TextSpan(text: ''' button to edit a Page. Each Page is made up of multiple Page Rows (Red), containing multiple Columns (Orange), containing multiple Rows (Yellow), containing multiple Boxes (Blue). Use the coloured arrows to add Page elements.

Hint: sometimes you may need to temporarily resize a Box to show all the buttons.

The contents of each Box is selected through the '''),
        WidgetSpan(child: Icon(Icons.list, color: Colors.blue)),
        TextSpan(text: ''' button. If the Box has settings these are set through the '''),
        WidgetSpan(child: Icon(Icons.settings)),
        TextSpan(text: ''' buttons in the top right of the Box. The Blue button sets the per-Box settings and the White/Black button sets the Box Type settings that are shared between all instances of the Box.

The sizes of the Page elements can be adjusted by dragging the coloured Box borders. If the last Box in a Row or Column is deleted, the Row or Column is also deleted.

Swiping up or pressing the back button hides the top bar.

For "Auto Discovery" of your SignalK server, mDNS must be turned on in your server's settings. If discovery does not work, enter your server's hostname/IP and port number.

In "Demo Mode" the app connects to "https://demo.signalk.org".''')]))),
      const ListTile(leading: Icon(Icons.mode_night), title: Text('Enables Night Mode')),
      const ListTile(leading: Icon(Icons.brightness_high), title: Text('Cycles the brightness')),
      const ListTile(leading: Icon(Icons.sync_alt), title: Text('Toggles the Auto-Page rotation. Set the per-page delays in the page list. Pages without delays are not shown')),
      const ListTile(leading: Icon(Icons.copy), title: Text('Copy/Clone a Page')),
      const ListTile(leading: Icon(Icons.share), title: Text('Shares/Exports the Settings')),
      const ListTile(leading: Icon(Icons.file_open), title: Text('Imports Settings from a file')),
      const ListTile(leading: Icon(Icons.notes), title: Text('Shows the message/error log')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(children: list)
    );
  }
}
