import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidacoletiva/controllers/event_controller.dart';
import 'package:vidacoletiva/controllers/project_controller.dart';
import 'package:vidacoletiva/data/models/event_model.dart';
import 'package:vidacoletiva/resources/widgets/main_app_bar.dart';
import 'package:vidacoletiva/views/events/event_card.dart';

class AllEventsOnProjectPage extends StatelessWidget {
  const AllEventsOnProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    EventController eventController = Provider.of(context);
    ProjectController projectController = Provider.of(context);
    String projectId = projectController.project!.id!;
    List<EventModel> events = eventController.getAllEventsOnProject(projectId);
    return Scaffold(
        appBar: mainAppBar(context, leading: true, profile: false),
        body: CustomScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildListDelegate([
              ...eventController
                  .getAllDates(events)
                  .map((e) => eventList(e, events)),
            ])),
          ],
        ));
  }

  Widget eventList(DateTime date, List<EventModel> events) {
    // Filtrar apenas os eventos da data específica
    List<EventModel> eventsOnDate = events.where((event) {
      return event.createdAt!.year == date.year &&
          event.createdAt!.month == date.month &&
          event.createdAt!.day == date.day;
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ...eventsOnDate.map((e) => EventCard(
            event: e,
          ))
    ]);
  }
}
