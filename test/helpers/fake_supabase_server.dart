import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Minimal in-memory stand-in for Supabase's REST API (PostgREST), enough for
/// the queries VaultRepository and KeyHierarchyManager make. It does not
/// enforce row-level security; the app filters by user id itself.
///
/// Every `/auth/v1/*` request fails like a wrong-password login.
class FakeSupabaseServer {
  final Map<String, List<Map<String, dynamic>>> tables = {};
  final List<http.Request> requests = [];
  int _idCounter = 0;
  bool offline = false;

  List<Map<String, dynamic>> table(String name) => tables.putIfAbsent(name, () => []);

  late final http.Client client = MockClient(_handle);

  Future<http.Response> _handle(http.Request request) async {
    final response = await _route(request);
    // The postgrest client reads response.request, which MockClient leaves null.
    return http.Response.bytes(response.bodyBytes, response.statusCode, headers: response.headers, request: request);
  }

  Future<http.Response> _route(http.Request request) async {
    requests.add(request);
    if (offline) throw http.ClientException('Network unreachable (fake)');

    final segments = request.url.pathSegments;
    if (segments.length >= 2 && segments[0] == 'auth') {
      return _json({'code': 400, 'error_code': 'invalid_credentials', 'msg': 'Invalid login credentials'}, 400);
    }
    if (segments.length < 3 || segments[0] != 'rest') {
      return _json({'message': 'Not found'}, 404);
    }

    final name = segments[2];
    final params = request.url.queryParameters;
    final filters = Map.of(params)..removeWhere((k, _) => const {'select', 'order', 'limit', 'offset', 'on_conflict', 'columns'}.contains(k));

    switch (request.method) {
      case 'GET':
        var rows = table(name).where((r) => _matches(r, filters)).map(Map<String, dynamic>.of).toList();
        rows = _order(rows, params['order']);
        if (params['limit'] != null) rows = rows.take(int.parse(params['limit']!)).toList();
        if ((params['select'] ?? '').contains('document_metadata(')) {
          for (final r in rows) {
            r['document_metadata'] = table('document_metadata').where((m) => m['document_id'] == r['id']).toList();
          }
        }
        return _json(rows, 200);

      case 'POST':
        final body = jsonDecode(request.body);
        final incoming = (body is List ? body : [body]).cast<Map<String, dynamic>>();
        final prefer = request.headers['Prefer'] ?? request.headers['prefer'] ?? '';
        final conflictCols = params['on_conflict']?.split(',');
        final written = <Map<String, dynamic>>[];
        for (final row in incoming) {
          Map<String, dynamic>? existing;
          if (prefer.contains('merge-duplicates') && conflictCols != null) {
            existing = table(name).cast<Map<String, dynamic>?>().firstWhere(
                  (r) => conflictCols.every((c) => '${r![c]}' == '${row[c]}'),
                  orElse: () => null,
                );
          } else if (prefer.contains('merge-duplicates') && row['id'] != null) {
            existing = table(name).cast<Map<String, dynamic>?>().firstWhere((r) => r!['id'] == row['id'], orElse: () => null);
          }
          if (existing != null) {
            existing.addAll(row);
            written.add(existing);
          } else {
            final created = {
              'id': 'id-${++_idCounter}',
              'created_at': DateTime.utc(2026, 1, 1).add(Duration(seconds: _idCounter)).toIso8601String(),
              ...row,
            };
            table(name).add(created);
            written.add(created);
          }
        }
        if (prefer.contains('return=representation')) return _json(written, 201);
        return http.Response('', 201);

      case 'DELETE':
        table(name).removeWhere((r) => _matches(r, filters));
        return http.Response('', 204);

      default:
        return _json({'message': 'Unsupported ${request.method}'}, 405);
    }
  }

  static bool _matches(Map<String, dynamic> row, Map<String, String> filters) {
    return filters.entries.every((f) {
      if (!f.value.startsWith('eq.')) return true;
      return '${row[f.key]}' == f.value.substring(3);
    });
  }

  static List<Map<String, dynamic>> _order(List<Map<String, dynamic>> rows, String? order) {
    if (order == null) return rows;
    final parts = order.split('.');
    final col = parts.first;
    final desc = parts.contains('desc');
    rows.sort((a, b) {
      final c = '${a[col]}'.compareTo('${b[col]}');
      return desc ? -c : c;
    });
    return rows;
  }

  static http.Response _json(Object body, int status) => http.Response(
        jsonEncode(body),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
}
