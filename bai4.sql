create database bai4
use bai4

-- 1. Viết các câu lệnh tạo các bảng với các ràng buộc nêu trong đề bài, dựa vào bảng dữ liệu để chọn kiểu dữ liệu phù hợp
create table SANPHAM (
	MASP varchar(10) primary key,
	TENSP nvarchar(50) unique not null,
	KICHTHUOC varchar(10) not null check(KICHTHUOC in ('S', 'M', 'L', 'XL')),
	MAUSAC nvarchar(10)  not null
)

create table NHASANXUAT (
	MANSX varchar(10) primary key,
	TENNSX nvarchar(50) not null,
	DIACHI nvarchar(50) not null
)

create table CUNGCAP (
	MANSX varchar(10) not null,
	MASP varchar(10) not null,
	NGAY date not null,
	SOLUONG int check(SOLUONG > 0 ) not null,
	constraint fk_msp foreign key (MASP) references SANPHAM(MASP),
	constraint fk_mnsx foreign key (MANSX) references NHASANXUAT(MANSX)
)

-- 2. Viết câu lệnh nhập dữ liệu vào các bảng
insert SANPHAM
values
	('001',N'Áo cộc họa tiết','S',N'Xanh'),
	('002',N'Quần dài trơn','S',N'Be'),
	('003',N'Quần đùi trên gối','M',N'Xanh'),
	('004',N'Quần ngố họa tiết','L',N'Đen'),
	('005',N'Quần bó ống','XL',N'Đen'),
	('006',N'Áo cộc trơn','M',N'Tím')

insert NHASANXUAT
values
	('SX01',N'Thành Đông',N'Hà Nội'),
	('SX02',N'Hà Hải',N'Hưng Yên'),
	('SX03',N'Chiến Thắng',N'Hải Phòng'),
	('SX04',N'Hưng Bền',N'Hà Nội')

insert CUNGCAP
values
	('SX01','001','2024-1-1',50),
	('SX01','006','2024-3-20',20),
	('SX02','002','2024-1-1',10),
	('SX02','003','2024-1-25',30),
	('SX03','002','2024-1-1',40),
	('SX03','005','2024-3-22',50),
	('SX04','006','2024-1-19',90),
	('SX04','003','2024-1-2',100)

-- 3. Viết câu lệnh sửa bảng CUNGCAP thêm một cột mới là cột GHICHU
alter table CUNGCAP
add GHICHU nvarchar(100)

-- 4. Tạo truy vấn đưa ra những nhà cung cấp đã cung cấp tổng số lượng nhiều hơn tổng số lượng của nhà cung cấp SX01
select NHASANXUAT.MANSX, TENNSX, DIACHI, sum(CUNGCAP.SOLUONG) as N'Tổng số lượng'
from NHASANXUAT
join CUNGCAP on CUNGCAP.MANSX = NHASANXUAT.MANSX
group by NHASANXUAT.MANSX, TENNSX, DIACHI
having sum(CUNGCAP.SOLUONG) > (select sum(SOLUONG) from CUNGCAP where MANSX = 'SX01')

-- 5. Tạo truy vấn đưa ra những sản phẩm chưa có trong bảng CUNGCAP
select *
from SANPHAM
where not exists (
	select 1
	from CUNGCAP
	where CUNGCAP.MASP = SANPHAM.MASP
)

select *
from SANPHAM
where MASP not in (select MASP from CUNGCAP)

select SANPHAM.*
from SANPHAM
left join CUNGCAP on SANPHAM.MASP = CUNGCAP.MASP
where CUNGCAP.MASP is null