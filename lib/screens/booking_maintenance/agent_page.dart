import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:raco_ksa/main.dart';
import '../../component/loader_widget.dart';
import '../../utils/constant.dart';
import 'agent_model.dart';
import 'agent_service.dart';
import 'api_response.dart';

class Agent extends StatefulWidget {
  const Agent({super.key});

  @override
  State<Agent> createState() => _AgentState();
}

class _AgentState extends State<Agent> {
  var agents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("=======================================");
    print(appStore.token);
    print("=======================================");
    fetchAgentsData();
  }

  Future<void> fetchAgentsData() async {
    try {
      ApiResponse response = await fetchAgents();

      if (response.message != null) {
        print('حدث خطأ: ${response.message}');
        return;
      }

      setState(() {
        agents = response.data! as List<AgentModel>;
        isLoading = false;
      });
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  Future<void> _refreshData() async {
    await fetchAgentsData();
  }

  TimeOfDayFormat timeFormat = TimeOfDayFormat.h_colon_mm_space_a;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "الوكلاء والموزعين",
        textColor: white,
        showBack: true,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 3.0,
        color: context.primaryColor,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.of(context).push(MaterialPageRoute(
        //             builder: (context) => MaintenanceForm(
        //                   typeForm: "store",
        //                 )));
        //       },
        //       icon: Icon(Icons.add))
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SizedBox(
          width: context.width(),
          height: context.height(),
          child: isLoading
              ? Center(
                  child: LoaderWidget(),
                )
              : (agents.isEmpty
                  ? Center(
                      child: Text('لم يتم اضافة الوكلاء والموزعين حتى الآن'),
                    )
                  : ListView.builder(
                      itemCount: agents.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: context.dividerColor),
                            child: Row(
                              children: [
                                (agents[index].image != "")
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            agents[index].image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        decoration: BoxDecoration(
                                            color: context.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الاسم: ${agents[index].name}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: context.iconColor),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'العنوان: ${agents[index].address}',
                                      style:
                                          TextStyle(color: context.iconColor),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
        ),
      ),
    );
  }
}
