DROP DATABASE IF EXISTS patito;
CREATE DATABASE patito;

USE patito;

CREATE TABLE TIPOEMPLEADO(
  ID_TP     INT          PRIMARY KEY AUTO_INCREMENT, 
  DESCRIPCION    VARCHAR(15)      NOT NULL UNIQUE
  );
  
  CREATE TABLE DISTRITO(
  ID_DIST	INT		  NOT NULL UNIQUE,
  NOM_DIST	VARCHAR(50)  NOT NULL
  );

CREATE TABLE EMPLEADO(
  ID_EM    INT          PRIMARY KEY AUTO_INCREMENT, 
  DNI_USU    CHAR(8)      NOT NULL UNIQUE,
  NOM_USU    VARCHAR(50)  NOT NULL,
  APE_USU    VARCHAR(50)  NOT NULL,
  TELEF_USU  VARCHAR(10)  UNIQUE,
  USU_USU	 VARCHAR(50)  NOT NULL UNIQUE,
  CLAVE_USU  VARCHAR(50)  NOT NULL UNIQUE,
  ID_TP	 	  INT		  NOT NULL,
  ESTADO      tinyint         NOT NULL,
  IMAGEN 	varchar(1000) 		null,
  FOREIGN KEY (ID_TP) references TIPOEMPLEADO (ID_TP)
);

CREATE TABLE CLIENTE(
  ID_CLI     	CHAR(5)       PRIMARY KEY,
  ID_DIST 		INT		  NOT NULL UNIQUE,
  DNI_CLI    CHAR(8)      NOT NULL UNIQUE,
  NOM_CLI    VARCHAR(50)  NOT NULL,
  APE_CLI    VARCHAR(50)  NOT NULL,
  DIR_CLI	 VARCHAR(50)  NOT NULL,
  TELEF_CLI  VARCHAR(10)  UNIQUE,
  FOREIGN KEY (ID_DIST) references DISTRITO (ID_DIST)
);

CREATE TABLE CATEGORIA(
  ID_CA     INT          PRIMARY KEY AUTO_INCREMENT, 
  DESCRIPCION    VARCHAR(30)      NOT NULL UNIQUE
  );

CREATE TABLE PRODUCTOS(
  ID_PRO     INT    PRIMARY KEY AUTO_INCREMENT, 
  DESCRIPCION    VARCHAR(100)      NOT NULL UNIQUE,
  PRECIO	DECIMAL(6,2) 		NOT NULL CHECK (PRECIO >0),
  CANTIDAD	tinyint 			NOT NULL CHECK(CANTIDAD >=0),
  ID_CA 	int		NOT NULL ,
  IMAGEN 	varchar(1000) 		null,
  FOREIGN KEY (ID_CA) references CATEGORIA (ID_CA)
);

CREATE TABLE PEDIDO(
  ID_PE     INT    		AUTO_INCREMENT, 
  ID_EM		INT       NOT NULL,
  ID_CLI	INT       NOT NULL,
  FECHA_PE	DATE 	NOT NULL,
  FECHA_EN	DATE	NULL,
  CANTIDAD_TOTAL	tinyint 			NOT NULL CHECK(CANTIDAD_TOTAL >=0),
  PRIMARY KEY (ID_PE, ID_EM,ID_CLI),
  FOREIGN KEY (ID_EM) REFERENCES EMPLEADO (ID_EM),
  FOREIGN KEY (ID_CLI) REFERENCES CLIENTE (ID_CLI)
);
CREATE TABLE DETALLE_PEDIDO(
  ID_PE		INT  NOT NULL,
  ID_PRO     INT         NOT NULL, 
  PRECIO	DECIMAL(6,2) 		NOT NULL CHECK (PRECIO >0),
  CANTIDAD	TINYINT 			NOT NULL CHECK(CANTIDAD >=0),
  FOREIGN KEY (ID_PE) references PEDIDO (ID_PE),
  FOREIGN KEY (ID_PRO) REFERENCES PRODUCTOS (ID_PRO)
);

CREATE TABLE BOLETA(
  ID_PE INT NOT NULL,
  ID_BOL CHAR(11) NOT NULL,
  PRETOTAL DECIMAL(6,2) NOT NULL,
  DESCUENTO DECIMAL(6,2) NOT NULL,
  PRIMARY KEY (ID_BOL),
  FOREIGN KEY (ID_PE) REFERENCES DETALLE_PEDIDO (ID_PE)
);