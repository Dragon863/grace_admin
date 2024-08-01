import 'package:flutter/material.dart';
import 'package:grace_admin/pages/rota_edit/popup.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:grace_admin/utils/popup.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RotaEditPage extends StatefulWidget {
  const RotaEditPage({super.key});

  @override
  State<RotaEditPage> createState() => _RotaEditPageState();
}

class _RotaEditPageState extends State<RotaEditPage> {
  final List<PlutoColumn> columns = [
    PlutoColumn(
      title: 'Date',
      field: 'date_field',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: 'Status',
      field: 'status',
      type: PlutoColumnType.select(
        ['saved', 'edited', 'created'],
      ),
      enableEditingMode: false,
      frozen: PlutoColumnFrozen.end,
      titleSpan: const TextSpan(
        children: [
          WidgetSpan(
            child: Icon(Icons.lock, size: 17),
          ),
          TextSpan(text: 'Status'),
        ],
      ),
      renderer: (rendererContext) {
        Color textColor = Colors.black;
        switch (rendererContext.cell.value) {
          case 'saved':
            textColor = Colors.green;
            break;
          case 'edited':
            textColor = Colors.red;
            break;
          case 'created':
            textColor = Colors.blue;
            break;
        }
        return Text(
          rendererContext.cell.value.toString(),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        );
      },
    ),
  ];

  final List<PlutoRow> rows = [
    PlutoRow(cells: {
      'date_field': PlutoCell(value: '2020-08-06'),
      'status': PlutoCell(value: 'saved')
    }),
    PlutoRow(cells: {
      'date_field': PlutoCell(value: '2020-08-07'),
      'status': PlutoCell(value: 'saved')
    }),
    PlutoRow(cells: {
      'date_field': PlutoCell(value: '2020-08-08'),
      'status': PlutoCell(value: 'saved')
    }),
  ];

  late PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grace Admin Panel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 32, 109, 156),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final api = context.read<AuthAPI>();
              await api.signOut();
              Navigator.pushNamed(context, '/splash');
            },
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, size) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: size.maxWidth,
                height: size.maxHeight,
                constraints: const BoxConstraints(minHeight: 750),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: PlutoGrid(
                        columns: columns,
                        rows: rows,
                        onChanged: (PlutoGridOnChangedEvent event) {
                          if (event.row.cells['status']!.value == 'saved') {
                            event.row.cells['status']!.value = 'edited';
                          }
                          stateManager.notifyListeners();
                        },
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          stateManager = event.stateManager;
                        },
                        createHeader: (stateManager) =>
                            _Header(stateManager: stateManager),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({required this.stateManager, Key? key}) : super(key: key);

  final PlutoGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  int addCount = 1;
  List<String> users = [];

  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  @override
  void initState() {
    super.initState();
    final api = context.read<AuthAPI>();
    api.getAllUsers().then((value) {
      setState(() {
        users = value.map((user) => user[0]).toList();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.stateManager.setSelectingMode(gridSelectingMode);
    });
  }

  Future<void> handleAddColumns() async {
    final List<PlutoColumn> addedColumns = [];
    String? result = await showInputDialog(context);
    if (result != null) {
      addedColumns.add(
        PlutoColumn(
          title: result,
          field: result,
          type: PlutoColumnType.select(users, enableColumnFilter: true),
        ),
      );
    }

    widget.stateManager
        .insertColumns(widget.stateManager.bodyColumns.length, addedColumns);
  }

  void handleAddRows() {
    final newRows = widget.stateManager.getNewRows(count: addCount);
    for (var row in newRows) {
      row.cells['status']!.value = 'created';
    }
    widget.stateManager.appendRows(newRows);
    widget.stateManager.setCurrentCell(newRows.first.cells.entries.first.value,
        widget.stateManager.refRows.length - 1);
    widget.stateManager.moveScrollByRow(
        PlutoMoveDirection.down, widget.stateManager.refRows.length - 2);
    widget.stateManager.setKeepFocus(true);
  }

  void handleSaveAll() async {
    final api = context.read<AuthAPI>();
    final client = api.currentUser;
    final uuid = Uuid();

    for (var row in widget.stateManager.rows) {
      final date = row.cells['date_field']!.value;

      // Iterate through all the columns to find duties
      for (var column in widget.stateManager.columns) {
        if (column.field == 'date_field' || column.field == 'status') {
          continue;
        }

        final duty = row.cells[column.field]!.value;
        if (duty != null && duty.isNotEmpty) {
          // Fetch the user ID by duty (assuming duty is a user name)
          final userId = await api.fetchUserIDByName(duty);

          // Prepare the data to be saved
          final data = {
            'id': uuid.v4(),
            'date': date,
            'duty': duty,
            'user': userId,
          };

          // Insert the data into the Supabase table
          final response = await client
              .from(
                  'rota') // Replace 'your_table_name' with your actual table name
              .insert(data);
          print(response);
          if (response.error != null) {
            // Handle error
            print('Error saving data: ${response}');
          } else {
            // Mark the row as saved
            row.cells['status']!.value = 'saved';
          }
        }
      }
    }

    // Notify the state manager to update the UI
    widget.stateManager.notifyListeners();
  }

  void handleRemoveCurrentColumn() {
    final currentColumn = widget.stateManager.currentColumn;
    if (currentColumn != null) {
      widget.stateManager.removeColumns([currentColumn]);
    }
  }

  void handleRemoveCurrentRow() {
    widget.stateManager.removeCurrentRow();
  }

  void handleRemoveSelectedRows() {
    widget.stateManager.removeRows(widget.stateManager.currentSelectingRows);
  }

  void toggleFiltering() {
    widget.stateManager
        .setShowColumnFilter(!widget.stateManager.showColumnFilter);
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (mode != null && gridSelectingMode != mode) {
      setState(() {
        gridSelectingMode = mode;
        widget.stateManager.setSelectingMode(mode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: addCount,
                items:
                    [1, 5, 10, 15, 20].map<DropdownMenuItem<int>>((int count) {
                  return DropdownMenuItem<int>(
                    value: count,
                    child: Text(count.toString(),
                        style: TextStyle(
                            color: addCount == count ? Colors.blue : null)),
                  );
                }).toList(),
                onChanged: (int? count) {
                  setState(() {
                    addCount = count ?? 1;
                  });
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: handleAddColumns,
              label: const Text('Column'),
              icon: const Icon(Icons.add),
            ),
            ElevatedButton.icon(
              onPressed: handleAddRows,
              label: const Text('Rows'),
              icon: const Icon(Icons.add),
            ),
            ElevatedButton.icon(
              onPressed: handleSaveAll,
              label: const Text('Save'),
              icon: const Icon(Icons.save),
            ),
            ElevatedButton.icon(
              onPressed: handleRemoveCurrentColumn,
              label: const Text('Current Column'),
              icon: const Icon(Icons.delete_outline),
            ),
            ElevatedButton.icon(
              onPressed: handleRemoveCurrentRow,
              label: const Text('Current Row'),
              icon: const Icon(Icons.delete_outline),
            ),
            ElevatedButton.icon(
              onPressed: handleRemoveSelectedRows,
              label: const Text('Selected Rows'),
              icon: const Icon(Icons.delete_outline),
            ),
            ElevatedButton.icon(
              onPressed: toggleFiltering,
              label: const Text('Toggle Filtering'),
              icon: const Icon(Icons.toggle_on),
            ),
          ],
        ),
      ),
    );
  }
}
