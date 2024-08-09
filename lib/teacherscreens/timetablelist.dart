import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:studybunnies/teacherwidgets/timetable.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableList extends StatefulWidget {
  const TimetableList({super.key});

  @override
  State<TimetableList> createState() => _TimetableListState();
}

class _TimetableListState extends State<TimetableList> {
  String? selectedClassID;
  String? selectedDate;

  List<Map<String, String>> classname = [];
  String? selectedClass;
  Map<String, List<Map<String, dynamic>>> timetableEntriesByDate = {};

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      selectedClassID =
          snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    });
  }

  String convertTimeFormat(String timeStr) {
    DateTime time = DateFormat('HH:mm').parse(timeStr);
    return DateFormat('h:mm a').format(time);
  }

  String calculateEndTime(String startTimeStr, String duration) {
    DateTime startTime = DateFormat('h:mm a').parse(startTimeStr);
    Duration durationToAdd;
    if (duration == "1 Hour") {
      durationToAdd = Duration(hours: 1);
    } else if (duration == "2 Hour") {
      durationToAdd = Duration(hours: 2);
    } else if (duration == "3 Hour") {
      durationToAdd = Duration(hours: 3);
    } else {
      throw ArgumentError("Invalid duration format");
    }
    DateTime endTime = startTime.add(durationToAdd);
    return DateFormat('h:mm a').format(endTime);
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchTimetables(
      String? classID, String? date) async {
    if (classID == null) return {};
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    DateTime? selectedDateTime = date != null ? formatter.parse(date) : null;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .where('classID', isEqualTo: classID)
        .get();

    Map<String, List<Map<String, dynamic>>> groupedEntries = {};
    snapshot.docs.forEach((doc) {
      DateTime docDate = doc['classtime'] is Timestamp
          ? (doc['classtime'] as Timestamp).toDate()
          : doc['classtime'] as DateTime;
      String formattedDate = formatter.format(docDate);

      if (selectedDateTime == null ||
          (docDate.year == selectedDateTime.year &&
              docDate.month == selectedDateTime.month &&
              docDate.day == selectedDateTime.day)) {
        if (!groupedEntries.containsKey(formattedDate)) {
          groupedEntries[formattedDate] = [];
        }
        groupedEntries[formattedDate]!.add({
          'classID': doc.id,
          'classtime': docDate,
          'coursename': doc['coursename'] as String,
          'duration': doc['duration'] as String,
          'teacherID': doc['teacherID'] as String,
          'timetableID': doc['timetableID'] as String,
          'venue': doc['venue'] as String,
        });
      }
    });

    return groupedEntries;
  }

  Future<List<String>> _fetchAvailableDates(String classID) async {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .where('classID', isEqualTo: classID)
        .get();

    Set<String> dateSet = {};

    snapshot.docs.forEach((doc) {
      DateTime docDate = doc['classtime'] is Timestamp
          ? (doc['classtime'] as Timestamp).toDate()
          : doc['classtime'] as DateTime;

      dateSet.add(formatter.format(docDate));
    });

    return dateSet.toList();
  }

  void _showClassOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: classname.map((Map<String, String> item) {
              return ListTile(
                title: Text(item['classname']!),
                onTap: () async {
                  if (item['classID']!.isNotEmpty) {
                    setState(() {
                      selectedClass = item['classname'];
                      selectedClassID = item['classID'];
                      selectedDate =
                          null; // Reset date selection when class changes
                    });
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showDateOptionsBottomSheet() async {
    if (selectedClassID == null || selectedClassID!.isEmpty) {
      return; // Exit if no class is selected
    }

    List<String> dates = await _fetchAvailableDates(selectedClassID!);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Select a Date'),
                onTap: () {
                  setState(() {
                    selectedDate = null; // Reset date selection
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              ...dates.map((String date) {
                return ListTile(
                  title: Text(date),
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      // Fetch and update timetable entries based on the selected class and date
                      fetchTimetables(selectedClassID, selectedDate)
                          .then((entries) {
                        setState(() {
                          timetableEntriesByDate = entries;
                        });
                      });
                    });
                    Navigator.pop(context); // Close the bottom sheet
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: mainappbar(
          "Timetable",
          "This section includes the timetable for various classes.",
          context,
        ),
        bottomNavigationBar: navbar(1),
        drawer: teacherDrawer(context, 1, drawercurrentindex: 1),
        body: Padding(
          padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40.w,
                    child: ElevatedButton(
                      onPressed: _showClassOptionsBottomSheet,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              selectedClass != null
                                  ? selectedClass!
                                  : 'Select Class',
                              style: const TextStyle(
                                color: Colors.black,
                              )),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Container(
                    width: 40.w,
                    child: ElevatedButton(
                      onPressed: _showDateOptionsBottomSheet,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedDate ?? 'Select Date',
                              style: const TextStyle(
                                color: Colors.black,
                              )),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 2.h),
                  child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                    future: selectedClassID != null && selectedDate != null
                        ? fetchTimetables(selectedClassID!, selectedDate)
                        : Future.value({}),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        Map<String, List<Map<String, dynamic>>>
                            timetableEntriesByDate = snapshot.data ?? {};
                        List<String> dates =
                            timetableEntriesByDate.keys.toList();
                        dates.sort((a, b) => DateFormat('dd-MM-yyyy')
                            .parse(a)
                            .compareTo(DateFormat('dd-MM-yyyy').parse(b)));

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dates.isEmpty
                                ? [const Text("No Timetable Data Available")]
                                : dates.map((dateString) {
                                    List<Map<String, dynamic>> entries =
                                        timetableEntriesByDate[dateString] ??
                                            [];
                                    entries.sort((a, b) {
                                      DateTime startTimeA =
                                          a['classtime'] is Timestamp
                                              ? (a['classtime'] as Timestamp)
                                                  .toDate()
                                              : a['classtime'] as DateTime;
                                      DateTime startTimeB =
                                          b['classtime'] is Timestamp
                                              ? (b['classtime'] as Timestamp)
                                                  .toDate()
                                              : b['classtime'] as DateTime;
                                      return startTimeA.compareTo(startTimeB);
                                    });
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 2.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Timetableheader(
                                            DateFormat('EEEE, d/MM/yyyy')
                                                .format(DateFormat('dd-MM-yyyy')
                                                    .parse(dateString)),
                                          ),
                                          SizedBox(height: 1.h),
                                          ...entries.map((entry) {
                                            String startTime =
                                                DateFormat('HH:mm')
                                                    .format(entry['classtime']);
                                            String endTime = calculateEndTime(
                                                convertTimeFormat(startTime),
                                                entry['duration']);

                                            return Timetablecontent(
                                              context,
                                              entry['coursename'],
                                              entry['venue'],
                                              convertTimeFormat(startTime),
                                              endTime,
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
