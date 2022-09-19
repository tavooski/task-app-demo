import 'package:calendar_task_app_01/controllers/task_controller.dart';
import 'package:calendar_task_app_01/services/notification_services.dart';
import 'package:calendar_task_app_01/services/theme_services.dart';
import 'package:calendar_task_app_01/ui/add_task_page.dart';
import 'package:calendar_task_app_01/ui/theme.dart';
import 'package:calendar_task_app_01/ui/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _taskController = Get.put(TaskController());
  var notifyHelper;

  @override
  void initState() {
    // TODO: Implement initState
    _taskController.getTask();

    _selectedDay = _focusedDay;

    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        children: [
          _addCalendarPicker(),
          Container(
            height: 1.8,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          const SizedBox(height: 10.0),
          _showTasks(),
          _addLegend(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: FloatingActionButton(
          onPressed: () async {
            _taskController.getTask();
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return const FractionallySizedBox(
                    heightFactor: 0.69, child: AddTaskPage());
              },
              isScrollControlled: true,
            );
            //await Get.to(() => const AddTaskPage());
          },
          child: const Icon(Icons.add),
          backgroundColor: orangeClr,
        ),
      ),
    );
  }

  _bottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color color,
      required BuildContext context,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 55,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
              color: isClose == true ? Colors.transparent : color,
              border: Border.all(
                  width: 2,
                  color: isClose == true
                      ? Get.isDarkMode
                          ? Colors.grey[600]!
                          : Colors.grey[300]!
                      : color),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text(
              label,
              style: isClose
                  ? titleStyle
                  : titleStyle.copyWith(color: Colors.white),
            ),
          )),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.only(top: 4),
      height: task.isCompleted == 1
          ? MediaQuery.of(context).size.height * 0.24
          : MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyClr : Colors.white,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          const Spacer(),
          task.isCompleted == 1
              ? Container()
              : _bottomSheetButton(
                  label: 'Task Completed',
                  onTap: () {
                    _taskController.markTaskCompleted(task.id!);
                    Get.back();
                  },
                  color: primaryClr,
                  context: context),
          _bottomSheetButton(
              label: 'Delete',
              onTap: () {
                _taskController.delete(task);
                Get.back();
              },
              color: Colors.red[300]!,
              context: context),
          const SizedBox(height: 20),
          _bottomSheetButton(
              label: 'Close',
              onTap: () {
                Get.back();
              },
              color: Colors.red[300]!,
              isClose: true,
              context: context),
          const SizedBox(height: 10),
        ],
      ),
    ));
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              print(_taskController.taskList.length);
              Task task = _taskController.taskList[index];
              if (task.repeat == 'Daily') {
                DateTime date =
                    DateFormat.jm().parse(task.startTime.toString());
                var myTime = DateFormat("HH:mm").format(date);
                notifyHelper.scheduledNotification(
                    int.parse(myTime.toString().split(":")[0]),
                    int.parse(myTime.toString().split(":")[1]),
                    task);
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            )
                          ],
                        ),
                      ),
                    ));
              }
              if (task.date == DateFormat.yMd().format(_selectedDay!)) {
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            )
                          ],
                        ),
                      ),
                    ));
              } else {
                return Container();
              }
              return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showBottomSheet(context, task);
                            },
                            child: TaskTile(task),
                          )
                        ],
                      ),
                    ),
                  ));
            });
      }),
    );
  }

  _addCalendarPicker() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        calendarStyle: CalendarStyle(
          todayTextStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAFAFA),
              fontSize: 16.0),
          selectedTextStyle: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAFAFA)),
          outsideTextStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Color(0xFFAEAEAE)),
          defaultTextStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
          holidayDecoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          disabledDecoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          outsideDecoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          weekendDecoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          markerDecoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          defaultDecoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          selectedDecoration: BoxDecoration(
              color: orangeClr, borderRadius: BorderRadius.circular(15)),
          todayDecoration: BoxDecoration(
              color: lightOrangeClr, borderRadius: BorderRadius.circular(15)),
        ),
        headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: titleStyle),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: subTitleStyle,
          weekendStyle: subTitleStyle,
        ),
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.week: 'Week',
        },
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2020, 01, 01),
        lastDay: DateTime.utc(2030),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }

  _addLegend() {
    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      height: MediaQuery.of(context).size.height * .050,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: const Border(
            top: BorderSide(
          color: darkHeaderClr,
        )),
        color: Get.isDarkMode ? darkHeaderClr : Colors.grey[300],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
                // for background color
                //color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: const [
                Icon(
                  Icons.album_rounded,
                  color: orangeClr,
                  size: 20,
                ),
                Text(
                  " HairLux",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
                // for background color
                //color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: const [
                Icon(
                  Icons.album_rounded,
                  color: primaryClr,
                  size: 20,
                ),
                Text(
                  " Washed",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              // for background color
              //color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: const [
                Icon(
                  Icons.album_rounded,
                  color: pinkClr,
                  size: 20,
                ),
                Text(
                  " Conditioned",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _addDatePicker() {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 10.0, left: 20.0),
  //     child: DatePicker(
  //       DateTime.now(),
  //       height: 100.0,
  //       width: 80.0,
  //       initialSelectedDate: DateTime.now(),
  //       selectionColor: primaryClr,
  //       selectedTextColor: Colors.white,
  //       dateTextStyle: GoogleFonts.lato(
  //           textStyle: TextStyle(
  //               fontSize: 20.0,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.grey)),
  //       dayTextStyle: GoogleFonts.lato(
  //           textStyle: TextStyle(
  //               fontSize: 16.0,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.grey)),
  //       monthTextStyle: GoogleFonts.lato(
  //           textStyle: TextStyle(
  //               fontSize: 14.0,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.grey)),
  //       onDateChange: (date) {
  //         _selectedDate = date;
  //       },
  //     ),
  //   );
  // }

  // _addTaskBar() {
  //   return Container(
  //     margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Container(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(DateFormat.yMMMMd().format(DateTime.now()),
  //                   style: subHeadingStyle),
  //               Text('Today', style: headingStyle)
  //             ],
  //           ),
  //         ),
  //         MyButton(
  //             label: '+ Add Task', onTap: () => Get.to(() => AddTaskPage())),
  //       ],
  //     ),
  //   );
  // }

  _appBar() {
    return AppBar(
      elevation: 1.5,
      backgroundColor: orangeClr,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
          notifyHelper.displayNotification(
            title: 'Theme Changed',
            body: Get.isDarkMode
                ? 'Activated Light Theme'
                : 'Activated Dark Theme',
          );
          //notifyHelper.scheduledNotification();
        },
        child: Icon(
            Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            size: 20.0,
            color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      actions: [
        Icon(Icons.settings_sharp,
            color: Get.isDarkMode ? Colors.white : Colors.black),
        const SizedBox(
          width: 20.0,
        ),
      ],
    );
  }
}
