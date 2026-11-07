#!/usr/bin/env python3
"""Chạy dotnet test và kiểm tra số test đã chạy đủ (phát hiện test host bị dừng giữa chừng).

Vì sao cần: khi tiến trình `testhost` bị giết giữa chừng (vd `taskkill /IM testhost.exe` của một session khác,
hoặc tắt máy/timeout), `dotnet test` vẫn in một dòng "Passed! ... Total: N" với N là số test đã chạy tới lúc đó,
rồi mới in "Test Run Aborted". Chỉ nhìn dòng "Passed!" sẽ thấy xanh nhưng thiếu test.

Cách dùng (từ thư mục backend/ hoặc gốc repo):
    python backend/check-tests.py                 # build + chạy từng dự án, tuần tự
    python backend/check-tests.py --no-build
    python backend/check-tests.py --update-baseline   # sau khi cố ý thêm/xóa test, ghi lại số test chuẩn

Thất bại (mã thoát ≠ 0) khi: dotnet test lỗi/aborted, không có file kết quả, số đã chạy < số khám phá được,
có test không đạt, hoặc tổng số test < chuẩn trong backend/test-baseline.json.
"""
import json
import re
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASELINE = HERE / 'test-baseline.json'
PROJECTS = ['MonNgon.Engine.Tests', 'MonNgon.Api.Tests']


def run(cmd):
    p = subprocess.run(cmd, cwd=HERE, capture_output=True, text=True, encoding='utf-8', errors='replace')
    return p.returncode, p.stdout + p.stderr


def discovered(proj, no_build):
    code, out = run(['dotnet', 'test', proj, '--list-tests'] + (['--no-build'] if no_build else []))
    if code != 0:
        return None
    return sum(1 for line in out.splitlines() if re.match(r'^    \S', line))


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    no_build = '--no-build' in sys.argv
    update = '--update-baseline' in sys.argv
    baseline = json.loads(BASELINE.read_text(encoding='utf-8')) if BASELINE.exists() else {}
    problems, counts = [], {}
    for proj in PROJECTS:
        with tempfile.TemporaryDirectory() as tmp:
            code, out = run(['dotnet', 'test', proj] + (['--no-build'] if no_build else []) + ['--logger', 'trx;LogFileName=r.trx', '--results-directory', tmp])
            trx = Path(tmp) / 'r.trx'
            if 'Test Run Aborted' in out or 'Test host process crashed' in out:
                problems.append(f'{proj}: test run bị dừng giữa chừng (testhost crashed/aborted)')
            if code != 0:
                problems.append(f'{proj}: dotnet test thoát mã {code}')
            if not trx.exists():
                problems.append(f'{proj}: không có file kết quả .trx')
                continue
            c = ET.parse(trx).getroot().find('.//{*}Counters')
            total, executed, passed = int(c.get('total')), int(c.get('executed')), int(c.get('passed'))
            counts[proj] = total
            print(f'{proj}: total={total} executed={executed} passed={passed}')
            if executed < total or passed < executed:
                problems.append(f'{proj}: chạy {executed}/{total}, đạt {passed}')
        d = discovered(proj, True)
        if d is not None and d != counts.get(proj):
            problems.append(f'{proj}: khám phá được {d} test nhưng báo cáo {counts.get(proj)}')
        floor = baseline.get(proj)
        if floor is not None and counts.get(proj, 0) < floor and not update:
            problems.append(f'{proj}: {counts.get(proj)} test < chuẩn {floor} (mất test? nếu cố ý: --update-baseline)')
    if update and not problems:
        BASELINE.write_text(json.dumps(counts, indent=2) + '\n', encoding='utf-8')
        print('đã ghi', BASELINE.name, counts)
    if problems:
        print('\nKIỂM TRA SỐ TEST THẤT BẠI:')
        for p in problems:
            print(' -', p)
        sys.exit(1)
    print('OK: đủ số test, tất cả đạt.')


if __name__ == '__main__':
    main()
