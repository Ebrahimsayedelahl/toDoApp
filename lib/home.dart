import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/sqldb.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Sqldb sqlDb = Sqldb();

  Future<List<Map>> readData() async {
    List<Map> response = await sqlDb.readData(" SELECT  * FROM notes ");
    return response;
  }

  bool isChecked = false;

  final _controller = TextEditingController();
  final _task = TextEditingController();
  final DateTime _today = DateTime.now();
  final Map<int, String> _months = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec",
  };
  final Map<int, String> _weekdays = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130.0),
          child: Container(
            height: 100.0,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _today.day.toString(),
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _months[_today.month]!.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _today.year.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),


                            ],
                          ),
                        ),
                        const SizedBox(width: 150,),
                        Text(
                          _weekdays[_today.weekday]!.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            color: Colors.white,
                            fontSize: 23,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              FutureBuilder(
                future: readData(),
                builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                  if (snapshot.hasData) {
                    return
                      ListView.builder(
                      itemCount: snapshot.data!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {

                        return Card(

                          child: Transform.scale(
                            scale: 1.2,
                            child: CheckboxListTile(
                              checkboxShape: const CircleBorder(),
                              title: Text("${snapshot.data![i]['task']}"),
                              subtitle: Text("${snapshot.data![i]['date']}"),
                              value: isChecked,
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
          Positioned(
            right: 30,
            bottom: 70,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  //isScrollControlled:true,
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.0),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        height: 250,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                            TextField(
                            controller: _task,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'Task',
                            ),
                          ),
                          TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'No due date',
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  DateTime? newDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2030),
                                  );
                                  if (newDate != null) {
                                    setState(() {
                                      _controller.text =
                                          DateFormat('yyy-MM-dd')
                                              .format(newDate);
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(
                                width: 140,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "cancel",

                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,),

                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              TextButton(
                                onPressed: () async  {
                                    int response =
                                    await sqlDb.insertData('''
                                INSERT INTO notes ( task , date)
                                VALUES ('${_task.text}' ,'${_controller.text}')
                                ''');
                                    if (response > 0) {
                                      Navigator.pop(context);
                                    }

                                },
                                child: const Text(
                                  "save",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                            )],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}