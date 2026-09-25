-- PROJETO DE CURRICULARIZAÇÃO - ENTREGA_2_BANCO_VENDAS
-- ENTREGA 2 - DDL + SEQUENCES + TRIGGERS DE HISTÓRICO
-- Baseado no DDL original e no padrão do script de exemplo.
--
-- TRIGGERS UTILIZADOS:
-- 1) BEFORE INSERT para geração automática das chaves com SEQUENCE.
-- 2) BEFORE UPDATE OR DELETE para historiamento.
--

-- - UPDATE/DELETE com histórico;
-- - SAVEPOINT + ROLLBACK para demonstrar transação sem gravar a alteração.
--

-- Quando a planilha não possui um campo correspondente ao modelo (ex.: identificador
-- do item), foi usado um valor sintético apenas para permitir o teste da estrutura.

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

-- ============================================================
-- 1. TABELAS CADASTRAIS
-- ============================================================

CREATE TABLE FORNECEDORES (
    for_id       NUMBER(5)     NOT NULL,
    for_nome     VARCHAR2(150) NOT NULL,
    for_telefone VARCHAR2(20),
    CONSTRAINT pk_fornecedores PRIMARY KEY (for_id)
);

CREATE TABLE MARCAS (
    mar_id   NUMBER(5)     NOT NULL,
    mar_nome VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_marcas PRIMARY KEY (mar_id)
);

CREATE TABLE CATEGORIAS (
    cat_id   NUMBER(5)     NOT NULL,
    cat_nome VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_categorias PRIMARY KEY (cat_id)
);

CREATE TABLE CLIENTES (
    cli_id       NUMBER(5)     NOT NULL,
    cli_nome     VARCHAR2(150) NOT NULL,
    cli_telefone VARCHAR2(20),
    CONSTRAINT pk_clientes PRIMARY KEY (cli_id)
);

CREATE TABLE TIPO_IDENTIFICADOR (
    tid_id        NUMBER(5)     NOT NULL,
    tid_nome      VARCHAR2(50)  NOT NULL,
    tid_descricao VARCHAR2(255),
    CONSTRAINT pk_tipo_identificador PRIMARY KEY (tid_id)
);

-- ============================================================
-- 2. PRODUTOS
-- ============================================================

CREATE TABLE PRODUTOS (
    prod_id                NUMBER(5)     NOT NULL,
    prod_mar_id            NUMBER(5)     NOT NULL,
    prod_cat_id            NUMBER(5)     NOT NULL,
    prod_nome              VARCHAR2(150) NOT NULL,
    prod_preco_venda_atual NUMBER(10,2)  NOT NULL,
    CONSTRAINT pk_produtos PRIMARY KEY (prod_id),
    CONSTRAINT fk_prod_mar FOREIGN KEY (prod_mar_id) REFERENCES MARCAS(mar_id),
    CONSTRAINT fk_prod_cat FOREIGN KEY (prod_cat_id) REFERENCES CATEGORIAS(cat_id)
);

-- ============================================================
-- 3. ENTRADAS
-- ============================================================

CREATE TABLE COMPRAS (
    com_id          NUMBER(5) NOT NULL,
    com_for_id      NUMBER(5) NOT NULL,
    com_data_compra DATE      NOT NULL,
    CONSTRAINT pk_compras PRIMARY KEY (com_id),
    CONSTRAINT fk_com_for FOREIGN KEY (com_for_id) REFERENCES FORNECEDORES(for_id)
);

CREATE TABLE ITENS_COMPRA (
    itc_id                    NUMBER(5)    NOT NULL,
    itc_com_id                NUMBER(5)    NOT NULL,
    itc_prod_id               NUMBER(5)    NOT NULL,
    itc_quantidade            INTEGER      NOT NULL,
    itc_valor_unitario_compra NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_itens_compra PRIMARY KEY (itc_id),
    CONSTRAINT fk_itc_com FOREIGN KEY (itc_com_id) REFERENCES COMPRAS(com_id),
    CONSTRAINT fk_itc_prod FOREIGN KEY (itc_prod_id) REFERENCES PRODUTOS(prod_id)
);

CREATE TABLE IDENTIFICADOR_ITEM (
    idi_id     NUMBER(5)     NOT NULL,
    idi_itc_id NUMBER(5)     NOT NULL,
    idi_tid_id NUMBER(5)     NOT NULL,
    idi_valor  VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_identificador_item PRIMARY KEY (idi_id),
    CONSTRAINT fk_idi_itc FOREIGN KEY (idi_itc_id) REFERENCES ITENS_COMPRA(itc_id),
    CONSTRAINT fk_idi_tid FOREIGN KEY (idi_tid_id) REFERENCES TIPO_IDENTIFICADOR(tid_id)
);

-- ============================================================
-- 4. SAÍDAS
-- ============================================================

CREATE TABLE VENDAS (
    ven_id         NUMBER(5) NOT NULL,
    ven_cli_id     NUMBER(5) NOT NULL,
    ven_data_venda DATE      NOT NULL,
    CONSTRAINT pk_vendas PRIMARY KEY (ven_id),
    CONSTRAINT fk_ven_cli FOREIGN KEY (ven_cli_id) REFERENCES CLIENTES(cli_id)
);

CREATE TABLE ITENS_VENDA (
    itv_id                   NUMBER(5)    NOT NULL,
    itv_ven_id              NUMBER(5)    NOT NULL,
    itv_itc_id              NUMBER(5)    NOT NULL,
    itv_quantidade           INTEGER      NOT NULL,
    itv_valor_unitario_venda NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_itens_venda PRIMARY KEY (itv_id),
    CONSTRAINT fk_itv_ven FOREIGN KEY (itv_ven_id) REFERENCES VENDAS(ven_id),
    CONSTRAINT fk_itv_itc FOREIGN KEY (itv_itc_id) REFERENCES ITENS_COMPRA(itc_id)
);

-- ============================================================
-- SEQUENCES + TRIGGERS DE GERAÇÃO DE ID
-- ============================================================

CREATE SEQUENCE FORNECEDORES_FOR_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER FORNECEDORES_FOR_ID_TRG
BEFORE INSERT ON FORNECEDORES
FOR EACH ROW
BEGIN
    :NEW.for_id := FORNECEDORES_FOR_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE MARCAS_MAR_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER MARCAS_MAR_ID_TRG
BEFORE INSERT ON MARCAS
FOR EACH ROW
BEGIN
    :NEW.mar_id := MARCAS_MAR_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE CATEGORIAS_CAT_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER CATEGORIAS_CAT_ID_TRG
BEFORE INSERT ON CATEGORIAS
FOR EACH ROW
BEGIN
    :NEW.cat_id := CATEGORIAS_CAT_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE CLIENTES_CLI_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER CLIENTES_CLI_ID_TRG
BEFORE INSERT ON CLIENTES
FOR EACH ROW
BEGIN
    :NEW.cli_id := CLIENTES_CLI_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE TIPO_IDENTIFICADOR_TID_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER TIPO_IDENTIFICADOR_TID_ID_TRG
BEFORE INSERT ON TIPO_IDENTIFICADOR
FOR EACH ROW
BEGIN
    :NEW.tid_id := TIPO_IDENTIFICADOR_TID_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE PRODUTOS_PROD_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER PRODUTOS_PROD_ID_TRG
BEFORE INSERT ON PRODUTOS
FOR EACH ROW
BEGIN
    :NEW.prod_id := PRODUTOS_PROD_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE COMPRAS_COM_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER COMPRAS_COM_ID_TRG
BEFORE INSERT ON COMPRAS
FOR EACH ROW
BEGIN
    :NEW.com_id := COMPRAS_COM_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE ITENS_COMPRA_ITC_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER ITENS_COMPRA_ITC_ID_TRG
BEFORE INSERT ON ITENS_COMPRA
FOR EACH ROW
BEGIN
    :NEW.itc_id := ITENS_COMPRA_ITC_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE IDENTIFICADOR_ITEM_IDI_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER IDENTIFICADOR_ITEM_IDI_ID_TRG
BEFORE INSERT ON IDENTIFICADOR_ITEM
FOR EACH ROW
BEGIN
    :NEW.idi_id := IDENTIFICADOR_ITEM_IDI_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE VENDAS_VEN_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER VENDAS_VEN_ID_TRG
BEFORE INSERT ON VENDAS
FOR EACH ROW
BEGIN
    :NEW.ven_id := VENDAS_VEN_ID_SEQ.NEXTVAL;
END;
/

CREATE SEQUENCE ITENS_VENDA_ITV_ID_SEQ
    START WITH 1
    NOCACHE
    ORDER;

CREATE OR REPLACE TRIGGER ITENS_VENDA_ITV_ID_TRG
BEFORE INSERT ON ITENS_VENDA
FOR EACH ROW
BEGIN
    :NEW.itv_id := ITENS_VENDA_ITV_ID_SEQ.NEXTVAL;
END;
/

-- ============================================================
-- TABELAS DE HISTÓRICO + TRIGGERS DE HISTORIAMENTO
-- Padrão: BEFORE UPDATE OR DELETE, gravando :OLD + SYSDATE.
-- ============================================================

CREATE TABLE H_FORNECEDORES (
    h_for_id NUMBER(5),
    h_for_nome VARCHAR2(150),
    h_for_telefone VARCHAR2(20),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_FORNECEDORES
BEFORE UPDATE OR DELETE ON FORNECEDORES
FOR EACH ROW
BEGIN
    INSERT INTO H_FORNECEDORES (h_for_id, h_for_nome, h_for_telefone, h_dt_entrada)
    VALUES (:OLD.for_id, :OLD.for_nome, :OLD.for_telefone, SYSDATE);
END;
/

CREATE TABLE H_MARCAS (
    h_mar_id NUMBER(5),
    h_mar_nome VARCHAR2(100),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_MARCAS
BEFORE UPDATE OR DELETE ON MARCAS
FOR EACH ROW
BEGIN
    INSERT INTO H_MARCAS (h_mar_id, h_mar_nome, h_dt_entrada)
    VALUES (:OLD.mar_id, :OLD.mar_nome, SYSDATE);
END;
/

CREATE TABLE H_CATEGORIAS (
    h_cat_id NUMBER(5),
    h_cat_nome VARCHAR2(100),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_CATEGORIAS
BEFORE UPDATE OR DELETE ON CATEGORIAS
FOR EACH ROW
BEGIN
    INSERT INTO H_CATEGORIAS (h_cat_id, h_cat_nome, h_dt_entrada)
    VALUES (:OLD.cat_id, :OLD.cat_nome, SYSDATE);
END;
/

CREATE TABLE H_CLIENTES (
    h_cli_id NUMBER(5),
    h_cli_nome VARCHAR2(150),
    h_cli_telefone VARCHAR2(20),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_CLIENTES
BEFORE UPDATE OR DELETE ON CLIENTES
FOR EACH ROW
BEGIN
    INSERT INTO H_CLIENTES (h_cli_id, h_cli_nome, h_cli_telefone, h_dt_entrada)
    VALUES (:OLD.cli_id, :OLD.cli_nome, :OLD.cli_telefone, SYSDATE);
END;
/

CREATE TABLE H_TIPO_IDENTIFICADOR (
    h_tid_id NUMBER(5),
    h_tid_nome VARCHAR2(50),
    h_tid_descricao VARCHAR2(255),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_TIPO_IDENTIFICADOR
BEFORE UPDATE OR DELETE ON TIPO_IDENTIFICADOR
FOR EACH ROW
BEGIN
    INSERT INTO H_TIPO_IDENTIFICADOR (h_tid_id, h_tid_nome, h_tid_descricao, h_dt_entrada)
    VALUES (:OLD.tid_id, :OLD.tid_nome, :OLD.tid_descricao, SYSDATE);
END;
/

CREATE TABLE H_PRODUTOS (
    h_prod_id NUMBER(5),
    h_prod_mar_id NUMBER(5),
    h_prod_cat_id NUMBER(5),
    h_prod_nome VARCHAR2(150),
    h_prod_preco_venda_atual NUMBER(10,2),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_PRODUTOS
BEFORE UPDATE OR DELETE ON PRODUTOS
FOR EACH ROW
BEGIN
    INSERT INTO H_PRODUTOS (h_prod_id, h_prod_mar_id, h_prod_cat_id, h_prod_nome, h_prod_preco_venda_atual, h_dt_entrada)
    VALUES (:OLD.prod_id, :OLD.prod_mar_id, :OLD.prod_cat_id, :OLD.prod_nome, :OLD.prod_preco_venda_atual, SYSDATE);
END;
/

CREATE TABLE H_COMPRAS (
    h_com_id NUMBER(5),
    h_com_for_id NUMBER(5),
    h_com_data_compra DATE,
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_COMPRAS
BEFORE UPDATE OR DELETE ON COMPRAS
FOR EACH ROW
BEGIN
    INSERT INTO H_COMPRAS (h_com_id, h_com_for_id, h_com_data_compra, h_dt_entrada)
    VALUES (:OLD.com_id, :OLD.com_for_id, :OLD.com_data_compra, SYSDATE);
END;
/

CREATE TABLE H_ITENS_COMPRA (
    h_itc_id NUMBER(5),
    h_itc_com_id NUMBER(5),
    h_itc_prod_id NUMBER(5),
    h_itc_quantidade INTEGER,
    h_itc_valor_unitario_compra NUMBER(10,2),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_ITENS_COMPRA
BEFORE UPDATE OR DELETE ON ITENS_COMPRA
FOR EACH ROW
BEGIN
    INSERT INTO H_ITENS_COMPRA (h_itc_id, h_itc_com_id, h_itc_prod_id, h_itc_quantidade, h_itc_valor_unitario_compra, h_dt_entrada)
    VALUES (:OLD.itc_id, :OLD.itc_com_id, :OLD.itc_prod_id, :OLD.itc_quantidade, :OLD.itc_valor_unitario_compra, SYSDATE);
END;
/

CREATE TABLE H_IDENTIFICADOR_ITEM (
    h_idi_id NUMBER(5),
    h_idi_itc_id NUMBER(5),
    h_idi_tid_id NUMBER(5),
    h_idi_valor VARCHAR2(100),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_IDENTIFICADOR_ITEM
BEFORE UPDATE OR DELETE ON IDENTIFICADOR_ITEM
FOR EACH ROW
BEGIN
    INSERT INTO H_IDENTIFICADOR_ITEM (h_idi_id, h_idi_itc_id, h_idi_tid_id, h_idi_valor, h_dt_entrada)
    VALUES (:OLD.idi_id, :OLD.idi_itc_id, :OLD.idi_tid_id, :OLD.idi_valor, SYSDATE);
END;
/

CREATE TABLE H_VENDAS (
    h_ven_id NUMBER(5),
    h_ven_cli_id NUMBER(5),
    h_ven_data_venda DATE,
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_VENDAS
BEFORE UPDATE OR DELETE ON VENDAS
FOR EACH ROW
BEGIN
    INSERT INTO H_VENDAS (h_ven_id, h_ven_cli_id, h_ven_data_venda, h_dt_entrada)
    VALUES (:OLD.ven_id, :OLD.ven_cli_id, :OLD.ven_data_venda, SYSDATE);
END;
/

CREATE TABLE H_ITENS_VENDA (
    h_itv_id NUMBER(5),
    h_itv_ven_id NUMBER(5),
    h_itv_itc_id NUMBER(5),
    h_itv_quantidade INTEGER,
    h_itv_valor_unitario_venda NUMBER(10,2),
    h_dt_entrada DATE NOT NULL
);

CREATE OR REPLACE TRIGGER TG_H_ITENS_VENDA
BEFORE UPDATE OR DELETE ON ITENS_VENDA
FOR EACH ROW
BEGIN
    INSERT INTO H_ITENS_VENDA (h_itv_id, h_itv_ven_id, h_itv_itc_id, h_itv_quantidade, h_itv_valor_unitario_venda, h_dt_entrada)
    VALUES (:OLD.itv_id, :OLD.itv_ven_id, :OLD.itv_itc_id, :OLD.itv_quantidade, :OLD.itv_valor_unitario_venda, SYSDATE);
END;
/

-- ============================================================
