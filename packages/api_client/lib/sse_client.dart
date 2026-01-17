import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EventStreamTerminated extends Error {}

class ServerSentEvent {
  final String? data;
  final String? event;
  final String? id;

  ServerSentEvent({required this.data, required this.event, required this.id});

  @override
  String toString() {
    return 'ServerSentEvent{event: $event, data: $data, id: $id}';
  }
}

class EventStream {
  final Uri uri;
  String? data;
  String? event;
  String? id;

  EventStream(this.uri);

  Future<Stream<ServerSentEvent>> connect() async {
    final response = await http.Client().send(http.Request("GET", uri));
    return response.stream
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .transform(
          StreamTransformer.fromHandlers(
            handleData: onStreamedLine,
            handleError: onError,
          ),
        );
  }

  onStreamedLine(String line, EventSink<ServerSentEvent> sink) {
    if (line.trim().isEmpty) {
      if (event != null || data != null || id != null) {
        sink.add(ServerSentEvent(data: data, event: event, id: id));
        event = data = id = null;
      } else {
        if (kDebugMode) {
          print('WTF double newline');
        }
      }
    } else {
      extractFieldValue(line);
    }
  }

  extractFieldValue(String line) {
    final fieldLabelIndexExclusive = line.indexOf(':');
    if (fieldLabelIndexExclusive == -1) {
      if (kDebugMode) {
        print('WTF not valid sse protocol line: $line');
      }
    }
    final value = line.substring(fieldLabelIndexExclusive + 1).trim();
    switch (line.substring(0, fieldLabelIndexExclusive)) {
      case 'event':
        event = value;
        break;
      case 'data':
        data = value;
        break;
      case 'id':
        id = value;
        break;
      default:
        if (kDebugMode) {
          print('WTF not valid sse protocol field: $line');
        }
    }
  }

  onError(e, stackTrace, sink) {
    if (e is http.ClientException &&
        e.message.startsWith('Connection closed')) {
      sink.addError(EventStreamTerminated());
    } else {
      sink.addError(e, stackTrace);
    }
  }
}
