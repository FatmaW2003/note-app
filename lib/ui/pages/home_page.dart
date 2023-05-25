import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:note_app/controllers/task_controller.dart';
import 'package:note_app/services/notification_services.dart';
import 'package:note_app/ui/size_config.dart';
import 'package:note_app/ui/widgets/button.dart';

import '../../models/task.dart';
import '../../services/theme_services.dart';
import '../theme.dart';
import 'add_task_page.dart';
import 'package:note_app/ui/widgets/task_tile.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  @override
  void initState(){
    super.initState();
   notifyHelper=NotifyHelper();
   notifyHelper.initializeNotification();
   notifyHelper.requestIOSPermissions();
    taskController.getTasks();

  }
  DateTime selectedDate = DateTime.now();

  final TaskController taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: context.theme.backgroundColor,
        appBar: appBar(),
        body: Column(children: [
          addTaskBar(),
          addDateBar(),
          const SizedBox(height: 6,),
          showTasks(),
        ],),
    );
  }

  AppBar appBar() {
    return AppBar(
      leading: IconButton(onPressed: () {
        ThemeServices().switchTheme();
      },
        icon: Icon(
          Get.isDarkMode ?
          Icons.wb_sunny_outlined : Icons.nightlight_round_outlined, size: 24,
          color: Get.isDarkMode ? Colors.white : darkGreyClr
          ,),
      ),
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      actions: [
        IconButton(
         icon:Icon(
    Icons.cleaning_services_outlined, size: 24,
        color: Get.isDarkMode ? Colors.white : darkGreyClr),
    onPressed:() {
      notifyHelper.cancelAllNotification();
      taskController.deleteAllTasks();
    },
          ),
        const CircleAvatar(backgroundImage: AssetImage('images/person.jpeg'),
          radius:18),
      const  SizedBox(width: 20,),
      ],
    );
  }

  addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text('Today', style: headingStyle,)
              ]
          ),
          MyButton(label: '+Add Task',
              onTap: () async {
                await Get.to(() =>  AddTaskPage());
                taskController.getTasks();
              }),
        ],
      ),
    );
  }

  addDateBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 6),
      child: DatePicker(DateTime.now(),
        width: 70,
        height: 100,
        initialSelectedDate: DateTime.now(),
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),),
        onDateChange: (newDate) {
          setState(() {
            selectedDate = newDate;
          });
        },
      ),
    );
  }

  showTasks() {
    return Expanded(
      child: Obx((){
        if(taskController.taskList.isEmpty){
          return noTaskMsg();}
          else{
              return ListView.builder(
                scrollDirection:SizeConfig.orientation==Orientation.landscape? Axis.horizontal:Axis.vertical,
                 itemCount:
                 taskController.taskList.length,
                itemBuilder:(BuildContext context,int index) {
                  var task = taskController.taskList[index];

                  if (task.repeat == 'Daily' ||
                      task.date == DateFormat.yMd().format(selectedDate)
                      || (task.repeat == 'Weekly' && selectedDate
                          .difference(DateFormat.yMd().parse(task.date!))
                          .inDays % 7 == 0)
                      || (task.repeat == 'Monthly' && DateFormat
                          .yMd()
                          .parse(task.date!)
                          .day == selectedDate.day)
                  ) {
                    var date = DateFormat.jm().parse(task.startTime!);
                    var myTime = DateFormat('HH:mm').format(date);
                    notifyHelper.scheduledNotification(
                      int.parse(myTime.toString().split(':')[0]),
                      int.parse(myTime.toString().split(':')[1]),
                     task,
                    );
                    return
                      AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 1375),
                        child: SlideAnimation(
                          horizontalOffset: 300,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () =>
                                  showBottomSheet(context, task),
                              child: TaskTile(task),
                            ),
                          ),
                        ),
                      );
                  }else {
                    return Container();
                  }
                }
               );
        }}));

      }

  noTaskMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 2000),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape ? Axis
                    .horizontal : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 6)
                      :
                  const SizedBox(height: 220),
                  Image.asset('images/task.jpeg', height: 90,
                    semanticLabel: 'Task',
                    color: primaryClr.withOpacity(0.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                        'You do not have any tasks yet!\n Add new tasks to make your days ',
                        style: subTitleStyle,
                        textAlign: TextAlign.center),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 120)
                      :
                  const SizedBox(height: 180),
                ],),
            ),

        )
      ],
    );
  }
  showBottomSheet(BuildContext context,Task task){
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 4),
            width: SizeConfig.screenWidth,
            height: (SizeConfig.orientation==Orientation.landscape)?(task.isCompleted==1?SizeConfig.screenHeight*0.6
                :SizeConfig.screenHeight*0.8):(task.isCompleted==1?
            SizeConfig.screenHeight*0.30:SizeConfig.screenWidth*0.39),
            color:Get.isDarkMode?darkHeaderClr:Colors.white,
            child:Column(children: [
           Flexible(child: Container(width:
             120,
             height: 6,
             decoration:
             BoxDecoration(borderRadius: BorderRadius.circular(10),
             color: Get.isDarkMode?Colors.grey[600]:Colors.grey[300],),
             ),
           ),
              const SizedBox(height:20),
              task.isCompleted==1?Container():buildBottomSheet(label: 'Task Completed', onTap: (){
                notifyHelper.cancelNotification(task);
               taskController.markTaskCompleted(task.id!);
               Get.back();
              }, clr: primaryClr,
              ),
              buildBottomSheet(label: 'Delete Task', onTap: (){
               notifyHelper.cancelNotification(task);
                taskController.deleteTasks(task);
                Get.back();
              }, clr: Colors.red[300]!,
              ),
              Divider(color:Get.isDarkMode? Colors.grey:darkGreyClr),
              buildBottomSheet(label: 'Cancel', onTap: (){
                Get.back();
              }, clr: primaryClr,
              ),
              const SizedBox(height: 20)
        ],),),
      )
    );
  }
  buildBottomSheet(
  {required String label,required Function() onTap,required Color clr, bool isClose=false}
      ){return GestureDetector(
    onTap: onTap,
        child: Container(
        margin: EdgeInsets.symmetric(vertical: 4,),
    height: 65,
    width: SizeConfig.screenWidth*0.9,
    decoration: BoxDecoration(
  border: Border.all(width: 2,
  color: isClose?Get.isDarkMode?Colors.grey[600]!:Colors.grey[300]!:clr),
        borderRadius: BorderRadius.circular(20),
        color: isClose ?Colors.transparent:clr,


  ),
          child: Center(child:Text(label,style:isClose? titleStyle:titleStyle.copyWith(color:Colors.white,
          ),),),
        ),
      );

  }
}
