import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReportService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /// Gera um relatório em Excel com as mídias separadas por usuário
  /// Colunas: Usuário, ID do Usuário, Projeto, ID do Projeto, Título do Evento, Tipo de Mídia
  Future<File> generateMediaReport() async {
    try {
      // Buscar todos os eventos
      final eventsSnapshot =
          await _firebaseFirestore.collection('events').get();

      // Criar um mapa de usuários e seus eventos com mídias
      Map<String, Map<String, dynamic>> userMediaMap = {};

      for (var eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        final userId = eventData['user_id'] ?? 'Desconhecido';
        final projectId = eventData['project_id'] ?? 'Sem projeto';
        final title = eventData['title'] ?? 'Sem título';
        final mediaList = eventData['media'] ?? [];

        // Se não tem mídia, pula
        if (mediaList.isEmpty) continue;

        // Buscar dados do usuário
        String userName = 'Desconhecido';
        try {
          final userDoc =
              await _firebaseFirestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            userName = userDoc['email'] ?? 'Desconhecido';
          }
        } catch (e) {
          print('Erro ao buscar usuário: $e');
        }

        // Buscar dados do projeto
        String projectName = 'Sem projeto';
        try {
          final projectDoc = await _firebaseFirestore
              .collection('projects')
              .doc(projectId)
              .get();
          if (projectDoc.exists) {
            projectName = projectDoc['name'] ?? 'Sem projeto';
          }
        } catch (e) {
          print('Erro ao buscar projeto: $e');
        }

        // Adicionar ao mapa (agrupando mídias por evento)
        String eventKey = '${userId}_${eventDoc.id}';
        if (!userMediaMap.containsKey(eventKey)) {
          userMediaMap[eventKey] = {
            'userName': userName,
            'userId': userId,
            'projectId': projectId,
            'projectName': projectName,
            'title': title,
            'eventId': eventDoc.id,
            'mediaList': [],
          };
        }

        // Adicionar todas as mídias com links
        for (var media in mediaList) {
          String mediaName = media is String ? media : media.toString();
          String mediaPath = '/$userId/${eventDoc.id}/$mediaName';

          // Obter URL de download do Firebase Storage
          String downloadUrl = '';
          try {
            final ref = _firebaseStorage.ref(mediaPath);

            // Verificar se o arquivo existe antes de obter a URL
            await ref.getMetadata();
            downloadUrl = await ref.getDownloadURL();
          } catch (e) {
            print('Erro ao obter URL da mídia $mediaPath: $e');
            // Tentar sem a barra no início
            try {
              String alternativePath = '$userId/${eventDoc.id}/$mediaName';
              final ref = _firebaseStorage.ref(alternativePath);
              await ref.getMetadata();
              downloadUrl = await ref.getDownloadURL();
            } catch (e2) {
              print('Erro alternativo: $e2');
              downloadUrl = 'Mídia não encontrada no Storage';
            }
          }

          userMediaMap[eventKey]!['mediaList'].add({
            'name': mediaName,
            'url': downloadUrl,
          });
        }
      }

      // Criar Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Adicionar cabeçalho
      var headerRow = [
        'Usuário',
        'ID do Usuário',
        'Projeto',
        'ID do Projeto',
        'Título do Evento',
        'Mídias (Nome)',
        'Links das Mídias',
      ];

      for (int i = 0; i < headerRow.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headerRow[i]);
        // Estilizar cabeçalho
        cell.cellStyle = CellStyle(bold: true);
      }

      // Adicionar dados
      int rowIndex = 1;
      userMediaMap.forEach((eventKey, eventData) {
        String userName = eventData['userName'];
        String userId = eventData['userId'];
        String projectName = eventData['projectName'];
        String projectId = eventData['projectId'];
        String title = eventData['title'];
        List<dynamic> mediaList = eventData['mediaList'];

        // Agrupar todas as mídias na mesma célula
        String mediaNames =
            mediaList.map((m) => m['name'].toString()).join('\n');

        String mediaUrls = mediaList.map((m) => m['url'].toString()).join('\n');

        var cells = [
          TextCellValue(userName),
          TextCellValue(userId),
          TextCellValue(projectName),
          TextCellValue(projectId),
          TextCellValue(title),
          TextCellValue(mediaNames),
          TextCellValue(mediaUrls),
        ];

        for (int i = 0; i < cells.length; i++) {
          var cell = sheetObject.cell(
            CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
          );
          cell.value = cells[i];

          // Habilitar quebra de linha para as colunas de mídia
          if (i >= 5) {
            cell.cellStyle = CellStyle(
              textWrapping: TextWrapping.WrapText,
            );
          }
        }

        rowIndex++;
      });

      // Ajustar largura das colunas
      sheetObject.setColumnWidth(0, 25);
      sheetObject.setColumnWidth(1, 30);
      sheetObject.setColumnWidth(2, 25);
      sheetObject.setColumnWidth(3, 20);
      sheetObject.setColumnWidth(4, 30);
      sheetObject.setColumnWidth(5, 40);
      sheetObject.setColumnWidth(6, 60);

      // Salvar arquivo temporário para compartilhar
      var bytes = excel.save();
      var dir = await getTemporaryDirectory();
      String fileName =
          'relatorio_medias_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      File file = File('${dir.path}/$fileName');

      if (bytes != null) {
        await file.writeAsBytes(bytes);
      }

      return file;
    } catch (e) {
      print('Erro ao gerar relatório: $e');
      throw Exception('Erro ao gerar relatório: $e');
    }
  }

  /// Compartilha o arquivo de relatório usando o pacote share_plus
  Future<void> shareReport(File file) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Relatório de Mídias - Vida Coletiva',
      );
    } catch (e) {
      print('Erro ao compartilhar relatório: $e');
      throw Exception('Erro ao compartilhar relatório: $e');
    }
  }
}
