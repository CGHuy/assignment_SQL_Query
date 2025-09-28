create database bai3
use bai3

-- 1. Viết các câu lệnh tạo các bảng với các ràng buộc nêu trong đề bài. Dựa vào bảng dữ liệu để chọn kiểu dữ liệu phù hợp

create table KHOA (
	MaKhoa varchar(10) primary key,
	TenKhoa nvarchar(50) not null
)

create table SINHVIEN (
	MaSV varchar(10) primary key,
	HoTen nvarchar(50) not null,
	NgaySinh date not null,
	MaKhoa varchar(10),
	constraint fk_mk foreign key (MaKhoa) references KHOA(MaKhoa)
)

create table MONHOC (
	MaMon varchar(10) primary key,
	TenMon nvarchar(50) not null,
	SoTinChi int not null
)

create table DANGKYHOC (
	MaSV varchar(10),
	MaMon varchar(10),
	HocKy int not null,
	constraint fk_msv foreign key (MaSV) references SINHVIEN(MaSV),
	constraint fk_mm foreign key (MaMon) references MonHoc(MaMon)
)

-- 2. Viết câu lệnh nhập dữ liệu vào các bảng

insert KHOA
values
	('TOAN', N'Toán - Tin'),
	('CNTT', N'Công nghệ thông tin'),
	('DIAL', N'Địa lý'),
	('HOAH', N'Hóa học')

insert SINHVIEN
values
	('K611', N'Phạm Văn Bình', '1990-2-24', 'TOAN'),
	('K612', N'Nguyễn Thị Hoài', '1991-4-12', 'CNTT'),
	('K613', N'Trần Ngọc', '1990-4-15', 'DIAL'),
	('K614', N'Nguyễn Tấn Dũng', '1992-2-3', 'CNTT'),
	('K615', N'Trương Tấn Sang', '1990-12-4', 'DIAL')

insert MONHOC
values
	('GT1',N'Giải tích 1', 2),
	('DSTT',N'Đại số tuyến tính', 3),
	('HH',N'Hình học Afin', 2)

insert DANGKYHOC
values
	('K611', 'GT1', 1),
	('K611', 'DSTT', 2),
	('K612', 'DSTT', 1),
	('K612', 'HH', 2),
	('K612', 'GT1', 1),
	('K613', 'HH', 1),
	('K613', 'GT1', 8),
	('K613', 'HH', 2),
	('K614', 'HH', 3),
	('K614', 'DSTT', 6),
	('K615', 'HH', 5)

-- 3. Viết câu lệnh sửa dữ liệu bảng MonHoc tên môn ‘Hình học Afin’ thành ‘Hình học’
update MONHOC
set TenMon = N'Hình học'
where TenMon = N'Hình học Afin'

-- 4. Tạo View đưa ra MaSV, HoTen, TenKhoa, Ngay sinh của sinh viên học khoa Công nghệ thông tin có năm sinh 1991
create view tt_hs_1991 as
select MaSV, HoTen, KHOA.TenKhoa, NgaySinh
from SINHVIEN
join KHOA on KHOA.MaKhoa = SINHVIEN.MaKhoa
where SINHVIEN.MaKhoa = 'CNTT'
	and year(NgaySinh) = 1991

-- 5. Tạo truy vấn đưa ra thông tin của sinh viên không đăng ký học môn Giải tích 1
select *
from SINHVIEN
where not exists (
	select 1
	from DANGKYHOC
	where SINHVIEN.MaSV = DANGKYHOC.MaSV
		and DANGKYHOC.MaMon = 'GT1'
)

select *
from SINHVIEN
where MaSV not in (select MaSV from DANGKYHOC where MaMon = 'GT1')

select SINHVIEN.*
from SINHVIEN
left join DANGKYHOC on SINHVIEN.MaSV = DANGKYHOC.MaSV
	and DANGKYHOC.MaMon = 'GT1'
where DANGKYHOC.MaSV is null

-- 6. Tạo truy vấn đưa ra những sinh viên có điểm từ 2 môn trở lên gồm: mã sv, tên sv, tổng số môn
select SINHVIEN.MaSV, HoTen, count(DANGKYHOC.MaMon) as N'Tổng số môn'
from SINHVIEN
join DANGKYHOC on DANGKYHOC.MaSV = SINHVIEN.MaSV
group by SINHVIEN.MaSV, HoTen
having count(distinct DANGKYHOC.MaMon) >= 2

-- 7. Đưa ra những môn có số tín chỉ lớn hơn số tín chỉ của môn ‘Giải tích 1’
select *
from MONHOC
where SoTinChi > (select SoTinChi from MONHOC where TenMon = N'Giải tích 1')

-- 8. Tạo Thủ tục để thông báo tổng số sinh viên sinh viên đăng ký môn học theo từng môn
create proc tongSoSV (@MaMon varchar(10)) as

	declare @SoLuong int;
	declare @Ten nvarchar(50);

	select @SoLuong = count(DANGKYHOC.MaSV)
	from DANGKYHOC
	where MaMon = @MaMon

	select @Ten = TenMon
	from MONHOC
	where MaMon=@MaMon

	print N'Tổng số sinh viên tham gia môn học ' +@Ten+ N' là: ' + cast(@SoLuong as varchar(10))

tongSoSV HH

-- 9. Tạo trigger để đảm bảo bảng MONHOC không vượt quá 4 môn, nếu chèn vượt quá thì đưa ra thông báo: ‘Số môn học không được quá 4 môn’
create trigger smh_check
on MONHOC
for insert
as
	declare @smh int;
	select @smh = count(MaMon) from MONHOC;
	if (@smh > 4) begin
		print N'Số môn học không được quá 4 môn';
		rollback transaction;
	end

insert MONHOC
values
	('AI',N'Trí tuệ nhân tạo',3)
