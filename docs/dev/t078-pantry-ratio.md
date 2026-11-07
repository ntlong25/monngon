# T-078 — Tỉ lệ "trả tại quầy / chi phí món ăn" trên 16 hồ sơ

Seed 1, chế độ auto, dữ liệu sau đợt D1 (07/11/2026), sau khi bỏ đồ nhà có sẵn khỏi con số tại quầy (D-SHP-01) và quy cơm ra gạo sống (D-SHP-02, hệ số 0,36). Nguồn: `dotnet run --project backend/MonNgon.Tools -- engine-report`.
`Trả tại quầy` không gồm các nguyên liệu `default_pantry` (kể cả gạo tẻ); `chi phí món ăn` vẫn gồm gram đã dùng của mọi nguyên liệu nên không đổi khi bật/tắt pantry (test: `ShoppingList_pantry_ids_khong_gui_…`, `Plans_auto_till_cost_khong_gom_…`, `PurchaseAsTests`).

| Hồ sơ | Chi phí món ăn | Ngân sách | Trả tại quầy | Tỉ lệ |
|---|---:|---:|---:|---:|
| p01_nu_giam_mo_vua — Nữ giảm mỡ, ngân sách vừa | 594.000 ₫ | 650.000 ₫ | 864.000 ₫ | 1,45 |
| p02_nu_nho_can_giam_mo_1350 — Nữ nhỏ cân giảm mỡ 1.350 kcal / 110 g | 512.000 ₫ | 600.000 ₫ | 820.000 ₫ | 1,60 |
| p03_nam_tang_co_2800 — Nam tăng cơ 2.800 kcal | 631.000 ₫ | 1.000.000 ₫ | 945.000 ₫ | 1,50 |
| p04_nam_giu_can — Nam giữ cân, tự tính chỉ tiêu | 518.000 ₫ | 800.000 ₫ | 793.000 ₫ | 1,53 |
| p05_thuan_chay_it_tinh_bot — Thuần chay, ít tinh bột | 399.000 ₫ | 550.000 ₫ | 474.000 ₫ | 1,19 |
| p06_chay_lacto_nu — Ăn chay (có trứng, sữa) | 463.000 ₫ | 600.000 ₫ | 692.000 ₫ | 1,49 |
| p07_khong_lon_khong_sua — Không lợn, không sữa | 552.000 ₫ | 700.000 ₫ | 858.000 ₫ | 1,55 |
| p08_di_ung_lac_hat_cay — Dị ứng lạc và hạt cây | 457.000 ₫ | 700.000 ₫ | 717.000 ₫ | 1,57 |
| p09_chi_co_lo_vi_song — Chỉ có lò vi sóng | 585.000 ₫ | 600.000 ₫ | 799.000 ₫ | 1,37 |
| p10_ngan_sach_toi_thieu — Ngân sách tối thiểu (600.000 ₫) | 543.000 ₫ | 600.000 ₫ | 814.000 ₫ | 1,50 |
| p11_ho_2_nguoi_lon_2_tre — Hộ 2 người lớn + 2 trẻ em | 1.485.000 ₫ | 1.500.000 ₫ | 1.423.000 ₫ | 0,96 |
| p12_bua_sang_tu_lo — Bữa sáng tự lo | 506.000 ₫ | 700.000 ₫ | 858.000 ₫ | 1,70 |
| p13_nhieu_mon_ghet — Nhiều món không thích | 554.000 ₫ | 650.000 ₫ | 883.000 ₫ | 1,59 |
| p14_ho_3_nguoi_lon — Hộ 3 người lớn, ít dụng cụ | 1.197.000 ₫ | 1.200.000 ₫ | 1.262.000 ₫ | 1,05 |
| p15_chi_noi_chien_va_noi_com — Chỉ có nồi chiên không dầu và nồi cơm điện | 1.182.000 ₫ | 1.200.000 ₫ | 1.236.000 ₫ | 1,05 |
| p16_chi_bep_va_noi_chien — Chỉ có bếp và nồi chiên không dầu | 691.000 ₫ | 900.000 ₫ | 845.000 ₫ | 1,22 |

**10/16 hồ sơ có tỉ lệ ≤ 1,5** (AC kỳ vọng: đa số). Trung bình 1,40, lớn nhất 1,70. Trên 1,5: p02, p04, p07, p08, p12, p13; chưa phân tích nguyên nhân chi tiết (nghi do mua nguyên gói đồ tươi).
