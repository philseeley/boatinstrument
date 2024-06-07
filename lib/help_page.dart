part of 'boatinstrument_controller.dart';

class _HelpPage extends StatelessWidget {
  final BoatInstrumentController _controller;

  const _HelpPage(this._controller);

  @override
  Widget build(BuildContext context) {
    List<ListTile> list = [
      ListTile(title: RichText(text: TextSpan(style: Theme.of(context).textTheme.bodyMedium, children: const [
        TextSpan(text: '''The display shows a number of Pages and swiping left/right moves between them. Swiping down and selecting '''),
        WidgetSpan(child: Icon(Icons.web)),
        TextSpan(text: ''' shows the list of Pages. Press the '''),
        WidgetSpan(child: Icon(Icons.edit)),
        TextSpan(text: ''' button to edit a Page. Each Page is made up of multiple Columns (Red), containing multiple Rows (Orange), containing multiple Boxes (Blue).
The contents of each Box is selected through the '''),
        WidgetSpan(child: Icon(Icons.list, color: Colors.blue)),
        TextSpan(text: ''' button. If the Box has settings these are set through the '''),
        WidgetSpan(child: Icon(Icons.settings)),
        TextSpan(text: ''' buttons in the top right of the Box. The Blue button sets the per-Box settings and the White/Black button sets the Box Type settings that are shared between all instances of the Box.
The sizes of the Page elements can be adjusted by dragging the coloured Box borders. If the last Box in a Row or Column is deleted, the Row or Column is also deleted.
Swiping up or pressing the back button hides the top bar.''')]))),
      const ListTile(leading: Icon(Icons.mode_night), title: Text('Enables Night Mode')),
      const ListTile(leading: Icon(Icons.brightness_high), title: Text('Cycles the brightness')),
      const ListTile(leading: Icon(Icons.share), title: Text('Shares/Exports the Settings')),
      const ListTile(leading: Icon(Icons.file_open), title: Text('Imports Settings from a file')),
      const ListTile(leading: Icon(Icons.notes), title: Text('Shows the message/error log')),
      const ListTile(title: Text('Box Specific Help:')),
    ];

    for(BoxDetails b in boxDetails) {
      BoxWidget? box = b.build(BoxWidgetConfig(_controller, {}, const BoxConstraints(maxWidth: 1.0, maxHeight: 1.0), true));
      Widget? boxHelp = box.getSettingsHelp();
      Widget? perBoxHelp = box.getPerBoxSettingsHelp();
      if(boxHelp != null || perBoxHelp != null) {
        list.add(ListTile(title: Text(b.description)));
      }
      if(boxHelp != null) {
        list.add(ListTile(leading: const Icon(Icons.settings), title: boxHelp));
      }
      if(perBoxHelp != null) {
        list.add(ListTile(leading: const Icon(Icons.settings, color: Colors.blue), title: perBoxHelp));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(children: list)
    );
  }
}
