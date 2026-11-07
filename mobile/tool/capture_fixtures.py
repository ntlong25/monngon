#!/usr/bin/env python3
"""Chụp phản hồi thật từ API đang chạy (http://localhost:5095) thành fixture cho test hợp đồng.

Chạy:  python mobile/tool/capture_fixtures.py [base_url]
Ghi:   mobile/test/fixtures/*.json  (dùng cho test hợp đồng; test giao diện dùng bản cố định ở test/fixtures/ui/, xem README ở đó)
Dùng hồ sơ p01 trong data/test-profiles.json làm đầu vào.
"""
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'mobile' / 'test' / 'fixtures'
BASE = sys.argv[1] if len(sys.argv) > 1 else 'http://localhost:5095'


def call(method, path, body=None):
    data = None if body is None else json.dumps(body).encode('utf-8')
    req = urllib.request.Request(BASE + path, data=data, method=method, headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode('utf-8'))


def save(name, obj):
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / name).write_text(json.dumps(obj, ensure_ascii=False, indent=1), encoding='utf-8', newline='\n')
    print('wrote', name)


def main():
    profiles = json.loads((ROOT / 'data' / 'test-profiles.json').read_text(encoding='utf-8'))
    items = profiles['profiles'] if isinstance(profiles, dict) else profiles
    p = items[0]
    profile, prefs = p['profile'], p['preferences']
    save('reference.json', call('GET', '/v1/reference'))
    save('ingredients_search.json', call('GET', '/v1/ingredients?q=ga&limit=5'))
    targets = call('POST', '/v1/targets', {'profile': profile})
    save('targets.json', targets)
    save('slots_preview.json', call('POST', '/v1/slots/preview', {'profile': profile, 'slots': prefs['slots']}))
    save('budget_range.json', call('POST', '/v1/budget-range', {'targets': {'kcal_target': targets['kcal_target'], 'protein_g': targets['protein_g']}, 'preferences': prefs}))
    plan = call('POST', '/v1/plans', {'profile': profile, 'preferences': prefs, 'start_date': '2026-11-09', 'seed': 1})
    save('plan_response.json', plan)
    meals = [
        {'ingredients': [{'ingredient_id': g['ingredient_id'], 'grams': g['grams'], 'standard_grams': s['grams']} for g, s in zip(m['grams'], m['standard_grams'])], 'eaten_out': False}
        for d in plan['plan']['days'] for m in d['meals'] if m['status'] == 'planned'
    ][:6]
    save('shopping_list.json', call('POST', '/v1/shopping-list', {'meals': meals, 'store_id': prefs['store_id'], 'adults': prefs['adults'], 'children': prefs['children'], 'pantry_ids': []}))
    rid = next(m['recipe_id'] for d in plan['plan']['days'] for m in d['meals'] if m['status'] == 'planned' and not m['recipe_id'].startswith('mam:'))
    save('recipe_detail.json', call('GET', '/v1/recipes/' + rid))
    save('plan_request.json', {'profile': profile, 'preferences': prefs, 'start_date': '2026-11-09', 'seed': 1})


if __name__ == '__main__':
    main()
