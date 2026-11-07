#!/usr/bin/env python3
"""Chuyển chuỗi UI của RESEARCH thành ARB cho Flutter (T-081, T-074).

Chạy:  python mobile/tool/gen_arb.py
Đọc:   content/i18n/vi.json   (NGUỒN DUY NHẤT; RESEARCH sở hữu)
Ghi:   mobile/lib/l10n/app_vi.arb   (rồi chạy `flutter gen-l10n`)

Quy tắc:
  - Khóa "onboarding.body.age" → "onboardingBodyAge" (camelCase, mỗi đoạn viết hoa chữ đầu).
  - Chỗ giữ `{{name}}` kiểu i18next → `{name}` ICU; mỗi tên là một placeholder kiểu Object.
    Chuỗi có từ 2 placeholder trở lên đổi tên thành v1, v2… theo thứ tự xuất hiện (gen-l10n sắp tham số theo tên).
  - Hai khóa trùng tên ARB sau khi camelCase → lỗi (dừng).
  - Kiểm tra ngược: mọi `l.xxx` / `AppL10n.of(context).xxx` trong mobile/lib phải có trong ARB, nếu không → lỗi
    (chuỗi mới của app phải được thêm vào content/i18n/vi.json, không thêm vào mobile/).
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'content' / 'i18n' / 'vi.json'
OUT = ROOT / 'mobile' / 'lib' / 'l10n' / 'app_vi.arb'
LIB = ROOT / 'mobile' / 'lib'

# Thành viên của lớp AppL10n không phải chuỗi.
NON_STRING_MEMBERS = {'localeName', 'delegate', 'of', 'supportedLocales', 'localizationsDelegates'}
PLACEHOLDER = re.compile(r'\{\{\s*(\w+)\s*\}\}|\{(\w+)\}')


def flatten(o, pre=''):
    if isinstance(o, dict):
        for k, v in o.items():
            yield from flatten(v, f'{pre}{k}.')
    else:
        yield pre[:-1], o


def camel(key: str) -> str:
    parts = [p for p in re.split(r'[._]', key) if p]
    return parts[0] + ''.join(p[:1].upper() + p[1:] for p in parts[1:])


def convert(value: str):
    """Trả (chuỗi ICU, danh sách tên placeholder)."""
    names = []
    for m in PLACEHOLDER.finditer(value):
        n = m.group(1) or m.group(2)
        if n not in names:
            names.append(n)
    rename = {n: (f'v{i + 1}' if len(names) > 1 else n) for i, n in enumerate(names)}
    icu = PLACEHOLDER.sub(lambda m: '{' + rename[m.group(1) or m.group(2)] + '}', value)
    return icu, [rename[n] for n in names]


def used_keys():
    """Tên getter/hàm AppL10n mà mã Dart dùng, theo từng file."""
    pat = re.compile(r'\b(?:l|l10n|AppL10n\.of\(\s*\w+\s*\))\.([a-z][A-Za-z0-9]*)')
    out = {}
    for f in LIB.rglob('*.dart'):
        if 'l10n' in f.relative_to(LIB).parts[:2] and 'gen' in f.parts:
            continue
        text = f.read_text(encoding='utf-8')
        if 'app_localizations.dart' not in text and 'AppL10n' not in text:
            continue
        for m in pat.finditer(text):
            out.setdefault(m.group(1), f.relative_to(ROOT).as_posix())
    return out


def main():
    if not SOURCE.exists():
        sys.exit(f'không thấy nguồn i18n: {SOURCE.relative_to(ROOT)}')
    arb = {'@@locale': 'vi'}
    meta = {}
    seen = {}
    for key, val in flatten(json.loads(SOURCE.read_text(encoding='utf-8'))):
        if not isinstance(val, str):
            continue
        k = camel(key)
        if k in seen:
            sys.exit(f'trùng khóa ARB: {k} ({seen[k]} và {key})')
        seen[k] = key
        icu, names = convert(val)
        arb[k] = icu
        if names:
            meta['@' + k] = {'placeholders': {nm: {'type': 'Object'} for nm in names}}
    arb.update(meta)

    missing = {k: f for k, f in used_keys().items() if k not in arb and k not in NON_STRING_MEMBERS}
    if missing:
        for k, f in sorted(missing.items()):
            print(f'  thiếu trong {SOURCE.relative_to(ROOT)}: {k} (dùng ở {f})', file=sys.stderr)
        sys.exit(f'{len(missing)} khóa mã đang dùng nhưng không có trong nguồn i18n')

    OUT.write_text(json.dumps(arb, ensure_ascii=False, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(f'ok: {len(seen)} chuỗi từ {SOURCE.relative_to(ROOT)} → {OUT.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
