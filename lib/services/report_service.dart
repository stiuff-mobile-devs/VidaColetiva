import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ReportService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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
        if ((mediaList as List).isEmpty) continue;

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

        // Adicionar ao mapa
        if (!userMediaMap.containsKey(userId)) {
          userMediaMap[userId] = {'userName': userName, 'medias': []};
        }

        // Processar cada mídia
        for (var media in mediaList as List) {
          userMediaMap[userId]!['medias'].add({
            'projectId': projectId,
            'projectName': projectName,
            'title': title,
            'mediaName': media is String ? media : media.toString(),
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
        'Arquivo de Mídia',
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
      userMediaMap.forEach((userId, userData) {
        String userName = userData['userName'];
        List<dynamic> medias = userData['medias'];

        for (var media in medias) {
          var cells = [
            TextCellValue(userName),
            TextCellValue(userId),
            TextCellValue(media['projectName']?.toString() ?? 'N/A'),
            TextCellValue(media['projectId']?.toString() ?? 'N/A'),
            TextCellValue(media['title']?.toString() ?? 'N/A'),
            TextCellValue(media['mediaName']?.toString() ?? 'N/A'),
          ];

          for (int i = 0; i < cells.length; i++) {
            var cell = sheetObject.cell(
              CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
            );
            cell.value = cells[i];
          }

          rowIndex++;
        }
      });

      // Ajustar largura das colunas
      sheetObject.setColumnWidth(0, 25);
      sheetObject.setColumnWidth(1, 30);
      sheetObject.setColumnWidth(2, 25);
      sheetObject.setColumnWidth(3, 20);
      sheetObject.setColumnWidth(4, 30);
      sheetObject.setColumnWidth(5, 25);

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

  /// Compartilha o arquivo de relatório usando Intent nativo do Android
  Future<void> shareReport(File file) async {
    try {
      const platform = MethodChannel('com.vidacoletiva.app/share');

      await platform.invokeMethod('shareFile', {
        'filePath': file.path,
        'fileName': file.path.split('/').last,
      });
    } on PlatformException catch (e) {
      print('Erro ao compartilhar relatório: ${e.message}');
      throw Exception('Erro ao compartilhar relatório: ${e.message}');
    } catch (e) {
      print('Erro ao compartilhar relatório: $e');
      throw Exception('Erro ao compartilhar relatório: $e');
    }
  }
}
