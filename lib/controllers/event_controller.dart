import 'package:flutter/material.dart';
import 'package:vidacoletiva/data/models/event_model.dart';
import 'package:vidacoletiva/data/models/media_model.dart';
import 'package:vidacoletiva/data/services/event_service.dart';

class EventController extends ChangeNotifier {
  EventService eventService;

  EventController(this.eventService);

  List<EventModel> events = [];
  Map<String, List<EventModel>> eventsInProject = {};

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

  init() async {
    await listOwnEvents();
  }

  Future listOwnEvents() async {
    events = await eventService.listOwn();
    debugPrint('events: ${events.length}');
    notifyListeners();
  }

  Future listEventsOnProject(String projectId) async {
    List<EventModel> m = await eventService.listEventsOnProject(projectId);
    eventsInProject[projectId] = m;
    notifyListeners();
  }

  List<EventModel> getEventsOnProject(String projectId) {
    var e = events.where((ev) => ev.projectId == projectId).toList();
    return e;
  }

  List<EventModel> getAllEventsOnProject(String? projectId) {
    if (projectId == null) {
      return [];
    }
    return eventsInProject[projectId] ?? [];
  }

  Future<bool> createEvent(
      BuildContext context,
      String? title,
      String? description,
      String projectId,
      List<CreateMedia> mediaList) async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      EventModel e = await eventService.addEvent(
          EventModel(
            title: title,
            text: description,
            projectId: projectId,
          ),
          mediaList);

      events.add(e);
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relato criado com sucesso'),
        ),
      );

      return true;
    } catch (e, s) {
      debugPrint('createEvent error: $e');
      debugPrint('$s');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Não foi possível criar o relato. Tente novamente mais tarde.'),
        ),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<DateTime> getAllDates(List<EventModel> events) {
    Set<DateTime> dateSet = {};
    for (var e in events) {
      if (e.createdAt == null) {
        continue;
      }
      DateTime d =
          DateTime(e.createdAt!.year, e.createdAt!.month, e.createdAt!.day);
      dateSet.add(d);
    }
    return dateSet.toList()..sort((a, b) => b.compareTo(a));
    // return dates
    //     .map((date) =>
    //         "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}")
    //     .toList();
  }
}
