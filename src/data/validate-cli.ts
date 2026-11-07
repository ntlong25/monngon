// npm run validate-data [-- <thư mục>]   (mặc định: data)
import { formatIssue, validateDataset } from './validate.ts';
import { readRawDataset } from './loadFs.ts';

const dir = process.argv[2] ?? 'data';
let issues;
try {
  issues = validateDataset(readRawDataset(dir));
} catch (e) {
  console.error(`Không đọc được dữ liệu trong "${dir}": ${(e as Error).message}`);
  process.exit(2);
}
for (const i of issues) console.log(formatIssue(i));
const errors = issues.filter((i) => i.severity === 'error').length;
console.log(`\n${dir}: ${errors} lỗi, ${issues.length - errors} cảnh báo.`);
process.exit(errors > 0 ? 1 : 0);
