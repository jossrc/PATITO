DROP DATABASE IF EXISTS patito;
CREATE DATABASE patito;
USE patito;

CREATE TABLE TIPOEMPLEADO(
  ID_TP     INT          PRIMARY KEY AUTO_INCREMENT, 
  DESCRIPCION    VARCHAR(20)      NOT NULL UNIQUE
  );

CREATE TABLE EMPLEADO(
  ID_EM      INT          PRIMARY KEY AUTO_INCREMENT, 
  DNI   CHAR(8)      NOT NULL UNIQUE,
  NOMBRE    VARCHAR(50)  NOT NULL,
  APELLIDO    VARCHAR(50)  NOT NULL,
  TELEFONO  VARCHAR(10)  NOT NULL UNIQUE,
  DIRECCION VARCHAR(150) NOT NULL,
  CORREO VARCHAR(100) NOT NULL UNIQUE,
  USUARIO	 VARCHAR(50)  NOT NULL UNIQUE,
  CLAVE  VARCHAR(50)  NOT NULL UNIQUE,
  ID_TP	 	  INT		  NOT NULL,
  ESTADO      TINYINT     NOT NULL DEFAULT 1,
  IMAGEN 	VARCHAR(1000) NOT NULL DEFAULT "https://res.cloudinary.com/dfuuywyk9/image/upload/v1621437436/l60Hf_megote.png",
  FOREIGN KEY (ID_TP) REFERENCES TIPOEMPLEADO (ID_TP)
);

CREATE TABLE DISTRITO
(
    ID_DIST  INT PRIMARY KEY,
    NOM_DIST VARCHAR(50) NOT NULL
);

CREATE TABLE CLIENTE
(
    ID_CLI    INT PRIMARY KEY AUTO_INCREMENT,
    ID_DIST   INT         NOT NULL,
    DNI_CLI   CHAR(8)     NOT NULL UNIQUE,
    NOM_CLI   VARCHAR(50) NOT NULL,
    APE_CLI   VARCHAR(50) NOT NULL,
    DIR_CLI   VARCHAR(50) NOT NULL,
    TELEF_CLI VARCHAR(15) UNIQUE,
    ESTADO    TINYINT     NOT NULL DEFAULT 1,
    FOREIGN KEY (ID_DIST) references DISTRITO (ID_DIST)

);

CREATE TABLE CATEGORIA
(
    ID_CA       INT PRIMARY KEY AUTO_INCREMENT,
    DESCRIPCION VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE PRODUCTO
(
    ID_PRO      INT PRIMARY KEY AUTO_INCREMENT,
    DESCRIPCION VARCHAR(100)  NOT NULL UNIQUE,
    PRECIO      DECIMAL(6, 2) NOT NULL CHECK (PRECIO > 0),
    CANTIDAD    TINYINT       NOT NULL CHECK (CANTIDAD >= 0),
    ID_CA       INT           NOT NULL,
    IMAGEN      VARCHAR(1000) NULL DEFAULT 'https://cutt.ly/unbQLrJ',
    ESTADO      TINYINT       NOT NULL DEFAULT 1,
    FOREIGN KEY (ID_CA) REFERENCES CATEGORIA (ID_CA)
);

CREATE TABLE PEDIDO
(
    ID_PE          INT AUTO_INCREMENT,
    ID_EM          INT     NOT NULL,
    ID_CLI         INT     NOT NULL,
    FECHA_PE       DATE    NOT NULL,
    CANTIDAD_TOTAL TINYINT NOT NULL CHECK (CANTIDAD_TOTAL >= 0),
    PRIMARY KEY (ID_PE, ID_EM, ID_CLI),
    FOREIGN KEY (ID_EM) REFERENCES EMPLEADO (ID_EM),
    FOREIGN KEY (ID_CLI) REFERENCES CLIENTE (ID_CLI)
);
CREATE TABLE DETALLE_PEDIDO
(
    ID_PE    INT           NOT NULL,
    ID_PRO   INT           NOT NULL,
    PRECIO   DECIMAL(6, 2) NOT NULL CHECK (PRECIO > 0),
    CANTIDAD TINYINT       NOT NULL CHECK (CANTIDAD >= 0),
    FOREIGN KEY (ID_PE) REFERENCES PEDIDO (ID_PE),
    FOREIGN KEY (ID_PRO) REFERENCES PRODUCTO (ID_PRO)
);

CREATE TABLE BOLETA
(
    ID_PE     INT           NOT NULL,
    ID_BOL    CHAR(11)      NOT NULL,
    PRETOTAL  DECIMAL(6, 2) NOT NULL,
    DESCUENTO DECIMAL(6, 2) NOT NULL,
    PRIMARY KEY (ID_BOL),
    FOREIGN KEY (ID_PE) REFERENCES DETALLE_PEDIDO (ID_PE)
);

/*--------------------------FUNCIONES AUTOGENERADAS PARA LA TABLA EMPLEADO--------------------------*/

/*FUNCIï¿½N AUTOGENERADO DEL CORREO-->EMPLEADO*/
DROP FUNCTION IF EXISTS GENERAR_CORREO;
DELIMITER $$
CREATE FUNCTION GENERAR_CORREO(NOMBRE VARCHAR(50), APELLIDO VARCHAR(50))
RETURNS VARCHAR(50) DETERMINISTIC
	BEGIN
	RETURN CONCAT(LOWER((CONCAT(CONCAT(SUBSTRING(NOMBRE,1,3),SUBSTRING(APELLIDO,1,3)),YEAR(SYSDATE())))),LOWER('@PATITO.COM'));   
    END$$
DELIMITER ;

/*FUNCIï¿½N AUTOGENERADO DEL USUARIO-->EMPLEADO*/
DROP FUNCTION IF EXISTS GENERAR_USUARIO;
DELIMITER $$
CREATE FUNCTION GENERAR_USUARIO()
RETURNS VARCHAR(50) DETERMINISTIC
	BEGIN
	RETURN CONCAT(CONCAT(LOWER('p'),YEAR(SYSDATE())),FLOOR(RAND()*1000)+100);
    END$$
DELIMITER ;

/*FUNCIï¿½N AUTOGENERADO DE LA CLAVE-->EMPLEADO*/
DROP FUNCTION IF EXISTS GENERAR_CLAVE;
DELIMITER $$
CREATE FUNCTION GENERAR_CLAVE(IN_LENGTH INT) RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
SET @LEN = 0;
SET @RETURNVALUE = "";
WHILE (@LEN < IN_LENGTH) DO
SET @RANDCHAR = "0";
WHILE (@RANDCHAR IN ("0","1","O","L")) DO
SET @RANDCHAR = (SELECT CHAR(FLOOR(RAND()*10)+48) AS CHR
UNION SELECT CHAR(FLOOR(RAND()*26)+65)
UNION SELECT CHAR(FLOOR(RAND()*26)+97)
ORDER BY RAND() LIMIT 1);
END WHILE;
SET @RETURNVALUE = CONCAT(@RETURNVALUE,@RANDCHAR);
SET @LEN = @LEN + 1;
END WHILE;
RETURN @RETURNVALUE;
END$$
DELIMITER ;
/*--------------------------------------------------------------------------------------------------*/

/*--------------------------PROCEDIMIENTOS ALMACENADOS PARA LA TABLA EMPLEADO-----------------------*/

/*PROCEDURE AUTOGENERADO PARA EL REGISTRO-->EMPLEADO*/
DROP PROCEDURE IF EXISTS REGISTRAR_EMPLEADO;
DELIMITER $$
CREATE PROCEDURE REGISTRAR_EMPLEADO(
DNI CHAR(8), NOM VARCHAR(50), APE VARCHAR(50), TELEF VARCHAR(10), DIRECCION VARCHAR(150),
TIPO INT
)
BEGIN
INSERT INTO EMPLEADO VALUES(NULL,DNI,NOM,APE,TELEF,DIRECCION,GENERAR_CORREO(NOM,APE),GENERAR_USUARIO(),GENERAR_CLAVE(8),TIPO,DEFAULT,DEFAULT); 
END$$
DELIMITER ;

/*PROCEDIMIENTO ALMACENADO PARA EL LISTADO DE LOS EMPLEADOS*/
DROP PROCEDURE IF EXISTS USP_LISTADOEMPLEADO;
DELIMITER $$
CREATE PROCEDURE USP_LISTADOEMPLEADO()
BEGIN
SELECT E.ID_EM,E.DNI,E.NOMBRE,E.APELLIDO,E.TELEFONO,E.CORREO,TE.DESCRIPCION FROM EMPLEADO AS E
INNER JOIN TIPOEMPLEADO AS TE
ON E.ID_TP=TE.ID_TP
WHERE E.ESTADO=1;
END$$
DELIMITER ;

/*PROCEDIMIENTO ALMACENADO PARA ELIMINAR EMPLEADOS*/
DROP PROCEDURE IF EXISTS USP_ELIMINAREMPLEADO;
DELIMITER $$
CREATE PROCEDURE USP_ELIMINAREMPLEADO(
    ID INT
)
BEGIN 
UPDATE EMPLEADO SET ESTADO = 0 WHERE ID_EM = ID;
END$$
DELIMITER ;

/*PROCEDIMIENTO ALMACENADO PARA VALIDAR ACCESO DEL EMPLEADO*/
DROP PROCEDURE IF EXISTS USP_VALIDARACCESO;
DELIMITER $$
CREATE PROCEDURE USP_VALIDARACCESO(USR VARCHAR(100), PAS VARCHAR(50))
BEGIN
SELECT E.*,TE.DESCRIPCION FROM EMPLEADO AS E
INNER JOIN TIPOEMPLEADO AS TE
ON E.ID_TP=TE.ID_TP
WHERE (CORREO = USR OR USUARIO = USR) AND CLAVE = PAS AND ESTADO = 1;
    SELECT * FROM EMPLEADO WHERE (CORREO = USR OR USUARIO = USR) AND CLAVE = PAS AND ESTADO = 1;
END$$
DELIMITER ;

/*PROCEDIMIENTO ALMACENADO PARA LA ACTUALIZACION DE LOS DATOS DEL EMPLEADO*/
DROP PROCEDURE IF EXISTS USP_ACTUALIZAREMPLEADO;
DELIMITER $$
CREATE PROCEDURE USP_ACTUALIZAREMPLEADO(DNI CHAR(8), NOMBRE VARCHAR(50), APELLIDO VARCHAR(50), TELEFONO VARCHAR(10), DIRECCION VARCHAR(150),
TIPO INT, ID INT)
BEGIN
UPDATE EMPLEADO SET DNI = DNI, NOMBRE = NOMBRE, APELLIDO = APELLIDO, TELEFONO = TELEFONO, DIRECCION = DIRECCION,
ID_TP=TIPO WHERE ID_EM=ID;
END$$
DELIMITER ;

/*PROCEDIMIENTO ALMACENADO PARA LA ACTUALIZACION DEL PERFIL DEL EMPLEADO*/
DROP PROCEDURE IF EXISTS USP_ACTUALIZARPERFILEMPLEADO;
DELIMITER $$
CREATE PROCEDURE USP_ACTUALIZARPERFILEMPLEADO(IMAGEN VARCHAR(1000), NOMBRE VARCHAR(50), APELLIDO VARCHAR(50), TELEFONO VARCHAR(10), DIRECCION VARCHAR(150),
CORREO VARCHAR(50), CLAVE VARCHAR(50), ID INT)
BEGIN
WHILE
IMAGEN IS NULL DO
SET IMAGEN = 'https://res.cloudinary.com/dfuuywyk9/image/upload/v1621437436/l60Hf_megote.png';
END WHILE;
UPDATE EMPLEADO SET IMAGEN = IMAGEN, NOMBRE = NOMBRE, APELLIDO = APELLIDO, TELEFONO = TELEFONO, DIRECCION = DIRECCION, CORREO = CORREO, CLAVE = CLAVE WHERE ID_EM=ID;
END$$
DELIMITER ;
/*--------------------------------------------------------------------------------------------------*/

/*PROCEDIMIENTO ALMACENADO PARA EL REGISTRO DE LOS PRODUCTOS*/	
DROP PROCEDURE IF EXISTS USP_REGISTRARPRODUCTO;
DELIMITER $$
CREATE PROCEDURE USP_REGISTRARPRODUCTO(DESCP VARCHAR(100), PRE DECIMAL(6, 2), CANT TINYINT, CATEGORIA INT,
                                       IMG VARCHAR(1000)
)
BEGIN
	IF IMG = NULL THEN
      SET IMG = 'https://cutt.ly/unbQLrJ';
	END IF;
    INSERT INTO PRODUCTO(DESCRIPCION, PRECIO, CANTIDAD, ID_CA, IMAGEN) VALUES (DESCP, PRE, CANT, CATEGORIA, IMG);
END$$
DELIMITER ;

/*INSERT INTO CATEGORIA VALUES(1,'Almuerzo');
CALL USP_REGISTRARPRODUCTO('SOPA SECA',23.4,10,1,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1621437436/l60Hf_megote.png');
select * from PRODUCTOS;*/

/*PROCEDIMIENTO ALMACENADO PARA EL REGISTRO DE LOS PRODUCTOS*/
DROP PROCEDURE IF EXISTS USP_ACTUALIZARPRODUCTO;
DELIMITER $$
CREATE PROCEDURE USP_ACTUALIZARPRODUCTO(IDPROD INT, DESCR VARCHAR(100), PRE DECIMAL(6, 2), CANT TINYINT, IDCAT INT,
                                        IMG VARCHAR(1000))
BEGIN
    UPDATE PRODUCTO
    SET DESCRIPCION = DESCR,
        PRECIO      = PRE,
        CANTIDAD    = CANT,
        ID_CA       = IDCAT,
        IMAGEN      = IMG
    WHERE ID_PRO = IDPROD;
END$$
DELIMITER ;
/*CALL USP_ACTUALIZARPRODUCTO(1,'SOPA DE CUY',23.4,10,1,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1621437436/l60Hf_megote.png');
select * from PRODUCTOS;*/
/*PROCEDIMIENTO ALMACENADO PARA ELIMINAR PRODUCTOS*/
DROP PROCEDURE IF EXISTS USP_ELIMINARPRODUCTO;
DELIMITER $$
CREATE PROCEDURE USP_ELIMINARPRODUCTO(PRO INT)
BEGIN
    UPDATE PRODUCTO SET ESTADO = 0 WHERE ID_PRO = PRO;
END$$
DELIMITER ;

/*CALL USP_REGISTRARPRODUCTO('SOPA SECA',23.4,10,1,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1621437436/l60Hf_megote.png');
CALL USP_ELIMINARPRODUCTO(2);
select * from PRODUCTO;*/
/*PROCEDIMIENTO ALMACENADO PARA EL LISTADO DE LOS EMPLEADOS*/
DROP PROCEDURE IF EXISTS USP_LISTADOPRODUCTOS;
DELIMITER $$
CREATE PROCEDURE USP_LISTADOPRODUCTOS()
BEGIN
    SELECT P.ID_PRO, P.DESCRIPCION, P.PRECIO, P.CANTIDAD, P.ID_CA, C.DESCRIPCION, P.IMAGEN
    FROM PRODUCTO AS P
             INNER JOIN CATEGORIA C
                        ON P.ID_CA = C.ID_CA
    WHERE P.ESTADO = 1;
END$$
DELIMITER ;

/*USP LISTAR CLIENTE POR DISTRITO*/
DROP PROCEDURE IF EXISTS USP_ClientexDistrito;
DELIMITER $$
CREATE PROCEDURE USP_ClientexDistrito()
BEGIN
    SELECT C.ID_CLI,
           C.DNI_CLI,
           C.NOM_CLI,
           C.APE_CLI,
           C.DIR_CLI,
           C.TELEF_CLI,
           D.ID_DIST,
           D.NOM_DIST
    FROM CLIENTE AS C
             INNER JOIN DISTRITO AS D ON C.ID_DIST = D.ID_DIST
             WHERE C.ESTADO =1;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS USP_ELIMINARCLIENTE;
DELIMITER $$
CREATE PROCEDURE USP_ELIMINARCLIENTE(CLI INT)
BEGIN
    UPDATE CLIENTE SET ESTADO = 0 WHERE ID_CLI = CLI;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS USP_ACTUALIZARCLIENTE;
DELIMITER $$
CREATE PROCEDURE USP_ACTUALIZARCLIENTE(
    IDC INT,
    IDD INT,
    DNI CHAR(8),
    NOM VARCHAR(50),
    APE VARCHAR(50),
    DIR VARCHAR(50),
    TELE VARCHAR(15)
)
BEGIN
    UPDATE CLIENTE
    SET NOM_CLI   = NOM,
        APE_CLI   = APE,
        TELEF_CLI = TELE,
        DNI_CLI   = DNI,
        ID_DIST   = IDD,
        DIR_CLI   = DIR
    WHERE ID_CLI = IDC;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS USP_REGISTRARCLIENTE;
DELIMITER $$
CREATE PROCEDURE USP_REGISTRARCLIENTE(
    DISTRITO INT,
    DNI CHAR(8),
    NOM VARCHAR(50),
    APE VARCHAR(50),
    DIR VARCHAR(50),
    TELE VARCHAR(15)
)
BEGIN
    INSERT INTO CLIENTE(ID_DIST, DNI_CLI, NOM_CLI, APE_CLI, DIR_CLI, TELEF_CLI)
    VALUES (DISTRITO, DNI, NOM, APE, DIR, TELE);
END$$
DELIMITER ;

/*PROCEDURE PARA EL LISTADO ENTRE FECHAS SOBRE LAS VENTAS*/
DROP PROCEDURE IF EXISTS USP_LISTADOENTREFECHAS;
DELIMITER $$
CREATE PROCEDURE USP_LISTADOENTREFECHAS(FECHA1 VARCHAR(10), FECHA2 VARCHAR(10))
BEGIN
SELECT BO.ID_BOL, PR.DESCRIPCION, PE.FECHA_PE, PD.PRECIO, PD.CANTIDAD, BO.DESCUENTO, ((PD.CANTIDAD*PD.PRECIO)-BO.DESCUENTO) 'IMPORTE TOTAL' FROM PEDIDO AS PE
INNER JOIN DETALLE_PEDIDO AS PD
ON PD.ID_PE = PE.ID_PE
INNER JOIN PRODUCTO AS PR
ON  PD.ID_PRO = PR.ID_PRO
INNER JOIN BOLETA AS BO
ON PD.ID_PE = BO.ID_PE
WHERE PE.FECHA_PE BETWEEN FECHA1 AND FECHA2
ORDER BY BO.ID_BOL ASC;
END$$
DELIMITER ;

/*PROCEDURE PARA EL LISTADO SOBRE LAS VENTAS*/
DROP PROCEDURE IF EXISTS USP_LISTADODEVENTAS;
DELIMITER $$
CREATE PROCEDURE USP_LISTADODEVENTAS()
BEGIN
SELECT BO.ID_BOL, PR.DESCRIPCION, PE.FECHA_PE, PD.PRECIO, PD.CANTIDAD, BO.DESCUENTO, ((PD.CANTIDAD*PD.PRECIO)-BO.DESCUENTO) 'IMPORTE TOTAL' FROM PEDIDO AS PE
INNER JOIN DETALLE_PEDIDO AS PD
ON PD.ID_PE = PE.ID_PE
INNER JOIN PRODUCTO AS PR
ON  PD.ID_PRO = PR.ID_PRO
INNER JOIN BOLETA AS BO
ON PD.ID_PE = BO.ID_PE;
END$$
DELIMITER ;

call USP_LISTADODEVENTAS();

INSERT INTO TIPOEMPLEADO VALUES (1,'Administrador(a)');
INSERT INTO TIPOEMPLEADO VALUES (2,'Recepcionista');
INSERT INTO TIPOEMPLEADO VALUES (3,'Chef');
INSERT INTO TIPOEMPLEADO VALUES (4,'Mesero(a)');
INSERT INTO TIPOEMPLEADO VALUES (5,'Repartidor(a)');

CALL REGISTRAR_EMPLEADO('89438934','Darick','Leroy','983498345','Calle Honolulu . Mz U Lt. 17',2);
CALL REGISTRAR_EMPLEADO('23898932','Leo','Martinez','984389438','Mz. 25 Lt. 9,Urb. Arriba Peru',5);
CALL REGISTRAR_EMPLEADO('47833478','Luis','Zapata','934334438','Los Algarrobos 563',5);
CALL REGISTRAR_EMPLEADO('23782378','Maria','Cerron','934477443','Avenida Peru,3210,SMP',2);
CALL REGISTRAR_EMPLEADO('43787843','Luz Elena','Medrano','984378343','Malachowscky 209 Of. 301',2);
CALL REGISTRAR_EMPLEADO('32782738','David','Gutarra','947374342','Av Republica Del Peru Nro 830',3);
CALL REGISTRAR_EMPLEADO('43879348','Rebeca','Mendoza','934438734','Mz. I Lote 12',4);
CALL REGISTRAR_EMPLEADO('43783478','Elva','Tasilla','934727334','Cdra. 46 Mza D4 Lt9 Bocanegra',4);
CALL REGISTRAR_EMPLEADO('32789237','Daniel','Castillo','934773423','Avenida Bellavista, 301',4);
CALL REGISTRAR_EMPLEADO('74374343','Kiara','Sullivan','934873474','Paruro 1369 Tda 135',3);

INSERT INTO DISTRITO values (1, 'Cercado de Lima');
INSERT INTO DISTRITO values (2, 'Ate');
INSERT INTO DISTRITO values (3, 'Barranco');
INSERT INTO DISTRITO values (4, 'BreÃ±a');
INSERT INTO DISTRITO values (5, 'Comas');
INSERT INTO DISTRITO values (6, 'Chorrillos');
INSERT INTO DISTRITO values (7, 'El Agustino');
INSERT INTO DISTRITO values (8, 'JesÃºs MarÃ­a');
INSERT INTO DISTRITO values (9, 'La Molina');
INSERT INTO DISTRITO values (10, 'La Victoria');
INSERT INTO DISTRITO values (11, 'Lince');
INSERT INTO DISTRITO values (12, 'Magdalena del Mar');
INSERT INTO DISTRITO values (13, 'Miraflores');
INSERT INTO DISTRITO values (14, 'Pueblo Libre');
INSERT INTO DISTRITO values (15, 'Puente Piedra');
INSERT INTO DISTRITO values (16, 'Rimac');
INSERT INTO DISTRITO values (17, 'San Isidro');
INSERT INTO DISTRITO values (18, 'Independencia');
INSERT INTO DISTRITO values (19, 'San Juan de Miraflores');
INSERT INTO DISTRITO values (20, 'San Luis');
INSERT INTO DISTRITO values (21, 'San Martin de Porres');
INSERT INTO DISTRITO values (22, 'San Miguel');
INSERT INTO DISTRITO values (23, 'Santiago de Surco');
INSERT INTO DISTRITO values (24, 'Surquillo');
INSERT INTO DISTRITO values (25, 'Villa MarÃ­a del Triunfo');
INSERT INTO DISTRITO values (26, 'San Juan de Lurigancho');
INSERT INTO DISTRITO values (27, 'Santa Rosa');
INSERT INTO DISTRITO values (28, 'Los Olivos');
INSERT INTO DISTRITO values (29, 'Los Olivos');
INSERT INTO DISTRITO values (30, 'Villa El Savador');
INSERT INTO DISTRITO values (31, 'Santa Anita');

CALL USP_REGISTRARCLIENTE(1, '72571636', 'Andres', 'Cervantes', 'Av. Bolivar 112', '945894384');
CALL USP_REGISTRARCLIENTE(2, '34982382', 'Julio', 'Garcia', 'Av. Buckingham V Lt5', '934348544');
CALL USP_REGISTRARCLIENTE(3, '98123843', 'Leo', 'Galvez', 'Av. Materiales 2915', '994584585');
CALL USP_REGISTRARCLIENTE(4, '87123484', 'Adrian', 'Buleje', 'Av. Arriba PerÃº 1154', '978621178');
CALL USP_REGISTRARCLIENTE(5, '39874789', 'Marcelo', 'Agachate Conocelo', 'JirÃ³n Puno,3721', '943678347');
CALL USP_REGISTRARCLIENTE(6, '98349823', 'Pedro', 'Castillo', 'Av. La Paz 356 Of. 405', '934734433');
CALL USP_REGISTRARCLIENTE(7, '78237832', 'Jose', 'Lurita', 'Av. PerÃº 1240 Km 12', '984378934');
CALL USP_REGISTRARCLIENTE(8, '98438934', 'Daniel', 'Esteban', 'Calle Los Naranjos 174', '934438974');
CALL USP_REGISTRARCLIENTE(9, '23982389', 'Matias', 'Sosa', 'Jr. BelÃ©n 555', '948347384');
CALL USP_REGISTRARCLIENTE(10, '23289389', 'Ricardo', 'Robles', 'Los Algarrobos 253', '974337344');

INSERT INTO CATEGORIA(DESCRIPCION) VALUES('BEBIDAS');
INSERT INTO CATEGORIA(DESCRIPCION) VALUES('COMBOS');
INSERT INTO CATEGORIA(DESCRIPCION) VALUES('CHIFA');
INSERT INTO CATEGORIA(DESCRIPCION) VALUES('OFERTAS');
INSERT INTO CATEGORIA(DESCRIPCION) VALUES('SOPAS');
INSERT INTO CATEGORIA(DESCRIPCION) VALUES('HAMBURGUESAS');
INSERT INTO CATEGORIA(DESCRIPCION) VALUES('MARISCOS');

CALL USP_REGISTRARPRODUCTO('MARACUYA',5.99,14,1,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('CHICHA MORADA',5.99,13,1,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('COMBO CLASICO',14.99,5,2,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('COMBO FAMILIAR',42.00,5,2,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('ARROZ CHAUFA DE POLLO',10.99,20,3,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('AEROPUERTO DE POLLO',11.99,10,3,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('1 POLLO ENTERO + 1/4 DE POLLO + CHAUFA + PAPAS + GASEOSA 1 1/2L',64.99,5,4,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('1 POLLO ENTERO + 1/4 POLLO + PAPAS',49.99,4,4,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('SOPA DE DIETA',10,20,5,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('CALDO DE POLLO',15,10,5,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('SIMPLE',5.99,12,6,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('CHEESEBURGER',7.99,23,6,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('CEVICHE DE PESCADO',12.99,15,7,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');
CALL USP_REGISTRARPRODUCTO('CEVICHE + CHICHARRON',17.99,14,7,'https://res.cloudinary.com/dfuuywyk9/image/upload/v1622821263/notfound_gwgndg.png');


select * from empleado;


DROP PROCEDURE IF EXISTS USP_REGISTRARPEDIDO;
DELIMITER $$
CREATE PROCEDURE USP_REGISTRARPEDIDO(ID_PE INT,ID_EM INT, ID_CLI INT, CANT TINYINT
)
BEGIN
    INSERT INTO PEDIDO VALUES (ID_PE,ID_EM, ID_CLI, sysdate(), null, CANT);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS USP_REGISTRARDETALLEPEDIDO;
DELIMITER $$
CREATE PROCEDURE USP_REGISTRARDETALLEPEDIDO(ID_PE INT, ID_PRO INT, PRECIO DECIMAL(6, 2),CANTIDAD TINYINT
)
BEGIN
    INSERT INTO DETALLE_PEDIDO VALUES (ID_PE,ID_PRO,PRECIO,CANTIDAD);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS USP_REGISTRARBOLETA;
DELIMITER $$
CREATE PROCEDURE USP_REGISTRARBOLETA(ID_PE INT, ID_BOL CHAR(11), PRETOTAL DECIMAL(6, 2),DESCUENTO DECIMAL(6, 2)
)
BEGIN
	SET DESCUENTO = 0.00;
    INSERT INTO BOLETA VALUES (ID_PE, ID_BOL , PRETOTAL,DESCUENTO);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS USP_RESTARPRODUCTO;
DELIMITER $$
CREATE PROCEDURE USP_RESTARPRODUCTO(CANT INT, CODIGO INT)
BEGIN
    UPDATE PRODUCTO SET CANTIDAD = CANTIDAD -CANT WHERE ID_PRO = CODIGO;
END$$
DELIMITER ;

select * from pedido;
select * from detalle_pedido;
select * from boleta;
select * from producto;
SELECT * FROM empleado;
SELECT (count(ID_PE) + 1) FROM PEDIDO;

DROP PROCEDURE IF EXISTS USP_CATEGORIZACIONCLIENTES;
DELIMITER $$
CREATE PROCEDURE USP_CATEGORIZACIONCLIENTES()
BEGIN
    SELECT C.ID_CLI,CONCAT(C.NOM_CLI, ' ' ,C.APE_CLI) AS 'NOMBRE CLIENTE',SUM(P.CANTIDAD_TOTAL) AS 'CANTIDAD COMPRAS', 
    CASE WHEN P.CANTIDAD_TOTAL <=5 THEN 'COMPRADOR OCASIONAL' 
    WHEN P.CANTIDAD_TOTAL <50 THEN 'COMPRADOR HABITUAL'
    ELSE 'COMPRADOR FRECUENTE'
    END AS SEGMENTO_CLIENTE
    FROM PEDIDO AS P
    INNER JOIN CLIENTE AS C
    ON P.ID_CLI = C.ID_CLI
    GROUP BY ID_CLI 
    ORDER BY 1 ASC;
END$$
DELIMITER ;

CALL USP_CATEGORIZACIONCLIENTES;

DROP PROCEDURE IF EXISTS USP_DESCUENTOCLIENTE;
DELIMITER $$
CREATE PROCEDURE USP_DESCUENTOCLIENTE(CLI INT)
BEGIN
    SELECT C.ID_CLI,CONCAT(C.NOM_CLI, ' ' ,C.APE_CLI) AS 'NOMBRE CLIENTE',SUM(P.CANTIDAD_TOTAL) AS 'CANTIDAD COMPRAS', 
    CASE
    WHEN SUM(P.CANTIDAD_TOTAL)<50 THEN 0.00
    WHEN SUM(P.CANTIDAD_TOTAL)>50 AND SUM(P.CANTIDAD_TOTAL)<100 THEN 0.03
    ELSE 0.05
    END AS DESCUENTO
    FROM CLIENTE AS C
    INNER JOIN PEDIDO AS P
    ON C.ID_CLI = P.ID_CLI
    WHERE C.ID_CLI = CLI
    GROUP BY C.ID_CLI;
END$$
DELIMITER ;

CALL USP_DESCUENTOCLIENTE(1);

DROP PROCEDURE IF EXISTS USP_CLIENTEXDNI;
DELIMITER $$
CREATE PROCEDURE USP_CLIENTEXDNI(DNI CHAR(8))
BEGIN
    SELECT CONCAT(C.NOM_CLI, ' ' ,C.APE_CLI) AS 'NOMBRE CLIENTE', D.NOM_DIST, C.DIR_CLI
    FROM CLIENTE AS C
    INNER JOIN DISTRITO AS D
    ON C.ID_DIST = D.ID_DIST
    WHERE C.DNI_CLI = DNI ;
END$$
DELIMITER ;

CALL USP_CLIENTEXDNI('72571636');