create database bai5
use bai5

-- 1. Viết các câu lệnh tạo các bảng với các ràng buộc nêu trong đề bài. Dựa vào bảng dữ liệu để chọn kiểu dữ liệu phù hợp

create table SACH (
	MaSach varchar(10) primary key,
	TenSach nvarchar(50) not null,
	Namxb int not null
)

create table DOCGIA (
	MaDg varchar(10) primary key,
	HoTen nvarchar(50) not null,
	GioiTinh nvarchar(10) not null,
	NgaySinh date not null,
)

create table PHIEUMUON (
	MaDg varchar(10),
	MaSach varchar(10),
	NgayMuon date not null, check(NgayMuon <= getdate() and NgayMuon < NgayTra),
	NgayTra date not null,
	SoLuong int check(SoLuong between 1 and 5) not null,
	primary key (MaDg, MaSach),
	constraint fk_mdg foreign key (MaDg) references DOCGIA(MaDg),
	constraint fk_ms foreign key (MaSach) references SACH(MaSach)
)

-- 2. Viết câu lệnh nhập dữ liệu vào các bảng

insert SACH (MaSach,TenSach, Namxb)
values
	('S01', N'Giải tích 1', 2000),
	('S02', N'Đại số tuyến tính', 2020),
	('S03', N'Hình học Afin', 2010),
	('S04', N'Hóa học', 2019),
	('S05', N'Tin học', 2020);

insert DOCGIA (MaDg, HoTen, GioiTinh, NgaySinh)
values
	('DG01', N'Phạm Văn Bình', N'Nam', '1990-03-24'),
	('DG02', N'Nguyễn Thị Hoài', N'Nữ', '1991-04-06'),
	('DG03', N'Trần Ngọc', N'Nam', '1990-05-15'),
	('DG04', N'Nguyễn Tấn', N'Nam', '1992-12-23'),
	('DG05', N'Trương Mận', N'Nữ', '1990-12-04')

insert PHIEUMUON (MaDg, MaSach, NgayMuon, NgayTra, SoLuong)
values
	('DG01','S01','2024-02-01','2024-06-03',1),
	('DG02','S02','2024-02-15','2024-05-03',2),
	('DG03','S03','2024-04-17','2024-07-13',1),
	('DG01','S02','2024-04-01','2024-08-13',3),
	('DG02','S03','2024-01-15','2024-06-03',2),
	('DG04','S05','2024-05-15','2024-07-03',1)

-- 3. Viết câu lệnh thêm ràng buộc cho bảng DOCGIA với điều kiện giới tính Nam hoặc Nữ
alter table DOCGIA
add constraint dk_gt check(GioiTinh in (N'Nam', N'Nữ'))

-- 4. Viết câu lệnh chèn thêm cột SoLuong vào bảng SACH, sau đó nhập dữ liệu cho cột SoLuong
alter table SACH
add SoLuong int

update SACH set SoLuong = 10 where MaSach = 'S01'
update SACH set SoLuong = 13 where MaSach = 'S02'
update SACH set SoLuong = 7 where MaSach = 'S03'
update SACH set SoLuong = 16 where MaSach = 'S04'
update SACH set SoLuong = 4 where MaSach = 'S05'

-- 5. Tạo view đưa ra danh sách các độc giả mượn sách 'Giải tích 1' trong tháng 1
insert PHIEUMUON (MaDg,MaSach,NgayMuon,NgayTra,SoLuong)
values
	('DG03','S01','2024-01-13','2024-10-1',2)

create view dsdg_gt1 as
select
	DOCGIA.MaDg,
    DOCGIA.HoTen,
    DOCGIA.NgaySinh,
    PHIEUMUON.MaSach,
    SACH.TenSach,
    PHIEUMUON.NgayMuon,
    PHIEUMUON.NgayTra,
    PHIEUMUON.SoLuong
from DOCGIA
join PHIEUMUON on DOCGIA.MaDg = PHIEUMUON.MaDg
join SACH on PHIEUMUON.MaSach = SACH.MaSach
where
	SACH.TenSach = N'Giải tích 1'
	and MONTH(PHIEUMUON.NgayMuon) = 1;

-- 6. Tạo truy vấn đưa ra các cuốn sách không được mượn
select
	SACH.MaSach,
	SACH.TenSach,
	SACH.Namxb,
	SACH.SoLuong
from SACH
where SACH.MaSach not in (select MaSach from PHIEUMUON)

-- 7. Tạo thủ tục nhập vào 2 mã sách. Đưa ra thông báo xem 2 cuốn sách này có cùng năm xuất bản không.
create proc KtraNamxb (@MaSach1 varchar(10), @MaSach2 varchar(10))
as
	declare @Namxb1 int;
	declare @Namxb2 int;
	select @Namxb1 = Namxb from SACH where MaSach = @MaSach1;
	select @Namxb2 = Namxb from SACH where MaSach = @MaSach2;
	print N'Năm xuất bản của mã sách ' +@MaSach1+ ' là: ' + cast(@Namxb1 as varchar);
	print N'Năm xuất bản của mã sách ' +@MaSach2+ ' là: ' + cast(@Namxb2 as varchar);
	if @Namxb1 is null or @Namxb2 is null
		print N'Một trong hai mã sách không tồn tại!';
	else if @Namxb1 = @Namxb2
		print N'Hai cuốn sách có cùng năm xuất bản: ' + cast(@Namxb1 as varchar);
	else
		print N'Hai cuốn sách không cùng năm xuất bản (' +cast(@Namxb1 as varchar)+ ', ' +cast(@Namxb2 as varchar)+ ')'; 

ktraNamxb S01,S02

-- 8. Viết trigger để khi chèn 1 dòng dữ liệu vào bảng PHIEUMUON thì số lượng trong bảng SACH sẽ tự động được cập nhật
create trigger update_SACH
on PHIEUMUON
for insert
as
	if exists (
		select 1
		from SACH
		join PHIEUMUON on SACH.MaSach = PHIEUMUON.MaSach
		where PHIEUMUON.SoLuong > SACH.SoLuong
	) begin
		print N'Số lượng sách mượn nhiều hơn số lượng sách hiện có';
		rollback transaction;
	end
	else begin
		update SACH
		set SACH.SoLuong = SACH.SoLuong - PHIEUMUON.SoLuong
		from SACH
		join PHIEUMUON on SACH.MaSach = PHIEUMUON.MaSach
	end

insert PHIEUMUON
values
	('DG03','S02','2025-9-15','2025-10-28',1),
	('DG02','S04','2025-9-15','2025-11-1',1)

delete
from PHIEUMUON
where
	(MaDg = 'DG03' and MaSach = 'S02')
	or (MaDg = 'DG02' and MaSach = 'S04')