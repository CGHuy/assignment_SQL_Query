create database bai1
use bai1

create table SINHVIEN (
	MASV varchar(10) primary key,
	HOTEN nvarchar(50),
	GIOITINH nvarchar(10) check (GioiTinh in (N'Nam', N'Nữ')),
	LOP varchar(10)
)

create table MONHOC (
	MAMH varchar(10) primary key,
	TENMH nvarchar(50),
	SOTINCHI int check(SOTINCHI between 1 and 10)
)

create table DIEM (
	MASV varchar(10),
	MAMH varchar(10),
	DIEMLAN1 float check(DIEMLAN1 between 0 and 10),
	DIEMLAN2 float check(DIEMLAN2 between 0 and 10),
	primary key (MASV, MAMH),
	constraint fk_msv foreign key (MASV) references SINHVIEN(MASV),
	constraint fk_mmh foreign key (MAMH) references MONHOC(MAMH)
)

insert SINHVIEN
values
	('00111',N'Đỗ Mai Anh',N'Nữ','L01'),
	('00112',N'Mai Văn Bình',N'Nam','L01'),
	('00113',N'Lê La',N'Nữ','L02'),
	('00215',N'Đặng Ngọc Anh',N'Nữ','L02'),
	('00315',N'Nguyễn Thế Tâm',N'Nữ','L03'),
	('00254',N'Phạm Thị Thuận',N'Nữ','L01'),
	('01305',N'Cao Giang Huy',N'Nam','L01')

insert MONHOC
values
	('TRR',N'Toán rời rạc',4),
	('CTDL',N'Cấu trúc dữ liệu',3),
	('CSDL',N'Cơ sở dữ liệu',3),
	('KNGT',N'Kỹ năng giao tiếp',2)

insert DIEM
values
	('00111','TRR',7,NULL),
	('00112','CTDL',8,NULL),
	('00113','CSDL',2,9),
	('00215','KNGT',9,NULL),
	('00315','TRR',1,7),
	('00254','TRR',2,9),
	('00112','CSDL',8,NULL),
	('00113','KNGT',9,NULL),
	('00215','CTDL',9,NULL)

-- 1. Xóa tất cả điểm của sinh viên có mã 00254
delete DIEM
where MASV = '00254'

-- 2. Cho biết mã môn học, tên môn học, điểm thi tất cả các môn của sinh viên tên Bình
select DIEM.MAMH, MONHOC.TENMH, DIEM.DIEMLAN1, DIEM.DIEMLAN2
from DIEM
join SINHVIEN on SINHVIEN.MASV = DIEM.MASV
join MONHOC on MONHOC.MAMH = DIEM.MAMH
where SINHVIEN.HOTEN like N'%Bình%'

-- 3. Cho biết mã môn học, tên môn và điểm thi ở những môn mà sinh viên tên Lê La phải thi lại (điểm < 5)
select DIEM.MAMH, MONHOC.TENMH, DIEM.DIEMLAN1, DIEM.DIEMLAN2
from DIEM
join SINHVIEN on SINHVIEN.MASV = DIEM.MASV
join MONHOC on MONHOC.MAMH = DIEM.MAMH
where SINHVIEN.HOTEN like N'%Lê La%'
	and DIEM.DIEMLAN1 < 5

-- 4. Cho biết mã sinh viên, tên những sinh viên đã thi ít nhất là 1 trong 3 môn Toán rời rạc, cơ sở dữ liệu, kỹ năng giao tiếp
select SINHVIEN.MASV, SINHVIEN.HOTEN
from SINHVIEN
join DIEM on DIEM.MASV = SINHVIEN.MASV
where DIEM.MAMH in ('TRR','CSDL','KNGT')
group by SINHVIEN.MASV, SINHVIEN.HOTEN

-- 5. Cho biết mã môn học, tên môn mà sinh viên có mã số 00315 chưa có điểm
select MAMH, TENMH -- tối ưu nhất vì không lỗi trường hợp null
from MONHOC
where not exists (
	select 1
	from DIEM
	where MASV = '00315'
		and DIEM.MAMH = MONHOC.MAMH
)

select MAMH, TENMH
from MONHOC
where MAMH not in (select MAMH from DIEM where MASV = '00315')

select MONHOC.MAMH, MONHOC.TENMH
from MONHOC
left join DIEM on DIEM.MAMH = MONHOC.MAMH and DIEM.MASV = '00315'
where DIEM.MAMH is null





-- 6. Cho biết điểm cao nhất môn CSDL mà các sinh viên đạt được
select max(DIEMLAN1) as N'Điểm cao nhất 1', max(DIEMLAN2) as N'Điểm cao nhất 2'
from DIEM
where
	MAMH = 'CSDL'

-- 7. Cho biết sinh viên nào chưa có điểm của bất kỳ môn nào
select * -- tối ưu hơn vì k bị lỗi trường hợp null
from SINHVIEN 
where not exists (
	select 1
	from DIEM
	where DIEM.MASV = SINHVIEN.MASV
)

select *
from SINHVIEN
where MASV not in (select MASV from DIEM)

select SINHVIEN.*
from SINHVIEN
left join DIEM on DIEM.MASV = SINHVIEN.MASV
where DIEM.MASV is null