#!/usr/bin/env python3
"""Sinh client Dart từ backend/openapi/openapi.json (T-080).

Chạy:  python mobile/tool/gen_client.py        (từ gốc repo hoặc thư mục mobile/)
Sinh:  mobile/lib/api/generated/models.dart
       mobile/lib/api/generated/api_client.dart

Không phụ thuộc build_runner; model là lớp bất biến thuần Dart với fromJson/toJson.
Quy ước đọc lỏng (server luôn gửi đủ trường, trừ trường null bị bỏ):
  - trường không-null mà thiếu → giá trị mặc định (0, '', false, [], {}, đối tượng rỗng)
  - trường nullable thiếu → null
Test hợp đồng (test/api/contract_test.dart) kiểm client sinh ra khớp openapi.json.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'backend' / 'openapi' / 'openapi.json'
OUT = ROOT / 'mobile' / 'lib' / 'api' / 'generated'

RESERVED = {
    'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch', 'class', 'const', 'continue', 'covariant',
    'default', 'deferred', 'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension', 'external', 'factory',
    'false', 'final', 'finally', 'for', 'function', 'get', 'hide', 'if', 'implements', 'import', 'in', 'interface',
    'is', 'late', 'library', 'mixin', 'new', 'null', 'on', 'operator', 'part', 'required', 'rethrow', 'return', 'set',
    'show', 'static', 'super', 'switch', 'sync', 'this', 'throw', 'true', 'try', 'typedef', 'var', 'void', 'while',
    'with', 'yield',
}


def camel(name: str) -> str:
    parts = name.split('_')
    s = parts[0] + ''.join(p[:1].upper() + p[1:] for p in parts[1:])
    return s + '_' if s in RESERVED else s


class T:
    """Kiểu Dart suy ra từ một schema."""

    def __init__(self, kind, nullable=False, ref=None, item=None, prim=None):
        self.kind = kind  # prim | ref | list | map
        self.nullable = nullable
        self.ref = ref
        self.item = item
        self.prim = prim

    def dart(self):
        base = {
            'prim': self.prim,
            'ref': self.ref,
            'list': f'List<{self.item.dart() if self.item else "dynamic"}>',
            'map': f'Map<String, {self.item.dart() if self.item else "dynamic"}>',
        }[self.kind]
        return base + ('?' if self.nullable else '')


def parse_type(p: dict) -> T:
    nullable = False
    if 'oneOf' in p or 'anyOf' in p:
        alts = p.get('oneOf') or p.get('anyOf')
        non_null = [a for a in alts if a.get('type') != 'null']
        nullable = len(non_null) != len(alts)
        if len(non_null) != 1:
            return T('prim', nullable, prim='Object')
        t = parse_type(non_null[0])
        t.nullable = nullable or t.nullable
        return t
    if '$ref' in p:
        return T('ref', ref=p['$ref'].split('/')[-1])
    ty = p.get('type')
    if isinstance(ty, list):
        nullable = 'null' in ty
        rest = [x for x in ty if x != 'null']
        ty = rest[0] if rest else 'string'
    if ty == 'string':
        return T('prim', nullable, prim='String')
    if ty == 'integer':
        return T('prim', nullable, prim='int')
    if ty == 'number':
        return T('prim', nullable, prim='double')
    if ty == 'boolean':
        return T('prim', nullable, prim='bool')
    if ty == 'array':
        return T('list', nullable, item=parse_type(p.get('items', {})))
    if ty == 'object' or 'additionalProperties' in p:
        ap = p.get('additionalProperties')
        return T('map', nullable, item=parse_type(ap) if isinstance(ap, dict) else T('prim', prim='Object'))
    return T('prim', nullable, prim='Object')


def default_expr(t: T, schemas) -> str:
    if t.kind == 'prim':
        return {'String': "''", 'int': '0', 'double': '0', 'bool': 'false', 'Object': 'null'}[t.prim]
    if t.kind == 'list':
        return 'const []'
    if t.kind == 'map':
        return 'const {}'
    return f'const {t.ref}()'


def from_json_expr(t: T, src: str) -> str:
    """Biểu thức Dart đọc `src` (kiểu dynamic) thành kiểu t (không-null; nullable xử lý ở ngoài)."""
    if t.kind == 'prim':
        if t.prim == 'String':
            return f'{src} as String'
        if t.prim == 'int':
            return f'({src} as num).toInt()'
        if t.prim == 'double':
            return f'({src} as num).toDouble()'
        if t.prim == 'bool':
            return f'{src} as bool'
        return src
    if t.kind == 'ref':
        return f'{t.ref}.fromJson({src} as Map<String, dynamic>)'
    if t.kind == 'list':
        inner = from_json_expr(t.item, 'e')
        if t.item.kind == 'prim' and t.item.prim == 'String':
            return f'({src} as List<dynamic>).cast<String>().toList()'
        return f'({src} as List<dynamic>).map((e) => {inner}).toList()'
    inner = from_json_expr(t.item, 'v')
    return f'({src} as Map<String, dynamic>).map((k, v) => MapEntry(k, {inner}))'


def to_json_expr(t: T, src: str, nullable_src: bool) -> str:
    bang = '!' if nullable_src else ''
    if t.kind == 'prim':
        return src
    if t.kind == 'ref':
        return f'{src}{"?" if nullable_src else ""}.toJson()'
    if t.kind == 'list':
        if t.item.kind == 'prim':
            return src
        return f'{src}{bang}.map((e) => {to_json_expr(t.item, "e", False)}).toList()'
    if t.item.kind == 'prim':
        return src
    return f'{src}{bang}.map((k, v) => MapEntry(k, {to_json_expr(t.item, "v", False)}))'


def gen_models(schemas) -> str:
    out = [
        '// GENERATED FILE — KHÔNG SỬA TAY. Sinh bởi mobile/tool/gen_client.py từ backend/openapi/openapi.json.',
        '// ignore_for_file: unnecessary_cast, prefer_const_constructors, unused_element, unnecessary_this',
        '',
    ]
    for name in sorted(schemas):
        s = schemas[name]
        props = s.get('properties', {})
        fields = []
        for key, p in props.items():
            t = parse_type(p)
            fields.append((key, camel(key), t))
        out.append(f'/// Schema `{name}`.')
        out.append(f'class {name} {{')
        if fields:
            out.append(f'  const {name}({{')
            for key, f, t in fields:
                if t.nullable:
                    out.append(f'    this.{f},')
                else:
                    out.append(f'    this.{f} = {default_expr(t, schemas)},')
            out.append('  });')
        else:
            out.append(f'  const {name}();')
        out.append('')
        out.append(f'  factory {name}.fromJson(Map<String, dynamic> json) => {name}(')
        for key, f, t in fields:
            src = f"json['{key}']"
            if t.nullable:
                out.append(f'        {f}: {src} == null ? null : {from_json_expr(t, src)},')
            else:
                d = default_expr(t, schemas)
                if t.kind == 'prim' and t.prim in ('double', 'int'):
                    out.append(f'        {f}: {src} == null ? {d} : {from_json_expr(t, src)},')
                else:
                    out.append(f'        {f}: {src} == null ? {d} : {from_json_expr(t, src)},')
        out.append('      );')
        out.append('')
        for key, f, t in fields:
            out.append(f'  final {t.dart()} {f};')
        if fields:
            out.append('')
        if fields:
            out.append('')
            out.append(f'  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).')
            out.append(f'  {name} copyWith({{')
            for key, f, t in fields:
                base = t.dart().rstrip('?')
                out.append(f'    {base}? {f},')
            out.append('  }) =>')
            out.append(f'      {name}(')
            for key, f, t in fields:
                out.append(f'        {f}: {f} ?? this.{f},')
            out.append('      );')
            out.append('')
        out.append('  Map<String, dynamic> toJson() => {')
        for key, f, t in fields:
            if t.nullable:
                out.append(f"        if ({f} != null) '{key}': {to_json_expr(t, f, True)},")
            else:
                out.append(f"        '{key}': {to_json_expr(t, f, False)},")
        out.append('      };')
        out.append('}')
        out.append('')
    return '\n'.join(out)


def op_name(op_id: str) -> str:
    return op_id[:1].lower() + op_id[1:]


def gen_client(spec) -> str:
    schemas = spec['components']['schemas']
    out = [
        '// GENERATED FILE — KHÔNG SỬA TAY. Sinh bởi mobile/tool/gen_client.py từ backend/openapi/openapi.json.',
        '// ignore_for_file: unnecessary_cast',
        '',
        "import 'package:dio/dio.dart';",
        '',
        "import 'models.dart';",
        '',
        '/// Lỗi API: HTTP != 2xx hoặc không kết nối được.',
        'class ApiException implements Exception {',
        '  const ApiException({this.statusCode, this.title, this.detail, this.fieldErrors = const {}, this.cause});',
        '',
        '  /// null nếu không có phản hồi (mất mạng, hết thời gian chờ).',
        '  final int? statusCode;',
        '  final String? title;',
        '  final String? detail;',
        '',
        '  /// Lỗi theo trường (RFC 7807 `errors`), khóa là đường dẫn trường.',
        '  final Map<String, List<String>> fieldErrors;',
        '  final Object? cause;',
        '',
        '  bool get isNetwork => statusCode == null;',
        '',
        '  @override',
        "  String toString() => 'ApiException(${statusCode ?? 'network'}: ${title ?? detail ?? cause})';",
        '}',
        '',
        '/// Client API v1 (sinh từ OpenAPI).',
        'class MonNgonApi {',
        '  MonNgonApi(this.dio);',
        '',
        '  final Dio dio;',
        '',
        '  /// `/health` không nằm trong OpenAPI (ExcludeFromDescription) nhưng app dùng để kiểm kết nối.',
        '  Future<bool> health() async {',
        "    final r = await _send<Map<String, dynamic>>('GET', '/health');",
        "    return r['status'] == 'ok';",
        '  }',
        '',
    ]
    for path, methods in spec['paths'].items():
        for method, op in methods.items():
            name = op_name(op['operationId'])
            params = op.get('parameters', [])
            body_ref = None
            if 'requestBody' in op:
                body_ref = parse_type(op['requestBody']['content']['application/json']['schema'])
            ok = op['responses']['200']['content']['application/json']['schema']
            rt = parse_type(ok)
            args = []
            for prm in params:
                pt = parse_type(prm['schema'])
                pname = camel(prm['name'])
                if prm['in'] == 'path':
                    args.append(('path', prm['name'], pname, pt.dart(), True))
                else:
                    args.append(('query', prm['name'], pname, pt.dart().rstrip('?') + '?', False))
            sig = []
            pos = [a for a in args if a[4]]
            named = [a for a in args if not a[4]]
            if body_ref is not None:
                sig.append(f'{body_ref.dart()} body')
            for a in pos:
                sig.append(f'{a[3]} {a[2]}')
            if named:
                sig.append('{' + ', '.join(f'{a[3]} {a[2]}' for a in named) + '}')
            url = "'" + path + "'"
            for a in pos:
                url = url.replace('{' + a[1] + '}', '${Uri.encodeComponent(' + a[2] + ')}')
            q = [a for a in args if a[0] == 'query']
            qs = ''
            if q:
                qs = ", query: {" + ', '.join(f"'{a[1]}': ?{a[2]}" for a in q) + '}'
            data = ", data: body.toJson()" if body_ref is not None else ''
            out.append(f'  /// `{method.upper()} {path}`')
            out.append(f'  Future<{rt.dart()}> {name}({", ".join(sig)}) async {{')
            if rt.kind == 'list':
                out.append(f"    final r = await _send<List<dynamic>>('{method.upper()}', {url}{qs}{data});")
                out.append(f"    return r.map((e) => {rt.item.ref}.fromJson(e as Map<String, dynamic>)).toList();")
            else:
                out.append(f"    final r = await _send<Map<String, dynamic>>('{method.upper()}', {url}{qs}{data});")
                out.append(f'    return {rt.ref}.fromJson(r);')
            out.append('  }')
            out.append('')
    out += [
        '  Future<T> _send<T>(String method, String path, {Map<String, dynamic>? query, Object? data}) async {',
        '    try {',
        '      final r = await dio.request<T>(path, data: data, queryParameters: query, options: Options(method: method));',
        '      final body = r.data;',
        '      if (body == null) {',
        '        throw ApiException(statusCode: r.statusCode, title: \'Phản hồi rỗng\');',
        '      }',
        '      return body;',
        '    } on DioException catch (e) {',
        '      throw _toApiException(e);',
        '    }',
        '  }',
        '',
        '  static ApiException _toApiException(DioException e) {',
        '    final res = e.response;',
        '    if (res == null) return ApiException(cause: e.error ?? e.message);',
        '    final data = res.data;',
        '    if (data is Map<String, dynamic>) {',
        '      final errs = <String, List<String>>{};',
        "      final raw = data['errors'];",
        '      if (raw is Map<String, dynamic>) {',
        '        raw.forEach((k, v) => errs[k] = (v as List<dynamic>).map((x) => x.toString()).toList());',
        '      }',
        "      return ApiException(statusCode: res.statusCode, title: data['title'] as String?, detail: data['detail'] as String?, fieldErrors: errs);",
        '    }',
        '    return ApiException(statusCode: res.statusCode, title: res.statusMessage);',
        '  }',
        '}',
        '',
    ]
    return '\n'.join(out)


def main():
    spec = json.loads(SPEC.read_text(encoding='utf-8'))
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / 'models.dart').write_text(gen_models(spec['components']['schemas']), encoding='utf-8', newline='\n')
    (OUT / 'api_client.dart').write_text(gen_client(spec), encoding='utf-8', newline='\n')
    print(f'ok: {len(spec["components"]["schemas"])} schemas, {sum(len(v) for v in spec["paths"].values())} operations -> {OUT}')


if __name__ == '__main__':
    sys.exit(main())
