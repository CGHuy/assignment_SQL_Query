create database bai2
use bai2

-- 1. Viết các câu lệnh tạo các bảng với các ràng buộc nêu trong đề bài, dựa vào bảng dữ liệu để chọn kiểu dữ liệu phù hợp

create table MAYBAY (
	MAMB varchar(10) primary key,
	SOPHIEU nvarchar(50) not null,
	TAMBAY int not null
)

create table NHANVIEN (
	MANV varchar(10) primary key,
	TEN nvarchar(50) not null,
	LUONG int not null,
)

create table CHUNGNHAN (
	MANV varchar(10),
	MAMB varchar(10),
	primary key (MANV, MAMB),
	constraint fk_mnv foreign key (MANV) references NHANVIEN(MANV),
	constraint fk_mmb foreign key (MAMB) references MAYBAY(MAMB)
)

-- 2. Viết câu lệnh nhập dữ liệu vào các bảng

insert MAYBAY
values
	('747','Boeing 747 - 400',13488),
	('737','Boeing 737 - 800',5413),
	('340','Airbus A340 - 300',11100),
	('757','Boeing 757 - 300',6415),
	('777','Boeing 777 - 300',10350),
	('767','Boeing 767 - 400ER',10300),
	('154','Aribus A154',21500)

insert NHANVIEN
values
	('NV01',N'Lê Thị Hòa',30000000),
	('NV02',N'Nguyễn Viết Hưng',50000000),
	('NV03',N'Nguyễn Thùy Linh',45000000),
	('NV04',N'Lê Văn An',60000000),
	('NV05',N'Công Văn Tuyến',60000000)

insert CHUNGNHAN
values
	('NV01','747'),
	('NV01','340'),
	('NV01','777'),
	('NV02','737'),
	('NV02','777'),
	('NV02','747'),
	('NV04','767'),
	('NV05','340')

-- 3. Viết câu lệnh sửa bảng CHUNGNHAN thêm 1 cột mới là cột GHICHU
alter table CHUNGNHAN
add GHICHU nvarchar(100)

-- 4. Tạo truy vấn đưa ra tên những nhân viên lái được ít loại máy bay nhất gồm các thông tin: TEN, MANV, Tổng số máy bay
select NHANVIEN.TEN, NHANVIEN.MANV, count(CHUNGNHAN.MAMB) as TongSoMayBay
from NHANVIEN
join CHUNGNHAN on NHANVIEN.MANV = CHUNGNHAN.MANV
group by NHANVIEN.MANV, NHANVIEN.TEN
having count(CHUNGNHAN.MAMB) = (
    select min(TongSo)
    from (
        select count(MAMB) as TongSo
        from CHUNGNHAN
        group by MANV
    ) as T
)

-- dùng top 1 with ties (lấy hàng đầu tiên và những hàng có cùng giá trị)
select top 1 with ties NHANVIEN.MANV, NHANVIEN.TEN, count(CHUNGNHAN.MAMB) as TongSoMayBay
from NHANVIEN
join CHUNGNHAN on NHANVIEN.MANV = CHUNGNHAN.MANV
group by NHANVIEN.MANV, NHANVIEN.TEN
order by count(CHUNGNHAN.MAMB) asc

-- 5. Tạo truy vấn đưa ra nhân viên lái được cả hai loại máy bay có mã 747 và 777
select NHANVIEN.MANV, NHANVIEN.TEN
from NHANVIEN
join CHUNGNHAN on NHANVIEN.MANV = CHUNGNHAN.MANV
where CHUNGNHAN.MAMB in ('747','777') -- sẽ liệt kê ra hết những nhân viên có 1 trong 2 hoặc cả 2 máy bay
group by NHANVIEN.MANV, NHANVIEN.TEN
having count(distinct CHUNGNHAN.MAMB) = 2 -- chỉ lấy những nhân viên có cả 2 loại máy bay 

-- 6. Tạo truy vấn đưa ra những máy bay chưa có trong bảng CHUNGNHAN
select *
from MAYBAY
where not exists (
	select 1
	from CHUNGNHAN
	where CHUNGNHAN.MAMB = MAYBAY.MAMB
)

select *
from MAYBAY
where MAYBAY.MAMB not in (select MAMB from CHUNGNHAN)
	
select MAYBAY.*
from MAYBAY
left join CHUNGNHAN on CHUNGNHAN.MAMB = MAYBAY.MAMB
where CHUNGNHAN.MAMB is null

-- 7. Tạo truy vấn đưa ra những nhân viên có lương cao hơn lương của nhân viên ‘NV03’
select *
from NHANVIEN
where LUONG > (select LUONG from NHANVIEN where MANV = 'NV03')

-- 8. Tạo truy vấn đưa ra những nhân viên đã lái được từ 3 loại máy bay trở lên ngồm các thông tin: MANV, TEN
select NHANVIEN.MANV, NHANVIEN.TEN
from NHANVIEN
join CHUNGNHAN on CHUNGNHAN.MANV = NHANVIEN.MANV
group by NHANVIEN.MANV, NHANVIEN.TEN
having count(distinct CHUNGNHAN.MAMB) >= 3;

-- 9. Tạo thủ tục đưa ra thông tin của máy bay được lái bởi 1 nhân viên bất kỳ
create proc ThongTinMayBay (@MANV varchar(10)) as
	select *
	from MAYBAY
	join CHUNGNHAN on CHUNGNHAN.MAMB = MAYBAY.MAMB
	where CHUNGNHAN.MANV = @MANV

ThongTinMayBay NV01

-- 10. Tạo trigger để khi chèn thêm dữ liệu vào bảng NHANVIEN sẽ có thông báo tổng số dòng trong bảng là bao nhiêu
create trigger tb_sl_nv_insert on NHANVIEN for insert as
	select count(MANV) as N'Tổng số dòng'
	from NHANVIEN

create trigger tb_sl_nv_delete on NHANVIEN for delete as
	select count(MANV) as N'Tổng số dòng'
	from NHANVIEN

select * from NHANVIEN

insert NHANVIEN
values
	('NV07',N'Lê Việt Anh', 70000000)

delete from NHANVIEN where MANV = 'NV07'