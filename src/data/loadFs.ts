// Đọc bộ dữ liệu từ thư mục trên đĩa (chỉ dùng cho script/Node; engine không import file này).
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import type { RawDataset } from './load.ts';

export function readRawDataset(dir: string): RawDataset {
  const rd = (name: string): unknown => JSON.parse(readFileSync(join(dir, `${name}.json`), 'utf8'));
  return { ingredients: rd('ingredients'), recipes: rd('recipes'), stores: rd('stores'), prices: rd('prices') };
}

export function readTestProfiles(file: string): unknown {
  return JSON.parse(readFileSync(file, 'utf8'));
}
