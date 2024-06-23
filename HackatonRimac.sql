CREATE TABLE Atenciones_2023 AS
SELECT *
FROM read_csv_auto('C:\duckdb_bases\Atenciones 2023.csv');

CREATE TABLE organized_data AS
SELECT *
FROM read_csv_auto('C:\duckdb_bases\organized_data.csv')
;

CREATE TABLE sumaria_2023 AS
SELECT *
FROM read_csv_auto('C:\duckdb_bases\Sumaria-2023.csv')
;

CREATE TABLE morbilidad AS
SELECT *
FROM read_csv_auto('C:\duckdb_bases\toymuerto.csv')
;


CREATE TABLE siniestros AS
SELECT count(*)
FROM read_csv_auto('C:\duckdb_bases\SINIESTROS.csv', ignore_errors=true);

--- data principal
CREATE TABLE data_mapa AS
SELECT 
    *,
    LEFT("CODIGO DE UBIGEO Y CENTRO POBLADO", 6) AS UBIGEO
FROM organized_data;
  
SELECT *
FROM Atenciones_2023_nueva

CREATE TABLE Atenciones_2023_nueva AS
SELECT 
    *,
    CASE 
        WHEN etapa = 0 THEN 'menos de un mes'
        WHEN etapa = 1 THEN '1 a 4 años'
        WHEN etapa = 2 THEN '1 a 11 años'
        WHEN etapa = 3 THEN '5 a 11 años'
        WHEN etapa = 4 THEN '12 a 17 años'
        WHEN etapa = 5 THEN '18 a 29 años'
        WHEN etapa = 6 THEN '30 a 59 años'
        WHEN etapa = 7 THEN '60 años a más'
        ELSE 'Desconocido'
    END AS etapa_descripcion,
    CASE 
        WHEN ambito = 1 THEN 'Minsa'
        WHEN ambito = 2 THEN 'EsSalud'
        WHEN ambito = 3 THEN 'FFAA'
        WHEN ambito = 4 THEN 'Privados'
        WHEN ambito = 9 THEN 'Otros'
        ELSE 'Desconocido'
    END AS ambito_descripcion
FROM 
    Atenciones_2023;


CREATE TABLE Atenciones_2023_nueva_final AS
SELECT 
    Departamento,
    Provincia,
    Distrito,
    SUM(CASE WHEN id_genero = 'M' THEN 1 ELSE 0 END) AS Total_M,
    SUM(CASE WHEN id_genero = 'F' THEN 1 ELSE 0 END) AS Total_F,
    SUM(eess_n) AS Total_eess_n,
    SUM(eess_c) AS Total_eess_c,
    SUM(eess_r) AS Total_eess_r,
    CASE
        WHEN COUNT(DISTINCT CASE WHEN ambito_descripcion = 'EsSalud' THEN 'EsSalud' END) > 0 THEN 'EsSalud'
        WHEN COUNT(DISTINCT CASE WHEN ambito_descripcion = 'Minsa' THEN 'Minsa' END) > 0 THEN 'Minsa'
        WHEN COUNT(DISTINCT CASE WHEN ambito_descripcion = 'FFAA' THEN 'FFAA' END) > 0 THEN 'FFAA'
        ELSE 'Otros'
    END AS ambito_descripcion
FROM 
    Atenciones_2023_nueva
GROUP BY 
    Departamento,
    Provincia,
    Distrito;


SELECT *
FROM Atenciones_2023_nueva_final
   
   
SELECT UBIGEO, ESTRSOCIAL 
FROM sumaria_2023
ORDER BY UBIGEO ASC;

SELECT *
FROM TABLA_TOTALatenciones


CREATE TABLE SUMARIA_2023_NUEVA AS
SELECT 
    UBIGEO,
    FIRST(DOMINIO) AS DOMINIO,
    FIRST(ESTRATO) AS ESTRATO,
     ROUND(AVG(MIEPERHO), 0) AS MIEPERHO,
    AVG(INGHOG1D) AS INGHOG1D,
    AVG(GASHOG2D) AS GASHOG2D,
    FIRST(ESTRSOCIAL) AS ESTRSOCIAL,
    FIRST(POBREZA) AS POBREZA
FROM 
    sumaria_2023
GROUP BY 
    UBIGEO;

CREATE TABLE SUMARIA_2023_NUEVA2 AS
SELECT 
    UBIGEO,
    FIRST(DOMINIO) AS DOMINIO,
    FIRST(ESTRATO) AS ESTRATO,
    ROUND(AVG(MIEPERHO), 0) AS MIEPERHO,
    AVG(INGHOG1D) AS INGHOG1D,
    AVG(GASHOG2D) AS GASHOG2D,
    CASE
        WHEN AVG(INGHOG1D) > 120000 THEN 'A'
        WHEN AVG(INGHOG1D) > 60000 AND AVG(INGHOG1D) <= 120000 THEN 'A'
        WHEN AVG(INGHOG1D) > 48000 AND AVG(INGHOG1D) <= 60000 THEN 'B'
        WHEN AVG(INGHOG1D) > 30000 AND AVG(INGHOG1D) <= 48000 THEN 'C'
        WHEN AVG(INGHOG1D) <= 30000 THEN 'C'
        ELSE NULL
    END AS NIVELSOCIAL,
    FIRST(POBREZA) AS POBREZA
FROM 
    sumaria_2023
GROUP BY 
    UBIGEO;
   
   -- unir las bases
SELECT COUNT(*)
FROM SUMARIA_2023_NUEVA2


CREATE TABLE base_final_ver4 AS
SELECT 
    data_mapa.*,
    Atenciones_2023_nueva_final.*,  -- Seleccionar todas las columnas de Atenciones_2023_nueva_final
    SUMARIA_2023_NUEVA2.*            -- Seleccionar todas las columnas de SUMARIA_2023_NUEVA
FROM 
    data_mapa
LEFT JOIN 
    Atenciones_2023_nueva_final 
    ON data_mapa.Departamento = Atenciones_2023_nueva_final.Departamento 
    AND data_mapa.Provincia = Atenciones_2023_nueva_final.Provincia 
    AND data_mapa.Distrito = Atenciones_2023_nueva_final.Distrito
LEFT JOIN 
    SUMARIA_2023_NUEVA2
    ON data_mapa.UBIGEO = SUMARIA_2023_NUEVA2.UBIGEO;

SELECT DEPARTAMENTO, count(distrito) AS cantidad
FROM base_final_ver1
GROUP BY DEPARTAMENTO
ORDER BY DEPARTAMENTO asc

-- Actualiza la tabla base_final_ver1 añadiendo la nueva columna ESTRSOCIAL
ALTER TABLE base_final_ver1
ADD ESTRATO_SOCIAL VARCHAR(10);

-- Actualiza los valores de la nueva columna ESTRSOCIAL basados en la columna ESTRSOCIAL_ORIGINAL
UPDATE base_final_ver1
SET ESTRATO_SOCIAL = CASE
                    WHEN ESTRSOCIAL = 1 THEN 'A'
                    WHEN ESTRSOCIAL = 2 THEN 'B'
                    WHEN ESTRSOCIAL = 3 THEN 'C'
                    WHEN ESTRSOCIAL = 4 THEN 'D'
                    WHEN ESTRSOCIAL = 5 THEN 'E'
                    WHEN ESTRSOCIAL = 6 THEN 'Rural'  -- Suponiendo que 6 corresponde a 'Rural'
                    ELSE NULL  -- Manejo de otros casos si es necesario
                 END;
                
ALTER TABLE base_final_ver1
ADD ESTRATO_FINAL VARCHAR(100);



CREATE TABLE base_final_ver2 AS
SELECT 
    base_final_ver1.*,
    Atenciones_2023_nueva.id_genero,  -- Seleccionar todas las columnas de Atenciones_2023
FROM 
    base_final_ver1
RIGHT JOIN 
    Atenciones_2023_nueva 
    ON base_final_ver1.Departamento = Atenciones_2023_nueva.Departamento 
    AND base_final_ver1.Provincia = Atenciones_2023_nueva.Provincia 
    AND base_final_ver1.Distrito = Atenciones_2023_nueva.Distrito

SELECT *
FROM Atenciones_2023_nueva

DROP TABLE base_final_ver3
CREATE TABLE base_final_ver3 AS
SELECT 
    base_final_ver1.*,
    morbilidad.*,  -- Seleccionar todas las columnas de Atenciones_2023
FROM 
    base_final_ver1
inner JOIN 
    morbilidad 
    ON base_final_ver1.Departamento = morbilidad.Departamento 
    AND base_final_ver1.Provincia = morbilidad.Provincia 
    AND base_final_ver1.Distrito = morbilidad.Distrito
    
    
SELECT *
FROM morbilidad


-- Crear una vista con las enfermedades seleccionadas
CREATE VIEW enfermedades_seleccionadas AS
SELECT 
    Departamento, 
    Provincia, 
    Distrito, 
    anio, 
    etapa, 
    desc_gru, 
    cantidad
FROM 
    morbilidad
WHERE 
    desc_gru IN (
        '(A00 - A09) ENFERMEDADES INFECCIOSAS INTESTINALES',
        '(E65 - E68) OBESIDAD Y OTROS DE HIPERALIMENTACION',
        '(J00 - J06) INFECCIONES AGUDAS DE LAS VIAS RESPIRATORIAS SUPERIORES',
        '(K00 - K14) ENFERMEDADES DE LA CAVIDAD BUCAL, DE LAS GLANDULAS SALIVALES Y DE LOS MAXILARES',
        '(K20 - K31) ENFERMEDADES DEL ESOFAGO, DEL ESTOMAGO Y DEL DUODENO',
        '(M40 - M54) DORSOPATIAS',
        '(N30 - N39) OTRAS ENFERMEDADES DEL SISTEMA URINARIO',
        '(O20 - O29) OTROS TRASTORNOS MATERNOS RELACIONADOS PRINCIPALMENTE CON EL EMBARAZO',
        '(R10 - R19) SINTOMAS Y SIGNOS QUE INVOLUCRAN EL SISTEMA DIGESTIVO Y EL ABDOMEN',
        '(R50 - R69) SINTOMAS Y SIGNOS GENERALES'
    );

-- Pivotar los datos
CREATE VIEW enfermedades_pivot AS
SELECT 
    Departamento,
    Provincia,
    Distrito,
    anio,
    etapa,
    MAX(CASE WHEN desc_gru = '(A00 - A09) ENFERMEDADES INFECCIOSAS INTESTINALES' THEN cantidad ELSE 0 END) AS "A00_A09",
    MAX(CASE WHEN desc_gru = '(E65 - E68) OBESIDAD Y OTROS DE HIPERALIMENTACION' THEN cantidad ELSE 0 END) AS "E65_E68",
    MAX(CASE WHEN desc_gru = '(J00 - J06) INFECCIONES AGUDAS DE LAS VIAS RESPIRATORIAS SUPERIORES' THEN cantidad ELSE 0 END) AS "J00_J06",
    MAX(CASE WHEN desc_gru = '(K00 - K14) ENFERMEDADES DE LA CAVIDAD BUCAL, DE LAS GLANDULAS SALIVALES Y DE LOS MAXILARES' THEN cantidad ELSE 0 END) AS "K00_K14",
    MAX(CASE WHEN desc_gru = '(K20 - K31) ENFERMEDADES DEL ESOFAGO, DEL ESTOMAGO Y DEL DUODENO' THEN cantidad ELSE 0 END) AS "K20_K31",
    MAX(CASE WHEN desc_gru = '(M40 - M54) DORSOPATIAS' THEN cantidad ELSE 0 END) AS "M40_M54",
    MAX(CASE WHEN desc_gru = '(N30 - N39) OTRAS ENFERMEDADES DEL SISTEMA URINARIO' THEN cantidad ELSE 0 END) AS "N30_N39",
    MAX(CASE WHEN desc_gru = '(O20 - O29) OTROS TRASTORNOS MATERNOS RELACIONADOS PRINCIPALMENTE CON EL EMBARAZO' THEN cantidad ELSE 0 END) AS "O20_O29",
    MAX(CASE WHEN desc_gru = '(R10 - R19) SINTOMAS Y SIGNOS QUE INVOLUCRAN EL SISTEMA DIGESTIVO Y EL ABDOMEN' THEN cantidad ELSE 0 END) AS "R10_R19",
    MAX(CASE WHEN desc_gru = '(R50 - R69) SINTOMAS Y SIGNOS GENERALES' THEN cantidad ELSE 0 END) AS "R50_R69"
FROM 
    enfermedades_seleccionadas
GROUP BY 
    Departamento, 
    Provincia, 
    Distrito, 
    anio, 
    etapa;

-- Consultar la vista pivotada
SELECT * FROM enfermedades_pivot;

CREATE TABLE base_final_ver5 AS
SELECT 
    base_final_ver4.*,
    enfermedades_pivot.*,  -- Seleccionar todas las columnas de Atenciones_2023
FROM 
    base_final_ver4
LEFT JOIN 
    enfermedades_pivot 
    ON base_final_ver4.Departamento = enfermedades_pivot.Departamento 
    AND base_final_ver4.Provincia = enfermedades_pivot.Provincia 
    AND base_final_ver4.Distrito = enfermedades_pivot.Distrito
WHERE base_final_ver4.DEPARTAMENTO = 'AMAZONAS'
    
SELECT NIVELSOCIAL, COUNT(NIVELSOCIAL) AS C
FROM base_final_ver5_unique
GROUP BY NIVELSOCIAL

SELECT count(NIVELSOCIAL)
FROM base_final_ver5_unique
WHERE NIVELSOCIAL = ' '


DROP TABLE base_final_ver5

CREATE TABLE base_final_ver5_unique AS
SELECT DISTINCT ON (UBIGEO) *
FROM base_final_ver5
ORDER BY UBIGEO;

SELECT *
FROM siniestros_renombrados


CREATE TABLE siniestros_renombrados AS
SELECT 
    column0 AS "FECHA SINIESTRO",
    column1 AS "CLASE SINIESTRO",
    column2 AS "CANTIDAD DE FALLECIDOS",
    column3 AS "CANTIDAD DE LESIONADOS",
    column4 AS "CANTIDAD DE VEHICULOS DAÑADOS",
    column5 AS "DEPARTAMENTO",
    column6 AS "PROVINCIA",
    column7 AS "DISTRITO",
    column8 AS "SINIESTROS"
FROM 
    siniestros;

CREATE TABLE siniestros_final AS
SELECT 
    DEPARTAMENTO,
    PROVINCIA,
    DISTRITO,
    COUNT(*) AS TOTAL_SINIESTROS
FROM 
    siniestros_renombrados
GROUP BY 
    DEPARTAMENTO,
    PROVINCIA,
    DISTRITO
ORDER BY 
    DEPARTAMENTO,
    PROVINCIA,
    DISTRITO;
   
SELECT count(*)
FROM siniestros_final

CREATE TABLE base_final_ver6 AS
SELECT 
    base_final_ver5_unique.*,
    siniestros_final.TOTAL_SINIESTROS,  -- Seleccionar todas las columnas de Atenciones_2023
FROM 
    base_final_ver5_unique
LEFT JOIN 
    siniestros_final 
    ON base_final_ver5_unique.Departamento = siniestros_final.Departamento 
    AND base_final_ver5_unique.Provincia = siniestros_final.Provincia 
    AND base_final_ver5_unique.Distrito = siniestros_final.Distrito
    
SELECT *
FROM base_final_ver6
WHERE TOTAL_SINIESTROS IS null